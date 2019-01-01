import 'package:flutter/gestures.dart';
import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flutter/material.dart';
import '../bus.dart';
import 'package:easy_alert/easy_alert.dart';
import '../dto/word.dart';
import './sign.dart';
import '../store/learned.dart';
import './articles.dart';
import '../store/articles.dart';

class ArticlePage extends StatefulWidget {
  ArticlePage({Key key}) : super(key: key);

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  String title = '';
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
    bus.on("get_article_done", (arg) {
      setState(() {
        _words = arg.map((d) => Word.fromJson(d)).toList();
      });
    });

    bus.on("analysis_done", (arg) {
      // 重新取列表
      getArticleTitles();
      //渲染字体
      setState(() {
        _words = arg.map((d) => Word.fromJson(d)).toList();
      });
    });
    // 显示单词级别
    bus.on("word_clicked", (arg) {
      Alert.toast(context, arg.toString(),
          position: ToastPosition.bottom, duration: ToastDuration.short);
    });
    bus.on("learned", (d) {
      String info;
      if (d.learned) {
        info = d.text + "已经学会";
      } else {
        info = "重新学习" + d.text;
      }
      Alert.toast(context, info,
          position: ToastPosition.bottom, duration: ToastDuration.long);
    });
    // postArticle();
  }

// 设置当前文章的所有单词为正确状态
  _setAllWordLearned(String word, bool learned) {
    print("_setAllWordLearned");
    _words.forEach((d) {
      print(word + "=" + d.text);
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

    if (_noNeedBlank.contains(word)) blank = "";
    return TextSpan(text: blank, children: [
      TextSpan(
          text: (word.text == "\n")
              ? word.text + "   "
              : word.text, // 如果换行了, 下一行加上3个空格, 保证缩进
          style: (this._tapedText == word.text)
              ? TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)
              : TextStyle(color: Colors.grey[600]),
          recognizer: MultiTapGestureRecognizer()
            ..onTapCancel = (i) {
              setState(() {
                this._tapedText = '';
              });
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
            }
            ..onTap = (i) {
              if (word.level != 0) {
                bus.emit('word_clicked', word.level);
              }
              ClipboardManager.copyToClipBoard(word.text);
            })
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

  MultiTapGestureRecognizer _getTapRecognizer(Word word) {
    bool longTap = false; // 标记是否长按, 长按不要触发单词查询
    return MultiTapGestureRecognizer()
      ..longTapDelay = Duration(milliseconds: 500)
      ..onLongTapDown = (i, detail) {
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
        if (!longTap) {
          // 避免长按的同时触发
          bus.emit('word_clicked', word.level);
          ClipboardManager.copyToClipBoard(word.text);
          putLearn(word.text);
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
        title: Text('这里放返回的文章列表'),
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
            text: '   ', // 第一句的空格
            style: TextStyle(color: Colors.black87, fontSize: 20),
            children: _words.map((d) {
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
    );
  }
}
