import 'package:flutter/gestures.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provide/provide.dart';
import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flutter/material.dart';
import '../bus.dart';
// import '../dto/word.dart';
import './sign.dart';
import '../store/learned.dart';
import './articles.dart';
import './add_article.dart';
import '../models/articles.dart';
import '../models/article.dart';
import '../models/word.dart';

@immutable
class ArticlePage extends StatefulWidget {
  ArticlePage({Key key, this.articleID}) : super(key: key);
  final int articleID;
  // final List articleTitles;

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  // 单引号开头的, 前面不要留空白
  RegExp _noNeedExp = new RegExp(r"^'");
  // 这些符号前面不要加空格
  List _noNeedBlank = [".", "!", "'", ",", ":", '"', "?", "n't"];

  // 后台返回的文章结构
  String _tapedText = ''; // 当前点击的文本
  String _lastTapedText = ''; // 上次点击的文本
  //initState() {
  //  super.initState();
  //
  //  getArticleByID(widget.articleID).then((data) {
  //    setState(() {
  //      _words = data['words'].map((d) => Word.fromJson(d)).toList();
  //    });
  //    _putUnlearnedCount();
  //  });
  //}

  void _toAddArticle() {
    //添加文章
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddArticlePage();
    }));
  }

// 根据规则, 判断单词前是否需要添加空白
  String _getBlank(String text) {
    String blank = " ";
    if (_noNeedExp.hasMatch(text)) blank = "";
    if (_noNeedBlank.contains(text)) blank = "";
    return blank;
  }

// 无需学习的单词
  TextSpan _getNoNeedLearnTextSpan(Word word, Article article) {
    return TextSpan(text: _getBlank(word.text.toLowerCase()), children: [
      TextSpan(
          text: word.text,
          style: (this._tapedText.toLowerCase() == word.text.toLowerCase())
              ? TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)
              : TextStyle(color: Colors.grey[600]),
          recognizer: _getTapRecognizer(word, article, true))
    ]);
  }

// 需要学习的单词
  TextSpan _getNeedLearnTextSpan(
      Word word, Articles articles, Article article) {
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
          recognizer: _getTapRecognizer(word, article))
    ]);
  }

// 定义各种 tap 后的处理
// isNoNeed 是不需要学习的
  MultiTapGestureRecognizer _getTapRecognizer(Word word, Article article,
      [bool isNoNeedLearn = false]) {
    bool longTap = false; // 标记是否长按, 长按不要触发单词查询
    return MultiTapGestureRecognizer()
      ..longTapDelay = Duration(milliseconds: 500)
      ..onLongTapDown = (i, detail) {
        // 不学习的没必要设置学会与否
        if (isNoNeedLearn) return;
        longTap = true;
        print("onLongTapDown");
        word.learned = !word.learned;
        article.putLearned(word);
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
            int id = _getIDByTitle(word.text.toLowerCase());
            if (id != 0) {
              article.clear();
              article.getArticleByID(id);
            }
            // 跳转时候要用小写
            // _tryJumpTo(word.text.toLowerCase());
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
  TextSpan _getLearnedTextSpan(Word word, Article article) {
    return TextSpan(text: _getBlank(word.text), children: [
      TextSpan(
        text: word.text,
        style: (this._tapedText.toLowerCase() == word.text.toLowerCase())
            ? TextStyle(fontWeight: FontWeight.bold)
            : TextStyle(),
        recognizer: _getTapRecognizer(word, article),
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
    return Provide<Article>(builder: (context, child, article) {
      if (article.words.length != 0) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding:
              EdgeInsets.only(top: 10.0, left: 10.0, bottom: 10, right: 10),
          child: Provide<Articles>(builder: (context, child, articles) {
            if (articles.articles.length != 0) {
              return RichText(
                text: TextSpan(
                  text: '',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: "NotoSans-Medium"),
                  children: article.words.map((d) {
                    if (d.learned) {
                      return _getLearnedTextSpan(d, article);
                    }
                    // if (d.level != null && d.level > 0 && d.level < 1000) {
                    if (d.level != null && d.level != 0) {
                      return _getNeedLearnTextSpan(d, articles, article);
                    } else {
                      return _getNoNeedLearnTextSpan(d, article);
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.list),
          tooltip: 'go to articles',
          onPressed: _toArticlesPage,
        ),
        title: Provide<Article>(builder: (context, child, article) {
          if (article.title != null) return Text(article.title);
          return Text("loading...");
        }),
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
