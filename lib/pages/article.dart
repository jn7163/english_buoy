import 'package:flutter/gestures.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provide/provide.dart';
import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flutter/material.dart';
import '../bus.dart';
import '../dto/word.dart';
import './sign.dart';
import '../store/learned.dart';
import './articles.dart';
import '../store/article.dart';
import './add_article.dart';
import '../models/articles.dart';

@immutable
class ArticlePage extends StatefulWidget {
  ArticlePage({Key key, this.articleID}) : super(key: key);
  final int articleID;
  // final List articleTitles;

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  // Set _setArticleTitles;
  String _title = "loading...";
  List _words = [];
  // 单引号开头的, 前面不要留空白
  RegExp _noNeedExp = new RegExp(r"^'");
  // 这些符号前面不要加空格
  List _noNeedBlank = [".", "!", "'", ",", ":", '"', "?", "n't"];

  // 后台返回的文章结构
  String _tapedText = ''; // 当前点击的文本
  String _lastTapedText = ''; // 上次点击的文本
  initState() {
    super.initState();
    // 把 articleTitles 的 title 组合成 set
    // _setArticleTitles = widget.articleTitles.map((d) => d['title']).toSet();
    getArticleByID(widget.articleID).then((data) {
      setState(() {
        _title = data['title'];
        _words = data['words'].map((d) => Word.fromJson(d)).toList();
      });
      _putUnlearnedCount();
    });
  }

  _putUnlearnedCount() async {
    // 重新计算未掌握单词数
    int unlearnedCount = _words
        .map((d) {
          if (d.level > 0 && !d.learned) {
            return d.text;
          }
        })
        .toSet()
        .length;
    unlearnedCount--;
    // 设置了掌握数以后, 列表也要重新获取的
    putUnlearnedCount(widget.articleID, unlearnedCount).then((d) {
      var articles = Provide.value<Articles>(context);
      articles.syncServer();
    });
  }

  void _toAddArticle() {
    //添加文章
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddArticlePage();
    }));
  }

// 设置当前文章的所有单词为正确状态
  _setAllWordLearned(String word, bool learned) {
    print("_setAllWordLearned");
    _words.forEach((d) {
      if (d.text.toLowerCase() == word) {
        setState(() {
          d.learned = learned;
        });
      }
    });
  }

// 根据规则, 判断单词前是否需要添加空白
  String _getBlank(String text) {
    String blank = " ";
    if (_noNeedExp.hasMatch(text)) blank = "";
    if (_noNeedBlank.contains(text)) blank = "";
    return blank;
  }

// 无需学习的单词
  TextSpan _getNoNeedLearnTextSpan(Word word) {
    return TextSpan(text: _getBlank(word.text.toLowerCase()), children: [
      TextSpan(
          text: word.text,
          style: (this._tapedText.toLowerCase() == word.text.toLowerCase())
              ? TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)
              : TextStyle(color: Colors.grey[600]),
          recognizer: _getTapRecognizer(word, true))
    ]);
  }

// 需要学习的单词
  TextSpan _getNeedLearnTextSpan(Word word, Articles articles) {
    return TextSpan(text: _getBlank(word.text), children: [
      TextSpan(
          text: word.text,
          style: (_tapedText.toLowerCase() == word.text.toLowerCase())
              ? ((articles.setArticleTitles.contains(word.text.toLowerCase()))
                  ? TextStyle(
                      color: Colors.teal[400], fontWeight: FontWeight.bold)
                  : TextStyle(
                      color: Colors.teal[700], fontWeight: FontWeight.bold))
              : ((articles.setArticleTitles.contains(word.text.toLowerCase()))
                  ? TextStyle(color: Colors.teal[400])
                  : TextStyle(color: Colors.teal[700])),
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
        putLearned(word.text, word.learned).then((d) {
          print("putLearned then");
          String info;
          if (word.learned) {
            info = word.text + " 已经学会";
          } else {
            info = "重新学习 " + word.text;
          }
          bus.emit('pop_show', info);
          _putUnlearnedCount();
        });
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
            bus.emit('pop_show', word.level.toString());
            putLearn(word.text);
          }
          ClipboardManager.copyToClipBoard(word.text);
          // 一个点击一个单词两次, 那么尝试跳转到这个单词列表
          if (_lastTapedText.toLowerCase() == word.text.toLowerCase()) {
            // 跳转时候要用小写
            _tryJumpTo(word.text.toLowerCase());
          } else {
            _lastTapedText = word.text;
          }
        }
      }
      ..onTapDown = (i, d) {
        setState(() {
          _tapedText = word.text;
        });
      }
      ..onTapUp = (i, d) {
        setState(() {
          _tapedText = '';
        });
      };
  }

  int _getIDByTitle(String title) {
    var articles = Provide.value<Articles>(context);
    var titles = articles.articles.where((d) => d.title == title).toList();
    if (titles.length > 0) {
      return titles[0].id;
    }
    return 0;
  }

  void _tryJumpTo(String text) {
    int id = _getIDByTitle(text);

    if (id != 0) {
      //导航到文章详情
      Navigator.push(
          context,
          MaterialPageRoute(
              maintainState: false, // 每次都新建一个详情页
              builder: (context) {
                return ArticlePage(articleID: id);
              }));
    }
  }

// 已经学会的单词
  TextSpan _getLearnedTextSpan(Word word) {
    return TextSpan(text: _getBlank(word.text), children: [
      TextSpan(
        text: word.text,
        style: (this._tapedText.toLowerCase() == word.text.toLowerCase())
            ? TextStyle(fontWeight: FontWeight.bold)
            : TextStyle(),
        recognizer: _getTapRecognizer(word),
      )
    ]);
  }

  void _toSignPage() {
    //导航到新路由
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SignInPage();
    }));
  }

  void _toArticlesPage() {
    //导航文章列表
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ArticlesPage();
    }));
  }

  Widget _wrapLoading() {
    if (_words.length != 0) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 10.0, left: 10.0, bottom: 10, right: 10),
        child: Provide<Articles>(builder: (context, child, articles) {
          if (articles.articles.length != 0) {
            return RichText(
              text: TextSpan(
                text: '',
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
                    return _getNeedLearnTextSpan(d, articles);
                  } else {
                    return _getNoNeedLearnTextSpan(d);
                  }
                }).toList(),
              ),
            );
          }
          return Text('some error!');
        }),
      );
    }
    return SpinKitChasingDots(
      color: Colors.blueGrey,
      size: 50.0,
    );
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
      body: _wrapLoading(),
      floatingActionButton: FloatingActionButton(
        onPressed: _toAddArticle,
        tooltip: 'add article',
        child: Icon(Icons.add),
      ),
    );
  }
}
