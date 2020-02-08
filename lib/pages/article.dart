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
import '../functions/utility.dart';

@immutable
class ArticlePage extends StatefulWidget {
  //ArticlePage({Key key, this.initID}) : super(key: key);
  ArticlePage(this.initID);

  final int initID;

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage>
    with AutomaticKeepAliveClientMixin {
  bool wantKeepAlive = false;
  Article article;
  ScrollController _scrollController;
  ArticleTitles articleTitles;
  Settings settings;
  int _id, lastID, nextID;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _id = widget.initID;
    _scrollController = ScrollController();
    settings = Provider.of<Settings>(context, listen: false);
    //article = Provider.of<Article>(context, listen: false);
    article = Article();
    article.notifyListeners2 = () {
      setState(() {});
    };
    articleTitles = Provider.of<ArticleTitles>(context, listen: false);
    article.articleID = _id;
    articleTitles.setInstanceArticles(article);
    loadByID();
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

  loadByID() {
    var a = articleTitles.findLastNextArticleByID(_id);
    lastID = a[0];
    nextID = a[1];
    loadArticleByID();
  }

  Future loadFromServer({bool justUpdateLocal = false}) async {
    return article
        .getArticleByID(articleID: this._id, justUpdateLocal: justUpdateLocal)
        .then((d) {
      if (this.mounted) {
        // 更新本地未学单词数
        articleTitles.setUnlearnedCountByArticleID(
            article.unlearnedCount, article.articleID);
      }
      setState(() {
        _loading = false;
      });
      return d;
    });
  }

  Future loadArticleByID() async {
    setState(() {
      _loading = true;
    });
    article.getFromLocal(_id).then((hasLocal) {
      if (!hasLocal) {
        return loadFromServer();
      } else {
        //如果缓存取到, 就不要更新页面内容, 避免后置更新导致页面跳变
        setState(() {
          _loading = false;
        });
        return loadFromServer(justUpdateLocal: true);
      }
    });
  }

  /*
  refreshCurrentLeftToRight() {
    articleTitles.setSelectedArticleID(this.id); // 高亮列表
    //刷新当前页
    Navigator.pushReplacement(
        context,
        PageTransition(
          duration: Duration(milliseconds: 500),
          type: PageTransitionType.leftToRight,
          child: ArticlePage(this.id),
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
        child: ArticlePage(this.id),
      ),
    );
  }
  */

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
          Padding(
              padding: EdgeInsets.all(5),
              child: ArticleSentences(
                  article: article, sentences: article.sentences)),
          NotMasteredVocabulary(article: article),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("build article");
    return Scaffold(
      body: body(),
      floatingActionButton: ArticleFloatingActionButton(article),
    );
  }
}
