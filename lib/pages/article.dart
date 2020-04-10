import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../components/article_sentences.dart';
import '../components/article_sentence.dart';
import '../components/article_top_bar.dart';
import '../components/not_mastered_vocabularies.dart';
import '../components/article_youtube.dart';
import '../components/article_floating_action_button.dart';
import '../components/youtube_thumbnail.dart';
import '../models/article_titles.dart';
import '../models/article_title.dart';
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
    indexs.forEach((i) => sentences[i].setHightlight(highlight));
  }
}

@immutable
class ArticlePage extends StatefulWidget {
  ArticlePage({Key key, @required this.articleID, this.articleTitle}) : super(key: key);
  //ArticlePage(this._articleID);

  final int articleID;
  final ArticleTitle articleTitle;

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
  bool _loading = false;
  Timer _timer;
  int _highlightSentenceIndex;
  List<TimeSentenceIndex> _timeSentenceIndexs = List();
  Controller _controller;
  OauthInfo _oauthInfo;

  @override
  void initState() {
    super.initState();
    _controller = Provider.of<Controller>(context, listen: false);
    _oauthInfo = Provider.of<OauthInfo>(context, listen: false);
    _articleID = widget.articleID;

    _scrollController = ScrollController();
    //_scrollController.addListener(this.scrollListener);
    _settings = Provider.of<SettingNews>(context, listen: false);
    _article = Article();
    _articleTitles = Provider.of<ArticleTitles>(context, listen: false);
    _article.articleID = _articleID;
    //send current setState callBack function to article model
    _article.setStateCallback = () {
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

  // no need
  scrollListener() {
    /*
    //up
    if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isScrollUp)
        setState(() {
          _isScrollUp = true;
        });
    }
    //down
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isScrollUp)
        setState(() {
          _isScrollUp = false;
        });
    }
    */

    //reach the bottom
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent && !_scrollController.position.outOfRange) {}
    /*
    if (_scrollController.offset <= _scrollController.position.minScrollExtent && !_scrollController.position.outOfRange) {
      setState(() {
        message = "reach the top";
      });
    }
    */
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
    if (_article.youtubeController == null) return;
    if (!_article.youtubeController.value.isPlaying) return;

    int currentIndex;
    for (int i = 0; i < _timeSentenceIndexs.length; i++) {
      int currentSeconds = _article.youtubeController.value.position.inSeconds;
      // current playing time between start and end then highlight it
      if (currentSeconds >= _timeSentenceIndexs[i].startSeconds && currentSeconds < _timeSentenceIndexs[i].endSeconds) {
        currentIndex = i;
        _timeSentenceIndexs[i].setHighlight(true, _article.sentences);
      } else
        _timeSentenceIndexs[i].setHighlight(false, _article.sentences);
    }
    // trigger setState if set new highlight sentence
    if (currentIndex != null && _highlightSentenceIndex != currentIndex) {
      _highlightSentenceIndex = currentIndex;
      //auto scroll sentence to top
      if (_settings.isScrollWithPlay &&
              controller.homeIndex == ArticlePageViewPageIndex && // is in page view page
              controller.selectedArticleID == _article.articleID // is open current page, the youtube play status may
          ) {
        int sentenceIndex = _timeSentenceIndexs[currentIndex].indexs[0];
        Scrollable.ensureVisible(_article.sentences[sentenceIndex].c, duration: Duration(milliseconds: 1400), alignment: 0.0);
      }
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

  Future loadFromServer({bool showLoading = false}) async {
    if (showLoading)
      setState(() {
        _loading = true;
      });
    await _article.getArticleByID(_article.articleID).catchError((e) {
      String errorInfo = "";
      if (isAccessTokenError(e)) {
        errorInfo = "Login expired";
        _oauthInfo.signIn();
      } else {
        errorInfo = e.toString();
        if (errorInfo.contains('Connection terminated during handshake'))
          _controller.showSnackBar("Failed to load article.", retry: () => loadFromServer(showLoading: showLoading));
        else
          _controller.showSnackBar(errorInfo);
      }
    });
    if (showLoading)
      setState(() {
        _loading = false;
      });
    // update unmastered word count
    /*
    if (this.mounted) {
      _articleTitles.setUnlearnedCountByArticleID(_article.unlearnedCount, _article.articleID);
    }
    */
  }

  Future runRoutine() async {
    this.splitSentencesByTime();
    this.initRoutine();
  }

  Future updateUnMastered() async {
    // recompute unmastered word
    bool isChange = _article.recomputeUnmastered();
    // update aritcles
    if (isChange)
      Provider.of<ArticleTitles>(context, listen: false)
          .setUnlearnedCountByArticleID(_article.unlearnedCount, _article.articleID);
  }

  Future loadArticleByID() async {
    bool hasLocal = await _article.getFromLocal(_article.articleID);
    if (!hasLocal) await loadFromServer(showLoading: true);
    if (_article.youtube != null && _article.youtube != "") runRoutine();
    await _article.queryWordWise();
    //  show word wise
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
    /*
    ModalProgressHUD hud = ModalProgressHUD(
        opacity: 1,
        progressIndicator: getSpinkitProgressIndicator(context),
        color: Theme.of(context).scaffoldBackgroundColor,
        dismissible: true,
        child: Column(children: [
          ArticleYouTube(article: _article),
          refreshBody(),
        ]),
        inAsyncCall: _loading);
        */
    Widget col = _loading
        ? loadingPage()
        : Column(children: [
            ArticleYouTube(article: _article),
            refreshBody(),
          ]);
    return VisibilityDetector(
        key: Key(_article.articleID.toString()),
        onVisibilityChanged: (d) {
          //make sure show right word state
          if (d.visibleFraction == 1) setState(() {});
          // when leave get new content from server
          if (d.visibleFraction == 0) {
            updateUnMastered();
            loadFromServer();
          }
        },
        child: col);
  }

  Widget loadingPage() {
    if (widget.articleTitle.thumbnailURL == null || widget.articleTitle.thumbnailURL == '') return Container();

    Article loadingAritcle = Article();
    loadingAritcle.title = widget.articleTitle.title;
    loadingAritcle.avatar = widget.articleTitle.avatar;
    loadingAritcle.youtube = widget.articleTitle.youtube;
    return SafeArea(
      child: Column(children: [
        YouTubeThumbnail(
          thumbnailURL: widget.articleTitle.thumbnailURL,
        ),
        ArticleTopBar(article: loadingAritcle),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[500],
              highlightColor: Colors.grey[200],
              child: Text(
                '''
How to memorize?

The first thing you need to know about committing vocabulary to memory is that

CONTEXT is KING.

The richer the context (short story, movie scene, etc.) the easier to memorize and later remember.

What is context?

The Cambridge Dictionary says: “Context is the text or speech that comes immediately before and after a particular phrase or piece of text and helps to explain its meaning.” Generally speaking, context is something with a beginning, middle and an end – at least 3 sentences. Everything else is more or less a waste of time.

When you come across a new word, in a book or in a movie (rich context), in order to increase your chances of remembering that word later on, you need to do the following 7 things:

Use MLDs 

Collocate 

Rephrase 

Visualize 

Personalize

Harmonize 

Notice
              ''',
                style: bodyTextStyle,
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget articleBody() {
    if (_article.title == null || _article.sentences == null) return loadingPage();
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        child: Column(children: [
          ArticleTopBar(article: _article),
          NotMasteredVocabulary(_article),
          Padding(padding: EdgeInsets.all(5), child: ArticleSentences(article: _article)),
          FloatingActionButton(
            onPressed: () => _scrollController.jumpTo(0.1),
            child: Icon(Icons.arrow_upward),
          ),
        ]));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    /*
    // article list data change make PageView  rebuild, need set article disable  want KeepAlive
    if (_article.articleID != null && widget.articleID != _article.articleID) {
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
