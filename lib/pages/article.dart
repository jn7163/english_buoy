import 'dart:async';

import 'package:ebuoy/components/launch_youbube_button.dart';
import 'package:easy_alert/easy_alert.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../components/article_top_bar.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../models/article_titles.dart';
import '../models/article.dart';
import '../models/articles.dart';
import '../models/word.dart';
import '../models/setting.dart';

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

  // 后台返回的文章结构
  String _tapedText = ''; // 当前点击的文本
  String _lastTapedText = ''; // 上次点击的文本
  Article _article;
  ScrollController _controller;
  Setting _setting;
  bool _isWrap = false; // 当前字符是否换行符
  RegExp _startExp = new RegExp(r"00[0-9]+.[0-9]+00");
  YoutubePlayerController _youtubeController = YoutubePlayerController();

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    Future.delayed(Duration.zero, () {
      _setting = Provider.of<Setting>(context);
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
    var articles = Provider.of<Articles>(context);
    setState(() {
      _article = articles.articles[widget.id];
    });
    if (_article == null) {
      var article = Article();
      article.getArticleByID(context, widget.id).then((d) {
        articles.set(article);
        setState(() {
          _article = article;
        });
        // 更新本地未学单词数
        var articleTitles = Provider.of<ArticleTitles>(context);
        articleTitles.setUnlearnedCountByArticleID(article.unlearnedCount, article.articleID);
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

  // 字符串是否包含字母
  bool hasLetter(String str) {
    RegExp regHasLetter = new RegExp(r"[a-zA-Z]+");
    return regHasLetter.hasMatch(str);
  }

// 定义应该的 style
  TextStyle _defineStyle(Word word, ArticleTitles articleTitles) {
    bool needLearn = (word.level != null && word.level != 0); // 是否需要掌握
    bool inArticleTitles = articleTitles.setArticleTitles.contains(word.text.toLowerCase()); // 是否添加
    bool isSelected = (_tapedText.toLowerCase() == word.text.toLowerCase()); // 是否选中

    // 默认的文字样式
    TextStyle defaultTextStyle = Theme.of(context).textTheme.display3;
    // 必学的高亮色
    TextStyle needLearnTextStyle = Theme.of(context).textTheme.display1;
    // 非必学的高亮色
    TextStyle noNeedLearnTextStyle = Theme.of(context).textTheme.display2;
    //根据条件逐步加工修改的样式
    TextStyle processTextStyle = defaultTextStyle;

    // 如果是词中没有字母, 默认样式
    if (!hasLetter(word.text)) return defaultTextStyle;
    // 无需前置空格的单词, 默认样式
    if (this._noNeedBlank.contains(word.text)) return defaultTextStyle;
    // 已经学会且没有选中, 不用任何修改
    if (word.learned == true && !isSelected) return defaultTextStyle;

    // 是否必学
    processTextStyle = needLearn ? needLearnTextStyle : noNeedLearnTextStyle;
    // 单词作为文章标题添加
    if (inArticleTitles) {
      //无需掌握的添加单词高亮为需要学习的颜色
      processTextStyle = needLearnTextStyle.copyWith(
        //添加下划线区分
        decoration: TextDecoration.underline,
        decorationStyle: TextDecorationStyle.dotted,
      );
    }
    // 一旦选中, 还原本来的样式
    // 长按选中 显示波浪下划线
    if (isSelected)
      processTextStyle = processTextStyle.copyWith(
          decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.wavy);

    return processTextStyle;
  }

  // 生成修改播放位置的图标
  TextSpan getSeekTextSpan(String time) {
    Duration seekTime = Duration(
      milliseconds: (double.parse(time) * 1000).round(),
    );
    TextStyle style = Theme.of(context).textTheme.display2.copyWith(fontSize: 20);
    MultiTapGestureRecognizer recognizer = MultiTapGestureRecognizer()
      ..onTap = (i) {
        _youtubeController.seekTo(seekTime);
        /*
        setState(() {
          style = style.copyWith(fontSize: 20);
          print(time);
        });
         */
      };
    return TextSpan(text: "▷", style: style, recognizer: recognizer);
  }

// 组装为需要的 textSpan
  TextSpan getTextSpan(Word word, ArticleTitles articles, Article article) {
    if (word.text == "\n") {
      _isWrap = true;
    } else {
      // 是时间格式的字符
      if (_startExp.hasMatch(word.text)) {
        if (_isWrap) {
          // 增加神奇的点击事件, 调整 youtube 视频
          _isWrap = false;
          return getSeekTextSpan(word.text);
        } else {
          // 返回空白, 不要显示
          return TextSpan(text: "");
        }
      }
      _isWrap = false;
    }
    var wordStyle = _defineStyle(word, articles); // 文字样式

    TextSpan subscript = TextSpan(); // 显示该单词查询次数的下标
    if (word.learned == false && hasLetter(word.text) && word.count != 0) {
      subscript = TextSpan(
          text: word.count.toString(),
          style: wordStyle.copyWith(fontSize: 12)); // 数字样式和原本保持一致, 只是变小
    }

    return TextSpan(text: _getBlank(word.text), children: [
      TextSpan(text: word.text, style: wordStyle, recognizer: _getTapRecognizer(word, article)),
      subscript,
      word.text == "\n" ? TextSpan(text: "   ") : TextSpan(text: ""), //新的一行空3个空格, 和单词原本的前空格凑成4个
    ]);
  }

// 定义各种 tap 后的处理
// isNoNeed 是不需要学习的
  MultiTapGestureRecognizer _getTapRecognizer(
    Word word,
    Article article,
  ) {
    if (word.text == "") return null;
    // 标记是否长按, 长按不要触发单词查询
    bool longTap = false;
    return MultiTapGestureRecognizer()
      ..longTapDelay = Duration(milliseconds: 400)
      ..onLongTapDown = (i, detail) {
        longTap = true;
        // 因为 setState 导致整个 RichText 重新渲染, 文章大时必然导致卡顿
        setState(() {
          word.learned = !word.learned;
        });
        article.putLearned(context, word).then((d) {
          //重新计算文章未掌握单词数
          var articleTitles = Provider.of<ArticleTitles>(context);
          articleTitles.setUnlearnedCountByArticleID(article.unlearnedCount, article.articleID);
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
          });
          // 无需学的, 没必要显示级别
          if (word.level != 0)
            Alert.toast(context, word.level.toString(),
                position: ToastPosition.bottom, duration: ToastDuration.long);
          // 实时增加次数的效果
          article.increaseLearnCount(word.text);
          // 记录学习次数
          word.putLearn(context);
          debugPrint(word.text);
          Clipboard.setData(ClipboardData(text: word.text));
          // 一个点击一个单词两次, 那么尝试跳转到这个单词列表
          // 已经在这个单词页, 就不要跳转了
          if (_lastTapedText.toLowerCase() == word.text.toLowerCase() &&
              word.text.toLowerCase() != article.title.toLowerCase() &&
              _setting.isJump) {
            int id = _getIDByTitle(word.text);
            if (id != 0) {
              Navigator.pushNamed(context, '/Article', arguments: id);
            }
          } else {
            _lastTapedText = word.text;
          }
        }
      };
  }

  int _getIDByTitle(String title) {
    var articles = Provider.of<ArticleTitles>(context);
    var titles =
        articles.articleTitles.where((d) => d.title.toLowerCase() == title.toLowerCase()).toList();
    if (titles.length > 0) {
      return titles[0].id;
    }
    return 0;
  }

  Widget getWrapLoading() {
    return ModalProgressHUD(
        child: _article == null
            ? Container() //这里可以搞一个动画或者什么效果
            : Stack(children: [getScrollView(), getYouTube()]),
        inAsyncCall: _article == null);
  }

  Widget getScrollView() {
    return SingleChildScrollView(
        controller: _controller,
        child: Column(children: [
          ArticleTopBar(article: _article),
          Padding(
              padding: EdgeInsets.only(top: 15.0, left: 5.0, bottom: 5, right: 5),
              child: Consumer<ArticleTitles>(builder: (context, articleTitles, _) {
                if (articleTitles.articleTitles.length != 0) {
                  return RichText(
                    text: TextSpan(
                      text: '   ',
                      style: Theme.of(context).textTheme.display3, // 没有这个样式,会导致单词点击时错位
                      children: _article.words.map((d) {
                        return getTextSpan(d, articleTitles, _article);
                      }).toList(),
                    ),
                  );
                }
                return Text('some error!');
              })),
        ]));
  }

  Widget getYouTube() {
    return _article == null || _article.youtube == ''
        ? Container()
        : Container(
            color: Colors.black,
            padding: EdgeInsets.only(top: 24),
            child: YoutubePlayer(
              onPlayerInitialized: (controller) => _youtubeController = controller,
              context: context,
              videoId: YoutubePlayer.convertUrlToId(_article.youtube),
              flags: YoutubePlayerFlags(
                //不要自动播放
                autoPlay: false,
                // 下半部分小小的进度条
                showVideoProgressIndicator: true,
                // 允许全屏
                hideFullScreenButton: false,
                // 不可能是 live 的视频
                isLive: false,
                forceHideAnnotation: true,
              ),
              videoProgressIndicatorColor: Colors.teal,
              liveUIColor: Colors.teal,
              progressColors: ProgressColors(
                playedColor: Colors.teal,
                handleColor: Colors.tealAccent,
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: getWrapLoading(),
        floatingActionButton: LaunchYoutubeButton(
          youtubeURL: _article == null ? '' : _article.youtube,
        ));
  }
}
