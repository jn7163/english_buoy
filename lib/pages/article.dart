import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:page_transition/page_transition.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

import '../components/article_sentences.dart';
import '../components/article_top_bar.dart';
import '../components/not_mastered_vocabularies.dart';
import '../components/article_youtube.dart';
import '../components/article_floating_action_button.dart';
import '../models/article_titles.dart';
import '../models/article.dart';
import '../themes/base.dart';
import '../models/settings.dart';

@immutable
class ArticlePage extends StatefulWidget {
  ArticlePage({Key key, this.initID}) : super(key: key);

  final int initID;

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage>
    with AutomaticKeepAliveClientMixin<ArticlePage> {
  bool wantKeepAlive = true;
  Article article;
  ScrollController _scrollController;
  ArticleTitles articleTitles;
  Settings settings;
  int id, lastID, nextID;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    id = widget.initID;
    _scrollController = ScrollController();
    settings = Provider.of<Settings>(context, listen: false);
    //article = Provider.of<Article>(context, listen: false);
    article = Article();
    articleTitles = Provider.of<ArticleTitles>(context, listen: false);
    loadByID();
  }

  @override
  void updateKeepAlive() {
    print("!!!!!!!!!!!!!!!!!!!!!!!!updateKeepAlive");
    if (article.youtubeController != null) article.youtubeController.pause();
    super.updateKeepAlive();
  }

  @override
  void deactivate() {
    print("!!!!!!!!!!!!!!!!!!!!!!!!deactivate");
    // This pauses video while navigating to next page.
    if (article.youtubeController != null) article.youtubeController.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    //为了避免内存泄露，需要调用_controller.dispose
    _scrollController.dispose();
    super.dispose();
  }

  loadByID() {
    var a = articleTitles.findLastNextArticleByID(id);
    lastID = a[0];
    nextID = a[1];
    loadArticleByID();
  }

  Future loadFromServer({bool justUpdateLocal = false}) async {
    return article
        .getArticleByID(articleID: this.id, justUpdateLocal: justUpdateLocal)
        .then((d) {
      if (this.mounted) {
        // 更新本地未学单词数
        articleTitles.setUnlearnedCountByArticleID(
            article.unlearnedCount, article.articleID);
      }
      setState(() {
        loading = false;
      });
      return d;
    });
  }

  Future loadArticleByID() async {
    setState(() {
      loading = true;
    });
    article.getFromLocal(id).then((hasLocal) {
      if (!hasLocal) {
        return loadFromServer();
      } else {
        //如果缓存取到, 就不要更新页面内容, 避免后置更新导致页面跳变
        setState(() {
          loading = false;
        });
        return loadFromServer(justUpdateLocal: true);
      }
    });
  }

  refreshCurrentLeftToRight() {
    articleTitles.setSelectedArticleID(this.id); // 高亮列表
    //刷新当前页
    Navigator.pushReplacement(
        context,
        PageTransition(
          duration: Duration(milliseconds: 500),
          type: PageTransitionType.leftToRight,
          child: ArticlePage(initID: this.id),
        ));
  }

  refreshCurrentRightToLeft() {
    articleTitles.setSelectedArticleID(this.id); // 高亮列表
    //刷新当前页
    Navigator.pushReplacement(
      context,
      PageTransition(
        duration: Duration(milliseconds: 500),
        type: PageTransitionType.rightToLeft,
        child: ArticlePage(initID: this.id),
      ),
    );
  }

  Widget refreshBody() {
    return Expanded(
        child: RefreshIndicator(
      onRefresh: () async => await loadFromServer(),
      child: articleBody(),
      color: mainColor,
    ));
    /*
    return Expanded(
        child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity < -600) {
                if (nextID != null) {
                  this.id = nextID;
                  article.setNotMasteredWord(null);
                  this.refreshCurrentRightToLeft();
                }
              }
              if (details.primaryVelocity > 600) {
                if (lastID != null) {
                  this.id = lastID;
                  article.setNotMasteredWord(null);
                  this.refreshCurrentLeftToRight();
                }
              }
            },
            child: RefreshIndicator(
              onRefresh: () async => await loadFromServer(),
              child: articleBody(),
              color: mainColor,
            )));
            */
  }

  Widget body() {
    var spinkit = SpinKitRipple(
      color: Theme.of(context).primaryColorLight,
      size: 200.0,
    );
    return ModalProgressHUD(
        opacity: 1,
        progressIndicator: spinkit,
        // 这里引用 Theme 会导致透明, 奇怪的要死
        color: Theme.of(context).scaffoldBackgroundColor,
        //color: Colors.white,
        dismissible: true,
        child: Column(children: [
          ArticleYouTube(
            article: article,
          ),
          refreshBody()
        ]),
        inAsyncCall: loading);
  }

  Widget articleBody() {
    if (article.title == null) return Container();
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        child: Column(children: [
          ArticleTopBar(article: article),
          NotMasteredVocabulary(article: article),
          Padding(
              padding: EdgeInsets.all(5),
              child: ArticleSentences(
                  article: article, sentences: article.sentences)),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("build article");
    return Consumer<Article>(builder: (context, article, child) {
      return Scaffold(
        body: body(),
        floatingActionButton: ArticleFloatingActionButton(this.article),
      );
    });
  }
}
