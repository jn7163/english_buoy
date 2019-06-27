import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provide/provide.dart';
import 'package:flutter/material.dart';
import '../bus.dart';
import '../store/learned.dart';
import '../models/article_titles.dart';
import '../models/article.dart';
import '../models/articles.dart';
import '../models/word.dart';
import '../components/oauth_info.dart';

@immutable
class ArticlePage extends StatefulWidget {
  ArticlePage({Key key, this.id}) : super(key: key);
  // ArticlePage({this.id});
  final int id;
  // final List articleTitles;

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  // 监听滚动事件
  // 单引号开头的, 前面不要留空白
  //RegExp _noNeedExp = new RegExp(r"^'");
  // 这些符号前面不要加空格
  List _noNeedBlank = [
    "'ll",
    "'s",
    "'re",
    "'m",
    "'d",
    "'ve",
    "n't",
    ".",
    "!",
    ",",
    ":",
    "?",
    "?",
    "…",
  ];
  List _noNeedLearn = ["[", "]"];

  // 后台返回的文章结构
  String _tapedText = ''; // 当前点击的文本
  String _lastTapedText = ''; // 上次点击的文本
  Article _article;
  ScrollController _controller;
  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    Future.delayed(Duration.zero, () {
      loadArticleByID();
    });
  }

  @override
  void dispose() {
    //为了避免内存泄露，需要调用_controller.dispose
    _controller.dispose();
    super.dispose();
  }

  loadArticleByID() {
    if (_article != null) return;
    var articles = Provide.value<Articles>(context);
    setState(() {
      // print("loadArticleByID");
      _article = articles.articles[widget.id];
    });
    if (_article == null) {
      var article = Article();
      article.getArticleByID(widget.id).then((d) {
        articles.set(article);
        setState(() {
          _article = article;
        });
      });
    }
  }

// 根据规则, 判断单词前是否需要添加空白
  String _getBlank(String text) {
    String blank = " ";
    //if (_noNeedExp.hasMatch(text)) blank = "";
    if (_noNeedBlank.contains(text)) blank = "";
    return blank;
  }

  bool isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

// 定义应该的 style
  TextStyle _defineStyle(Word word, ArticleTitles articleTitles) {
    TextStyle textStyle = TextStyle();
    bool needLearn = (word.level != null && word.level != 0); // 是否需要掌握
    bool inArticleTitles = articleTitles.setArticleTitles
        .contains(word.text.toLowerCase()); // 是否添加
    bool isSelected =
        (_tapedText.toLowerCase() == word.text.toLowerCase()); // 是否选中

    // 需要学习teal, 否则 blueGrep
    textStyle = needLearn
        ? textStyle.copyWith(color: Colors.teal[700])
        : textStyle.copyWith(color: Colors.blueGrey);
    // 已添加
    if (inArticleTitles) {
      //无需掌握的添加单词为淡绿色
      if (!needLearn) textStyle = textStyle.copyWith(color: Colors.teal[400]);
      textStyle = textStyle.copyWith(
        decoration: TextDecoration.underline,
        decorationStyle: TextDecorationStyle.dotted,
      );
    }

    // 如果是数字, 统一当做已经学会
    if (isNumeric(word.text)) word.learned = true;
    // 标点符号也不用学习
    if (this._noNeedBlank.contains(word.text)) word.learned = true;

    // 已经学会, 不用任何样式, 继承原本就可以
    // 一旦选中, 还原本来的样式
    if (word.learned == true && !isSelected) textStyle = TextStyle();
    // 长按选中 显示波浪下划线
    if (isSelected)
      textStyle = textStyle.copyWith(
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.wavy);

    return textStyle;
  }

