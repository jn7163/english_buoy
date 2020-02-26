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
  ArticleTitles _articleTitles;
  Settings settings;
  int _articleID;
  bool _loading = false;
  Timer _timer;
  int _highLightSentenceIndex;

  @override
  void initState() {
    super.initState();
    _articleID = widget._articleID;
    _scrollController = ScrollController();
    settings = Provider.of<Settings>(context, listen: false);
    article = Article();
    _articleTitles = Provider.of<ArticleTitles>(context, listen: false);
    article.articleID = _articleID;
    //send current setState callBack function to article model
    article.notifyListeners2 = () {
      if (this.mounted) setState(() {});
    };
    _articleTitles.setInstanceArticles(article);
    loadArticleByID();
    preload();
  }

  @override
  void deactivate() {
    debugPrint("ArticlePage deactivate");
    // This pauses video while navigating to next page.
    if (article.youtubeController != null) article.youtubeController.pause();
    _timer?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    debugPrint("ArticlePage dispose");
    //为了避免内存泄露，需要调用_controller.dispose
    _scrollController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  //star check sentence highlight routine
  initRoutine() {
    if (_timer == null && article.youtube != "") {
      _timer = Timer.periodic(const Duration(milliseconds: 800),
          (t) => routineCheckSentenceHighLight());
    }
  }

  routineCheckSentenceHighLight() {
    if (!article.checkSentenceHighlight) return;
    // debugPrint("routineCheckSentenceHighLight article=" + widget._articleID.toString());
    if (article.youtubeController == null) return;
    int currentIndex;
    for (int i = 0; i < article.sentences.length; i++) {
      if (article.sentences[i]
          .checkPlayToCurrent(article.youtubeController.value.position)) {
        currentIndex = i;

        while (i + 1 < article.sentences.length &&
            article.sentences[i + 1].followHighLight()) {
          i++;
        }
        print("find some set index=" + i.toString());
        break;
      }
    }
    if (currentIndex != null && _highLightSentenceIndex != currentIndex) {
      print("find some set index=" + currentIndex.toString());
      setState(() {
        _highLightSentenceIndex = currentIndex;
      });
    }
  }

  // preload last and next article from server save to local
  preload() {
    List<int> result =
        _articleTitles.findLastNextArticleByID(article.articleID);
    int lastID = result[0];
    int nextID = result[1];

    Article preArticle = Article();
    if (lastID != null) preArticle.getArticleByID(lastID);
    if (nextID != null) preArticle.getArticleByID(nextID);
  }

  Future loadFromServer() async {
    await article.getArticleByID(article.articleID);
    if (this.mounted) {
      // 更新本地未学单词数
      _articleTitles.setUnlearnedCountByArticleID(
          article.unlearnedCount, article.articleID);
    }
    _loading = false;
  }

  Future loadArticleByID() async {
    setState(() {
      _loading = true;
    });
    bool hasLocal = await article.getFromLocal(article.articleID);
    if (hasLocal) {
      //如果缓存取到, 就不要更新页面内容, 避免后置更新导致页面跳变
      setState(() {
        _loading = false;
      });
      // use preload replace loadFromServer even get from local
      //loadFromServer();
    } else {
      await loadFromServer();
      setState(() {});
    }
    this.initRoutine();
  }

  Widget refreshBody() {
    return Expanded(
        child: RefreshIndicator(
      onRefresh: loadFromServer,
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
  updateKeepAlive() {
    super.updateKeepAlive();
    if (widget._articleID != article.articleID) {
      article.articleID = widget._articleID;
      loadArticleByID();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget._articleID != -1 && widget._articleID != article.articleID) {
      wantKeepAlive = false;
      article.articleID = widget._articleID;
      loadArticleByID().then((d) => wantKeepAlive = true);
    }

    print("build article");
    return ArticleInherited(
        article: this.article,
        child: Scaffold(
            body: body(), floatingActionButton: ArticleFloatingActionButton()));
  }
}
