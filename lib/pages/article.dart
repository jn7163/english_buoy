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
  // 单引号开头的, 前面不要留空白
  RegExp _noNeedExp = new RegExp(r"^'");
  // 这些符号前面不要加空格
  List _noNeedBlank = [".", "!", "'", ",", ":", '"', "?", "n't"];

  // 后台返回的文章结构
  String _tapedText = ''; // 当前点击的文本
  String _lastTapedText = ''; // 上次点击的文本
  Article _article;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      loadArticleByID();
    });
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
    if (_noNeedExp.hasMatch(text)) blank = "";
    if (_noNeedBlank.contains(text)) blank = "";
    return blank;
  }

// 定义应该的 style
  TextStyle _defineStyle(Word word, ArticleTitles articleTitles) {
    TextStyle textStyle = TextStyle();
    // 需要学习
    // if (d.level != null && d.level > 0 && d.level < 1000) {
    if (word.level != null && word.level != 0) {
      textStyle = textStyle.copyWith(color: Colors.teal[700]);
    } else {
      // 无需学习的单词
      textStyle = textStyle.copyWith(color: Colors.blueGrey);
    }
    // 存在已经添加的单词标题列表中, 无论是不是需要学习的单词, 都高亮淡绿色
    if (articleTitles.setArticleTitles.contains(word.text.toLowerCase())) {
      textStyle = textStyle.copyWith(color: Colors.teal[400]);
    }
    // 长按选中
    if (_tapedText.toLowerCase() == word.text.toLowerCase()) {
      textStyle = textStyle.copyWith(fontWeight: FontWeight.bold);
    }
    // 已经学会用黑色
    if (word.learned == true) {
      textStyle = textStyle.copyWith(color: Colors.black);
    }
    return textStyle;
  }

// 需要学习的单词
  TextSpan _getNeedLearnTextSpan(
      Word word, ArticleTitles articles, Article article) {
    return TextSpan(text: _getBlank(word.text), children: [
      TextSpan(
          text: word.text,
          style: _defineStyle(word, articles),
          recognizer: _getTapRecognizer(word, article))
    ]);
  }

// 定义各种 tap 后的处理
// isNoNeed 是不需要学习的
  MultiTapGestureRecognizer _getTapRecognizer(
    Word word,
    Article article,
  ) {
    bool longTap = false; // 标记是否长按, 长按不要触发单词查询
    return MultiTapGestureRecognizer()
      ..longTapDelay = Duration(milliseconds: 500)
      ..onLongTapDown = (i, detail) {
        longTap = true;
        // print("onLongTapDown");
        word.learned = !word.learned;
        article.putLearned(word).then((d) {
          var articleTitles = Provide.value<ArticleTitles>(context);
          articleTitles.syncServer();
        });
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
          bus.emit('pop_show', word.level.toString());
          putLearn(word.text);
          Clipboard.setData(ClipboardData(text: word.text));
          // 一个点击一个单词两次, 那么尝试跳转到这个单词列表
          // 已经在这个单词也, 就不要跳转了
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
    if (_article != null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 10.0, left: 10.0, bottom: 10, right: 10),
        child: Column(children: [
          Provide<ArticleTitles>(builder: (context, child, articles) {
            if (articles.articles.length != 0) {
              return RichText(
                text: TextSpan(
                  text: '',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: "NotoSans-Medium"),
                  children: _article.words.map((d) {
                    return _getNeedLearnTextSpan(d, articles, _article);
                  }).toList(),
                ),
              );
            }
            return Text('some error!');
          }),
          /*
          Image.network(
            'https://follow.bigzhu.net/medias/natgeo/instagram/58684976_2120196621599783_7845444018273837766_n.jpg',
          )
          */
        ]),
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
