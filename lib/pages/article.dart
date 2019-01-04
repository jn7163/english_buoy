import 'package:flutter/gestures.dart';
import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flutter/material.dart';
import '../bus.dart';
import 'package:easy_alert/easy_alert.dart';
import '../dto/word.dart';
import './sign.dart';
import '../store/learned.dart';
import './articles.dart';
import '../store/article.dart';
import './add_article.dart';
import '../store/articles.dart';

@immutable
class ArticlePage extends StatefulWidget {
  ArticlePage({Key key, this.title, this.articleID}) : super(key: key);
  final String title;
  final int articleID;

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  String _title;
  int _articleID;

  @override
  void dispose() {
    print("dispose");
    _words.clear();
    bus.off("get_article_done");
    bus.off("analysis_done");
    bus.off("learned");
    super.dispose();
  }

  List _words = [
    Word('Loading'),
    Word('...'),
  ];
  // 单引号开头的, 前面不要留空白
  RegExp _noNeedExp = new RegExp(r"^'");
  // 这些符号前面不要加空格
  List _noNeedBlank = [".", "!", "'", ",", ":", '"', "?", "n't"];

  // 后台返回的文章结构
  String _tapedText = ''; // 当前点击的文本
  initState() {
    super.initState();
    _title = widget.title;
    _articleID = widget.articleID;

    bus.on("get_article_done", (arg) {
      setState(() {
        _words = arg.map((d) => Word.fromJson(d)).toList();
      });
      _putUnlearnedCount();
    });

    bus.on("analysis_done", (arg) {
      getArticleTitles();
      //渲染字体
      setState(() {
        _articleID = arg["id"];
        _title = arg["title"];
        _words.clear();
        _words = arg['words'].map((d) => Word.fromJson(d)).toList();
      });
    });
    // 设置为已学会
    bus.on("learned", (d) {
      String info;
      if (d.learned) {
        info = d.text + "已经学会";
      } else {
        info = "重新学习" + d.text;
      }
      _show(info);
      _putUnlearnedCount();
    });
    // postArticle();
  }

  void _show(String content) {
    Alert.toast(context, content,
        position: ToastPosition.bottom, duration: ToastDuration.long);
  }

  void _putUnlearnedCount() {
    // 重新计算未掌握单词数
    int unlearnedCount = _words
            .map((d) {
              if (d.level > 0 && !d.learned) return d.text;
            })
            .toSet()
            .length -
        1;
    //提交保存
    putUnlearnedCount(_articleID, unlearnedCount);
  }

  void _toAddArticle() {
    //添加文章
    Navigator.push(context, new MaterialPageRoute(builder: (context) {
      return AddArticlePage();
    }));
  }

// 设置当前文章的所有单词为正确状态
  _setAllWordLearned(String word, bool learned) {
    print("_setAllWordLearned");
    _words.forEach((d) {
      if (d.text.toLowerCase() == word) {
        print(word);
        setState(() {
          d.learned = learned;
        });
      }
    });
  }

// 无需学习的单词
  TextSpan _getNoNeedLearnTextSpan(Word word) {
    String blank = " ";
    if (_noNeedExp.hasMatch(word.text)) blank = "";
    if (_noNeedBlank.contains(word.text)) blank = "";
    return TextSpan(text: blank, children: [
      TextSpan(
          text: word.text,
          style: (this._tapedText == word.text)
              ? TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)
              : TextStyle(color: Colors.grey[600]),
          recognizer: _getTapRecognizer(word, true))
    ]);
  }

// 需要学习的单词
  TextSpan _getNeedLearnTextSpan(Word word) {
    return TextSpan(text: " ", children: [
      TextSpan(
          text: word.text,
          style: (this._tapedText == word.text)
              ? TextStyle(color: Colors.teal[500], fontWeight: FontWeight.bold)
              : TextStyle(color: Colors.teal[700]),
          recognizer: _getTapRecognizer(word))
    ]);
  }

// 定义各种 tap 后的处理
// isNoNeed 是不需要学习的
  MultiTapGestureRecognizer _getTapRecognizer(Word word,
      [bool isNoNeedLearn = false]) {
    bool longTap = false; // 标记是否长按, 长按不要触发单词查询
    return MultiTapGestureRecognizer()
      ..longTapDelay = Duration(milliseconds: 500)
      ..onLongTapDown = (i, detail) {
        // 不学习的没必要设置学会与否
        if (isNoNeedLearn) return;

        longTap = true;
        print("onLongTapDown");
        setState(() {
          word.learned = !word.learned;
        });
        putLearned(word.text, word.learned);
        bus.emit('learned', word);
        _setAllWordLearned(word.text.toLowerCase(), word.learned);
      }
      ..onTapCancel = (i) {
        setState(() {
          this._tapedText = '';
        });
      }
      ..onTap = (i) {
        // 避免长按的同时触发
        if (!longTap) {
          // 无需学的, 没必要记录学习次数以及显示级别
          if (!isNoNeedLearn) {
            _show(word.level.toString());
            putLearn(word.text);
          }
          ClipboardManager.copyToClipBoard(word.text);
        }
      }
      ..onTapDown = (i, d) {
        setState(() {
          this._tapedText = word.text;
        });
      }
      ..onTapUp = (i, d) {
        setState(() {
          this._tapedText = '';
        });
      };
  }

// 已经学会的单词
  TextSpan _getLearnedTextSpan(Word word) {
    return TextSpan(text: " ", children: [
      TextSpan(
        text: word.text,
        style: (this._tapedText == word.text)
            ? TextStyle(fontWeight: FontWeight.bold)
            : TextStyle(),
        recognizer: _getTapRecognizer(word),
      )
    ]);
  }

  void _toSignPage() {
    //导航到新路由
    Navigator.push(context, new MaterialPageRoute(builder: (context) {
      return SignInPage();
    }));
  }

  void _toArticlesPage() {
    //导航文章列表
    Navigator.push(context, new MaterialPageRoute(builder: (context) {
      return ArticlesPage();
    }));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.list),
          tooltip: 'go to articles',
          onPressed: _toArticlesPage,
        ),
        title: Text(_title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            tooltip: 'Air it',
            onPressed: _toSignPage,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 10.0, left: 10.0, bottom: 10, right: 10),
        child: RichText(
          text: TextSpan(
            text: '', // 英文似乎并不缩进
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: "NotoSans-Medium"),
            children: _words.map((d) {
              // return TextSpan(text: d.text);
              if (d.learned) {
                return _getLearnedTextSpan(d);
              }
              // if (d.level != null && d.level > 0 && d.level < 1000) {
              if (d.level != null && d.level != 0) {
                return _getNeedLearnTextSpan(d);
              } else {
                return _getNoNeedLearnTextSpan(d);
              }
            }).toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toAddArticle,
        tooltip: 'add article',
        child: Icon(Icons.add),
      ),
    );
  }
}
