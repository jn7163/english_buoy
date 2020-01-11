import 'dart:async';

import 'package:ebuoy/components/article_sentences.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../components/article_top_bar.dart';
import '../components/not_mastered_vocabularies.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../models/article_titles.dart';
import '../models/article.dart';
import '../models/article_status.dart';
import '../models/setting.dart';
import '../themes/bright.dart';

@immutable
class ArticlePage extends StatefulWidget {
  ArticlePage({Key key, this.initID}) : super(key: key);

  final int initID;

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  // 后台返回的文章结构
  Article _article;
  Article articleTmp = Article();
  ScrollController _controller;
  ArticleStatus articleStatus;
  ArticleTitles articleTitles;
  int id, lastID, nextID;

  @override
  void initState() {
    super.initState();
    id = widget.initID;
    _controller = ScrollController();
    Future.delayed(Duration.zero, () {
      articleStatus = Provider.of<ArticleStatus>(context, listen: false);
      articleTitles = Provider.of<ArticleTitles>(context, listen: false);
      loadByID();
    });
  }

  loadByID() {
    var a = articleTitles.findLastNextArticleByID(id);
    lastID = a[0];
    nextID = a[1];
    loadArticleByID();
  }

  @override
  void deactivate() {
    // This pauses video while navigating to next page.
    if (articleStatus.youtubeController != null) articleStatus.youtubeController.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    //为了避免内存泄露，需要调用_controller.dispose
    _controller.dispose();
    super.dispose();
  }

  Future loadFromServer(int id) async {
    return articleTmp.getArticleByID(context, id).then((d) {
      if (this.mounted) {
        setState(() {
          _article = articleTmp;
        });

        // 更新本地未学单词数
        articleTitles.setUnlearnedCountByArticleID(_article.unlearnedCount, _article.articleID);
      }
      return d;
    });
  }

  Future loadArticleByID() async {
    // from local cache
    articleTmp.getFromLocal(id).then((hasLocal) {
      setState(() {
        if (hasLocal) _article = articleTmp;
      });
    });

    // always update from server
    return await loadFromServer(id);
  }

  GestureDetector getRefresh() {
    return GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity < -800) {
            if (nextID != null) {
              id = nextID;
              articleTitles.setSelectedArticleID(id);
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => ArticlePage(initID: id)));
            }
          }
          if (details.primaryVelocity > 800) {
            if (lastID != null) {
              id = lastID;
              articleTitles.setSelectedArticleID(id);
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => ArticlePage(initID: id)));
            }
          }
          // Navigator.pushNamed(context, '/Article', arguments: d.id);
        },
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: articleBody(),
          color: mainColor,
        ));
  }

  Widget getWrapLoading() {
    return ModalProgressHUD(
        child: Column(children: [getYouTube(), Expanded(child: getRefresh())]),
        inAsyncCall: _article == null);
  }

  Widget articleBody() {
    return _article != null
        ? SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _controller,
            child: Column(children: [
              ArticleTopBar(article: _article),
              Padding(
                  padding: EdgeInsets.only(top: 0, left: 0, bottom: 0, right: 0),
                  child: NotMasteredVocabulary(article: _article)),
              Padding(
                  padding: EdgeInsets.only(top: 5.0, left: 5.0, bottom: 5, right: 5),
                  child: ArticleSentences(article: _article, sentences: _article.sentences)),
              Padding(
                  padding: EdgeInsets.only(top: 0, left: 0, bottom: 0, right: 0),
                  child: NotMasteredVocabulary(article: _article)),
            ]))
        : Container();
  }

  Widget getYouTube() {
    return _article == null || _article.youtube == ''
        ? Container()
        : Container(
            color: Colors.black,
            padding: EdgeInsets.only(top: 24),
            child: Consumer<Setting>(builder: (context, setting, child) {
              print(setting.isAutoplay);
              return YoutubePlayer(
                onPlayerInitialized: (controller) => articleStatus.setYouTube(controller),
                context: context,
                videoId: YoutubePlayer.convertUrlToId(_article.youtube),
                flags: YoutubePlayerFlags(
                  //自动播放
                  autoPlay: setting.isAutoplay,
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
              );
            }));
  }

  Future _refresh() async {
    await loadFromServer(id);
    return;
  }

  @override
  Widget build(BuildContext context) {
    print("build article");
    return Scaffold(
      body: getWrapLoading(),
      /*
        floatingActionButton: LaunchYoutubeButton(
          youtubeURL: _article == null ? '' : _article.youtube,
        )
        */
    );
  }
}