// 组装为需要的 textSpan
  TextSpan _getTextSpan(Word word, ArticleTitles articles, Article article) {
    var wordStyle = _defineStyle(word, articles); // 文字样式

    TextSpan subscript = TextSpan(); // 显示该单词查询次数的下标
    if (word.learned == false &&
        !_noNeedLearn.contains(word.text) &&
        !isNumeric(word.text) &&
        word.count != 0) {
      subscript = TextSpan(
          text: word.count.toString(),
          style: wordStyle.copyWith(fontSize: 12)); // 数字样式和原本保持一致, 只是变小
    }

    return TextSpan(text: _getBlank(word.text), children: [
      TextSpan(
          text: word.text,
          style: wordStyle,
          recognizer: _getTapRecognizer(word, article)),
      subscript,
    ]);
  }

// 定义各种 tap 后的处理
// isNoNeed 是不需要学习的
  MultiTapGestureRecognizer _getTapRecognizer(
    Word word,
    Article article,
  ) {
    if (word.text == "") return null;
    bool longTap = false; // 标记是否长按, 长按不要触发单词查询
    return MultiTapGestureRecognizer()
      ..longTapDelay = Duration(milliseconds: 200)
      ..onLongTapDown = (i, detail) {
        longTap = true;
        // print("onLongTapDown");
        setState(() {
          word.learned = !word.learned;
        });
        article.putLearned(word).then((d) {
          var articleTitles = Provide.value<ArticleTitles>(context);

          articleTitles.syncServer();
        });
      }
      ..onTap = (i) {
        // 避免长按的同时触发
        if (!longTap) {
          setState(() {
            _tapedText = word.text;
          });
          Future.delayed(Duration(milliseconds: 800), () {
            setState(() {
              _tapedText = '';
            });
            // print("_scrolling = false");
          });
          // 无需学的, 没必要显示级别
          if (word.level != 0) bus.emit('pop_show', word.level.toString());
          putLearn(word.text);
          Clipboard.setData(ClipboardData(text: word.text));
          // 一个点击一个单词两次, 那么尝试跳转到这个单词列表
          // 已经在这个单词页, 就不要跳转了
          if (_lastTapedText.toLowerCase() == word.text.toLowerCase() &&
              word.text.toLowerCase() != article.title.toLowerCase()) {
            int id = _getIDByTitle(word.text);
            if (id != 0) {
              // toArticle(context, id);
              Navigator.pushNamed(context, '/Article', arguments: id);
            }
          } else {
            _lastTapedText = word.text;
          }
        }
      };
    /*
      ..onTapCancel = (i) {
        // if (_scrolling) return;
        //setState(() {
        // this._tapedText = '';
        //});
      }
      ..onTapDown = (i, d) {
        //if (_scrolling) return;
        //setState(() {
        print("onTapDown setState");
        // _tapedText = word.text;
        //});
      }
      ..onTapUp = (i, d) {
        // if (_scrolling) return;
        // setState(() {
        print("onTapUp setState");
        // _tapedText = '';
        // });
      };
      */
  }

  int _getIDByTitle(String title) {
    var articles = Provide.value<ArticleTitles>(context);
    var titles = articles.articles
        .where((d) => d.title.toLowerCase() == title.toLowerCase())
        .toList();
    if (titles.length > 0) {
      return titles[0].id;
    }
    return 0;
  }

  Widget _wrapLoading() {
    TextStyle textStyle = TextStyle(
        color: Colors.black, fontSize: 20, fontFamily: "NotoSans-Medium");
    if (_article != null) {
      return SingleChildScrollView(
        controller: _controller,
        // physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 10.0, left: 10.0, bottom: 10, right: 10),
        child: Provide<ArticleTitles>(builder: (context, child, articleTitles) {
          if (articleTitles.articles.length != 0) {
            return RichText(
              text: TextSpan(
                text: '',
                style: textStyle,
                children: _article.words.map((d) {
                  return _getTextSpan(d, articleTitles, _article);
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.list),
          tooltip: 'go to articles',
          onPressed: () {
            Navigator.pushNamed(context, '/Articles');
          },
        ),
        title: (_article != null) ? Text(_article.title) : Text("loading..."),
        actions: <Widget>[
          OauthInfoWidget(),
        ],
      ),
      body: _wrapLoading(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/AddArticle');
        },
        tooltip: 'add article',
        child: Icon(Icons.add),
      ),
    );
  }
}
