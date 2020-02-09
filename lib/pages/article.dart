import 'dart:async';
import 'package:flutter/cupertino.dart';

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
import '../models/settings.dart';
import '../models/article_inherited.dart';
import '../functions/utility.dart';

@immutable
class ArticlePage extends StatefulWidget {
  //ArticlePage({Key key, this.initID}) : super(key: key);
  ArticlePage(this._articleID);

  final int _articleID;

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage>
    with AutomaticKeepAliveClientMixin {
  bool wantKeepAlive = true;
  Article article;
  ScrollController _scrollController;
  ArticleTitles articleTitles;
  Settings settings;
  int _articleID;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _articleID = widget._articleID;
    _scrollController = ScrollController();
    settings = Provider.of<Settings>(context, listen: false);
    article = Article();
    articleTitles = Provider.of<ArticleTitles>(context, listen: false);
    article.articleID = _articleID;
    article.notifyListeners2 = () {
      setState(() {});
    };
    articleTitles.setInstanceArticles(article);
    loadArticleByID();
  }

  @override
  void deactivate() {
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

  Future loadFromServer() async {
    await article.getArticleByID(this._articleID);
    if (this.mounted) {
      // 更新本地未学单词数
      articleTitles.setUnlearnedCountByArticleID(
          article.unlearnedCount, article.articleID);
    }
    _loading = false;
  }

  Future loadArticleByID() async {
    setState(() {
      _loading = true;
    });
    bool hasLocal = await article.getFromLocal(_articleID);
    if (hasLocal) {
      //如果缓存取到, 就不要更新页面内容, 避免后置更新导致页面跳变
      setState(() {
        _loading = false;
      });
      // 这里从server取只是为了更新本地cache,井不马上刷页面
      loadFromServer();
    } else {
      setState(() {
        loadFromServer();
      });
    }
  }

  Widget refreshBody() {
    return Expanded(
        child: RefreshIndicator(
      onRefresh: () async => await loadFromServer(),
      child: articleBody(),
      //color: mainColor,
    ));
  }

  Widget body() {
    return ModalProgressHUD(
        opacity: 1,
        progressIndicator: getSpinkitProgressIndicator(context),
        color: Theme.of(context).scaffoldBackgroundColor,
        dismissible: true,
        child: Column(children: [
          ArticleYouTube(
            article: article,
          ),
          refreshBody()
        ]),
        inAsyncCall: _loading);
  }

  Widget articleBody() {
    if (article.title == null) return Container();
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        child: Column(children: [
          ArticleTopBar(article: article),
          NotMasteredVocabulary(),
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
    return ArticleInherited(
        article: this.article,
        child: Scaffold(
            body: body(), floatingActionButton: ArticleFloatingActionButton()));
  }
}
