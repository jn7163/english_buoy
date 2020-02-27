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
import '../models/sentence.dart';
import '../models/article_inherited.dart';
import '../models/controller.dart';
import '../functions/utility.dart';

class TimeSentenceIndex {
  int startSeconds = 0;
  int endSeconds = 0;
  List<int> indexs = List();
  setHighlight(bool highlight, List<Sentence> sentences) {
    indexs.forEach((i) => sentences[i].highlight = highlight);
  }
}

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
  Article _article;
  ScrollController _scrollController;
  ArticleTitles _articleTitles;
  Settings settings;
  int _articleID;
  bool _loading = false;
  Timer _timer;
  int _highlightSentenceIndex;
  Controller _controller;
  // keep {int timeSecond: [SentenceIndex1, SentenceIndex2, ...]}
  List<TimeSentenceIndex> _timeSentenceIndexs = List();

  @override
  void initState() {
    super.initState();
    _articleID = widget._articleID;

    _controller = Provider.of<Controller>(context, listen: false);
    _scrollController = ScrollController();
    settings = Provider.of<Settings>(context, listen: false);
    _article = Article();
    _articleTitles = Provider.of<ArticleTitles>(context, listen: false);
    _article.articleID = _articleID;
    //send current setState callBack function to article model
    _article.notifyListeners2 = () {
      if (this.mounted) setState(() {});
    };
    _articleTitles.setInstanceArticles(_article);
    loadArticleByID();
    preload();
  }

  @override
  void deactivate() {
    debugPrint("ArticlePage deactivate");
    // This pauses video while navigating to next page.
    if (_article.youtubeController != null) _article.youtubeController.pause();
    _timer?.cancel();
    super.deactivate();
  }

  @override
  void dispose() {
    debugPrint("ArticlePage dispose");
    //为了避免内存泄露，需要调用_scrollController.dispose
    _scrollController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  //star check sentence highlight routine
  initRoutine() {
    if (_timer == null && _article.youtube != "") {
      _timer = Timer.periodic(const Duration(milliseconds: 800),
          (t) => routineCheckSentenceHighLight());
    }
  }

  routineCheckSentenceHighLight() {
    //if leave this article page no need checkSentenceHighlight
    if (!_article.checkSentenceHighlight) return;
    debugPrint("routineCheckSentenceHighLight article=" +
        widget._articleID.toString());
    if (_article.youtubeController == null) return;
    int currentIndex;
    for (int i = 0; i < _timeSentenceIndexs.length; i++) {
      int currentSeconds = _article.youtubeController.value.position.inSeconds;
      // current playing time between start and end then highlight it
      if (currentSeconds >= _timeSentenceIndexs[i].startSeconds &&
          currentSeconds < _timeSentenceIndexs[i].endSeconds) {
        _timeSentenceIndexs[i].setHighlight(true, _article.sentences);
        currentIndex = i;
      } else
        _timeSentenceIndexs[i].setHighlight(false, _article.sentences);
    }
    // trigger setState if set new highlight sentence
    if (currentIndex != null && _highlightSentenceIndex != currentIndex) {
      print("find some set index=" + currentIndex.toString());
      setState(() {
        //auto scroll sentence to top
        // if change page don't run ensureVisible
        if (settings.isScrollWithPlay &&
            _controller.mainSelectedIndex == 1 &&
            _controller.selectedArticleID == _article.articleID) {
          int sentenceIndex = _timeSentenceIndexs[currentIndex].indexs[0];
          Scrollable.ensureVisible(_article.sentences[sentenceIndex].c,
              duration: Duration(milliseconds: 1400), alignment: 0.0);
        }
        //alignment: 0.0);
        _highlightSentenceIndex = currentIndex;
      });
    }
  }

  // preload last and next article from server save to local
  preload() {
    List<int> result =
        _articleTitles.findLastNextArticleByID(_article.articleID);
    int lastID = result[0];
    int nextID = result[1];

    Article preArticle = Article();
    if (lastID != null) preArticle.getArticleByID(lastID);
    if (nextID != null) preArticle.getArticleByID(nextID);
  }

  Future loadFromServer() async {
    await _article.getArticleByID(_article.articleID);
    if (this.mounted) {
      // 更新本地未学单词数
      _articleTitles.setUnlearnedCountByArticleID(
          _article.unlearnedCount, _article.articleID);
    }
    _loading = false;
  }

  Future loadArticleByID() async {
    setState(() {
      _loading = true;
    });
    bool hasLocal = await _article.getFromLocal(_article.articleID);
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
    this.splitSentencesByTime();
    this.initRoutine();
  }

  //split article sentences by time
  void splitSentencesByTime() {
    _timeSentenceIndexs = List();
    for (int i = 0; i < _article.sentences.length; i++) {
      String startTime = _article.sentences[i].startTime;
      if (startTime != "") {
        int iStartTime = toDuration(startTime).inSeconds;
        if (_timeSentenceIndexs.length > 0)
          _timeSentenceIndexs[_timeSentenceIndexs.length - 1].endSeconds =
              iStartTime;
        TimeSentenceIndex timeSentenceIndex = TimeSentenceIndex();
        timeSentenceIndex.startSeconds = iStartTime;
        timeSentenceIndex.indexs.add(i);

        while (i + 1 < _article.sentences.length &&
            _article.sentences[i + 1].startTime == "") {
          i++;
          timeSentenceIndex.indexs.add(i);
        }
        _timeSentenceIndexs.add(timeSentenceIndex);
      }
    }
    //make sure last sentence has endtime
    _timeSentenceIndexs[_timeSentenceIndexs.length - 1].endSeconds =
        _timeSentenceIndexs[_timeSentenceIndexs.length - 1].startSeconds +
            10000;
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
            article: _article,
          ),
          refreshBody()
        ]),
        inAsyncCall: _loading);
  }

  Widget articleBody() {
    if (_article.title == null) return Container();
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        child: Column(children: [
          ArticleTopBar(article: _article),
          NotMasteredVocabulary(),
          Padding(
              padding: EdgeInsets.all(5),
              child: ArticleSentences(
                  article: _article, sentences: _article.sentences)),
        ]));
  }

  @override
  updateKeepAlive() {
    super.updateKeepAlive();
    if (widget._articleID != _article.articleID) {
      _article.articleID = widget._articleID;
      loadArticleByID();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget._articleID != -1 && widget._articleID != _article.articleID) {
      wantKeepAlive = false;
      _article.articleID = widget._articleID;
      loadArticleByID().then((d) => wantKeepAlive = true);
    }

    print("build article");
    return ArticleInherited(
        article: this._article,
        child: Scaffold(
            body: body(), floatingActionButton: ArticleFloatingActionButton()));
  }
}
