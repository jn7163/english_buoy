import 'dart:async';

import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:provider/provider.dart';

import '../components/article_sentences.dart';
import '../components/article_top_bar.dart';
import '../components/not_mastered_vocabularies.dart';
import '../components/article_youtube.dart';
import '../models/article_titles.dart';
import '../models/article.dart';
import '../models/settings.dart';
import '../themes/bright.dart';

@immutable
class ArticlePage extends StatefulWidget {
  ArticlePage({Key key, this.initID}) : super(key: key);

  final int initID;

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  Article article;
  ScrollController _scrollController;
  ArticleTitles articleTitles;
  int id, lastID, nextID;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    id = widget.initID;
    _scrollController = ScrollController();
    article = Provider.of<Article>(context, listen: false);
    articleTitles = Provider.of<ArticleTitles>(context, listen: false);
    loadByID();
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
    if (article.youtubeController != null) article.youtubeController.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    //为了避免内存泄露，需要调用_controller.dispose
    _scrollController.dispose();
    super.dispose();
  }

  Future loadFromServer(int id) async {
    return article.getArticleByID(id).then((d) {
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
    // from local cache
    article.getFromLocal(id).then((hasLocal) {
      if (!hasLocal) {
        setState(() {
          loading = true;
        });
      }
    });

    // always update from server
    return await loadFromServer(id);
  }

  Widget refreshBody() {
    return Expanded(
        child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity < -800) {
                if (nextID != null) {
                  id = nextID;
                  articleTitles.setSelectedArticleID(id); // 高亮列表
                  //刷新当前页
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ArticlePage(initID: id)));
                }
              }
              if (details.primaryVelocity > 800) {
                if (lastID != null) {
                  id = lastID;
                  articleTitles.setSelectedArticleID(id);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ArticlePage(initID: id)));
                }
              }
              // Navigator.pushNamed(context, '/Article', arguments: d.id);
            },
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: articleBody(),
              color: mainColor,
            )));
  }

  Widget body() {
    return ModalProgressHUD(
        child: Column(children: [getYouTube(), refreshBody()]),
        inAsyncCall: loading);
  }

  Widget articleBody() {
    return Consumer<Article>(builder: (context, article, child) {
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
    });
  }

  Widget getYouTube() {
    if (article.title == null || article.youtube == '') return Container();
    return Consumer<Article>(builder: (context, article, child) {
      return Container(
          color: Colors.black,
          padding: EdgeInsets.only(top: 24),
          child: ArticleYouTube());
    });
  }

  Future _refresh() async {
    await loadFromServer(id);
    return;
  }

  Widget floatingActionButton() {
    return Visibility(
        visible: article.notMasteredWord != null,
        child: Opacity(
            opacity: 0.4,
            child: FloatingActionButton(
              onPressed: () {
                Scrollable.ensureVisible(article.notMasteredWord.c);
                article.setFindWord(article.notMasteredWord.words[0].text);
                article.setNotMasteredWord(null);
              },
              child: Icon(Icons.arrow_upward,
                  color: Theme.of(context).primaryTextTheme.title.color),
            )));
  }

  @override
  Widget build(BuildContext context) {
    print("build article");

    return Consumer<Article>(builder: (context, article, child) {
      return Scaffold(
          body: body(), floatingActionButton: floatingActionButton());
    });
  }
}
