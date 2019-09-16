import 'dart:async';

import 'package:ebuoy/components/article_richtext.dart';
import 'package:ebuoy/components/launch_youbube_button.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../components/article_top_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../models/article_titles.dart';
import '../models/article.dart';
import '../models/article_status.dart';
import '../models/articles.dart';

@immutable
class ArticlePage extends StatefulWidget {
  ArticlePage({Key key, this.id}) : super(key: key);

  final int id;

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  // 后台返回的文章结构
  Article _article;
  ScrollController _controller;
  ArticleStatus articleStatus;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    Future.delayed(Duration.zero, () {
      articleStatus = Provider.of<ArticleStatus>(context, listen: false);
      loadArticleByID();
    });
  }

  @override
  void deactivate() {
    // This pauses video while navigating to next page.
    articleStatus.youtubeController.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    //为了避免内存泄露，需要调用_controller.dispose
    _controller.dispose();
    super.dispose();
  }

  loadArticleByID() {
    if (_article != null) return;
    var articles = Provider.of<Articles>(context, listen: false);
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
        var articleTitles = Provider.of<ArticleTitles>(context, listen: false);
        articleTitles.setUnlearnedCountByArticleID(article.unlearnedCount, article.articleID);
      });
    }
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
                  return Column(
                      children: _article.splitWords.map((d) {
                    return ArticleRichText(article: _article, words: d);
                  }).toList());
                }
                return Text('some error!');
              }))
        ]));
  }

  Widget getYouTube() {
    return _article == null || _article.youtube == ''
        ? Container()
        : Container(
            color: Colors.black,
            padding: EdgeInsets.only(top: 24),
            child: YoutubePlayer(
              onPlayerInitialized: (controller) => articleStatus.setYouTube(controller),
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
                forceHideAnnotation: false,
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
    print("build article");
    return Scaffold(
        body: getWrapLoading(),
        floatingActionButton: LaunchYoutubeButton(
          youtubeURL: _article == null ? '' : _article.youtube,
        ));
  }
}
