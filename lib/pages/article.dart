import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../components/article_sentences.dart';
import '../components/article_top_bar.dart';
import '../components/not_mastered_vocabularies.dart';
import '../components/article_youtube.dart';
import '../components/article_floating_action_button.dart';
import '../models/article_titles.dart';
import '../models/article.dart';
import '../models/settings.dart';
import '../models/sentence.dart';
import '../models/controller.dart';
import '../models/oauth_info.dart';
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
  ArticlePage({Key key, this.articleID}) : super(key: key);
  //ArticlePage(this._articleID);

  final int articleID;

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> with AutomaticKeepAliveClientMixin {
  bool wantKeepAlive = true;
  Article _article;
  ScrollController _scrollController;
  ArticleTitles _articleTitles;
  SettingNews _settings;
  int _articleID;
  bool _loading = true;
  Timer _timer;
  int _highlightSentenceIndex;
  List<TimeSentenceIndex> _timeSentenceIndexs = List();
  Controller _controller;
  OauthInfo _oauthInfo;

  @override
  void initState() {
    print("initState $this");
    super.initState();
    _controller = Provider.of<Controller>(context, listen: false);
    _oauthInfo = Provider.of<OauthInfo>(context, listen: false);
    _articleID = widget.articleID;

    _scrollController = ScrollController();
    _settings = Provider.of<SettingNews>(context, listen: false);
    _article = Article();
    _articleTitles = Provider.of<ArticleTitles>(context, listen: false);
    _article.articleID = _articleID;
    //send current setState callBack function to article model
    _article.notifyListeners2 = () {
      if (this.mounted) setState(() {});
    };
    loadArticleByID();
    preload();
    /*
    //maybe this is reinit need set back to need keepAlive
    if (this.wantKeepAlive == false) {
      this.wantKeepAlive = true;
      this.updateKeepAlive();
    }
    */
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
      _timer = Timer.periodic(const Duration(milliseconds: 800), (t) => routineCheckSentenceHighLight());
    }
  }

  routineCheckSentenceHighLight() {
    if (this.mounted == false) return;
    Controller controller = Provider.of<Controller>(context, listen: false);
    //if leave this article page no need checkSentenceHighlight
    if (!_article.checkSentenceHighlight) return;
    if (_article.youtubeController == null) return;
    int currentIndex;
    for (int i = 0; i < _timeSentenceIndexs.length; i++) {
      int currentSeconds = _article.youtubeController.value.position.inSeconds;
      // current playing time between start and end then highlight it
      if (currentSeconds >= _timeSentenceIndexs[i].startSeconds && currentSeconds < _timeSentenceIndexs[i].endSeconds) {
        _timeSentenceIndexs[i].setHighlight(true, _article.sentences);
        currentIndex = i;
      } else
        _timeSentenceIndexs[i].setHighlight(false, _article.sentences);
    }
    // trigger setState if set new highlight sentence
    if (currentIndex != null && _highlightSentenceIndex != currentIndex) {
      //make highlight show
      setState(() {});
      //auto scroll sentence to top
      if (_settings.isScrollWithPlay &&
          controller.homeIndex == ArticlePageViewPageIndex &&
          controller.selectedArticleID == _article.articleID &&
          _article.youtubeController.value.isPlaying) {
        int sentenceIndex = _timeSentenceIndexs[currentIndex].indexs[0];
        Scrollable.ensureVisible(_article.sentences[sentenceIndex].c, duration: Duration(milliseconds: 1400), alignment: 0.0);
      }
      //alignment: 0.0);
      _highlightSentenceIndex = currentIndex;
    }
  }

  // preload last and next article from server save to local
  preload() {
    List<int> result = _articleTitles.findLastNextArticleByID(_article.articleID);
    int lastID = result[0];
    int nextID = result[1];

    Article preArticle = Article();
    if (lastID != null) preArticle.getArticleByID(lastID);
    if (nextID != null) preArticle.getArticleByID(nextID);
  }

  Future loadFromServer() async {
    await _article.getArticleByID(_article.articleID).catchError((e) {
      String errorInfo = "";
      if (isAccessTokenError(e)) {
        errorInfo = "Login expired";
        _oauthInfo.signIn();
      } else {
        errorInfo = e.toString();
        if (errorInfo.contains('Connection terminated during handshake')) {
          sleep(Duration(seconds: 2));
          this.loadFromServer();
        }
      }
      _controller.showSnackBar(errorInfo);
    });
    if (this.mounted) {
      // 更新本地未学单词数
      _articleTitles.setUnlearnedCountByArticleID(_article.unlearnedCount, _article.articleID);
    }
  }

  Future loadArticleByID() async {
    bool hasLocal = await _article.getFromLocal(_article.articleID);
    if (hasLocal)
      loadFromServer();
    else {
      if (this.mounted)
        setState(() {
          _loading = true;
        });
      await loadFromServer();
    }

    if (_article.youtube != null && _article.youtube != "") {
      this.splitSentencesByTime();
      this.initRoutine();
    }
    setState(() {
      _loading = false;
    });
    await _article.queryWordWise();
    // make sure show word wise
    if (this.mounted) setState(() {});
    return hasLocal;
  }

  //split article sentences by time
  void splitSentencesByTime() {
    _timeSentenceIndexs = List();
    for (int i = 0; i < _article.sentences.length; i++) {
      String startTime = _article.sentences[i].startTime;
      if (startTime != "") {
        int iStartTime = toDuration(startTime).inSeconds;
        if (_timeSentenceIndexs.length > 0) _timeSentenceIndexs[_timeSentenceIndexs.length - 1].endSeconds = iStartTime;
        TimeSentenceIndex timeSentenceIndex = TimeSentenceIndex();
        timeSentenceIndex.startSeconds = iStartTime;
        timeSentenceIndex.indexs.add(i);

        while (i + 1 < _article.sentences.length && _article.sentences[i + 1].startTime == "") {
          i++;
          timeSentenceIndex.indexs.add(i);
        }
        _timeSentenceIndexs.add(timeSentenceIndex);
      }
    }
    //make sure last sentence has endtime
    _timeSentenceIndexs[_timeSentenceIndexs.length - 1].endSeconds =
        _timeSentenceIndexs[_timeSentenceIndexs.length - 1].startSeconds + 10000;
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
    ModalProgressHUD hud = ModalProgressHUD(
        opacity: 1,
        progressIndicator: getSpinkitProgressIndicator(context),
        color: Theme.of(context).scaffoldBackgroundColor,
        dismissible: true,
        child: Column(children: [
          Hero(
              tag: 'thumbnail_${_article.articleID}',
              child: ArticleYouTube(
                article: _article,
              )),
          refreshBody()
        ]),
        inAsyncCall: _loading);
    return VisibilityDetector(
        key: Key(_article.articleID.toString()),
        onVisibilityChanged: (d) {
          //make sure show right word state
          if (d.visibleFraction == 1) setState(() {});
        },
        child: hud);
  }

  Widget articleBody() {
    if (_article.title == null) return Container();
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        child: Column(children: [
          ArticleTopBar(article: _article),
          NotMasteredVocabulary(_article),
          Padding(padding: EdgeInsets.all(5), child: ArticleSentences(article: _article, sentences: _article.sentences)),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    /*
    // article list data change make PageView  rebuild, need set article disable  want KeepAlive
    if (_article.articleID != null && widget.articleID != _article.articleID) {
      print("change articleID build $this");
      this.wantKeepAlive = false;
      this.updateKeepAlive();
    }
    */

    return Scaffold(
      //backgroundColor: darkMaterialColor[50],
      //backgroundColor: Colors.white,
      body: body(),
      floatingActionButton: ArticleFloatingActionButton(_article),
    );
  }
}
