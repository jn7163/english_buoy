import 'dart:async';

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
    // from local cache
    article.getFromLocal(id).then((hasLocal) {
      if (!hasLocal) {
        setState(() {
          loading = true;
        });
        return loadFromServer();
      } else {
        //如果缓存取到, 就不要更新页面内容, 避免后置更新导致页面跳变
        return loadFromServer(justUpdateLocal: true);
      }
    });
  }

  refreshCurrent() {
    articleTitles.setSelectedArticleID(this.id); // 高亮列表
    // 暂停视频, 避免滑动切换后自动播放
    if (article.youtubeController != null) article.youtubeController.pause();
    //刷新当前页
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => ArticlePage(initID: this.id)));
  }

  Widget refreshBody() {
    return Expanded(
        child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity < -700) {
                if (nextID != null) {
                  this.id = nextID;
                  this.refreshCurrent();
                }
              }
              if (details.primaryVelocity > 700) {
                if (lastID != null) {
                  this.id = lastID;
                  this.refreshCurrent();
                }
              }
              // Navigator.pushNamed(context, '/Article', arguments: d.id);
            },
            child: RefreshIndicator(
              onRefresh: () async => await loadFromServer(),
              child: articleBody(),
              color: mainColor,
            )));
  }

  Widget body() {
    return ModalProgressHUD(
        child: Column(children: [ArticleYouTube(), refreshBody()]),
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

  @override
  Widget build(BuildContext context) {
    print("build article");

    return Consumer<Article>(builder: (context, article, child) {
      return Scaffold(
          body: body(), floatingActionButton: ArticleFloatingActionButton());
    });
  }
}
