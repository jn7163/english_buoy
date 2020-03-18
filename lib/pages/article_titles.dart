import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:async';

import '../components/article_titles_app_bar.dart';
import '../components/article_titles_slidable.dart';
import '../components/right_drawer.dart';
import '../components/left_drawer.dart';

import '../models/controller.dart';
import '../models/article_titles.dart';
import '../models/oauth_info.dart';
import '../models/article_title.dart';

import '../functions/utility.dart';
import '../themes/base.dart';

class ArticleTitlesPage extends StatefulWidget {
  ArticleTitlesPage({Key key}) : super(key: key);

  @override
  ArticleTitlesPageState createState() => ArticleTitlesPageState();
}

class ArticleTitlesPageState extends State<ArticleTitlesPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  ArticleTitles _articleTitles;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionListener =
      ItemPositionsListener.create();
  OauthInfo _oauthInfo;
  Controller _controller;
  @override
  initState() {
    super.initState();
    _articleTitles = Provider.of<ArticleTitles>(context, listen: false);
    _controller = Provider.of<Controller>(context, listen: false);

    //make sure already load
    //if (settings.filertPercent == 70) await settings.getFromLocal();
    _articleTitles.getFromLocal();
    _oauthInfo = Provider.of<OauthInfo>(context, listen: false);
    //设置回调
    _articleTitles.newYouTubeCallBack = this.newYouTubeCallBack;
    _articleTitles.scrollToArticleTitle = this.scrollToArticleTitle;
    _oauthInfo.setAccessTokenCallBack = this.syncArticleTitles;
    _oauthInfo.backFromShared();
  }

  showInfo(String info) {
    final snackBar = SnackBar(
      backgroundColor: mainColor,
      content: Text(
        info,
        textAlign: TextAlign.center,
      ),
      //duration: Duration(milliseconds: 500),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  //添加新的youtube以后的处理回调
  newYouTubeCallBack(String result) {
    print("newYouTubeCallBack result=" + result);
    switch (result) {
      case ArticleTitles.exists:
        this.showInfo("❦ Article already exists");
        break;
      case ArticleTitles.noSubtitle:
        this.showInfo("❕This YouTube video don't have any en subtitle!");
        break;
      case ArticleTitles.done:
        this.showInfo("❦ Add success");
        break;
      default:
        this.showInfo("✗ Something wrong: " + result);
    }
  }

  Future syncArticleTitles() async {
    return _articleTitles.syncArticleTitles()
        //.catchError((_) => oauthInfo.signIn());
        .catchError((e) {
      String errorInfo = "";
      if (isAccessTokenError(e)) {
        errorInfo = "Login expired";
        _oauthInfo.signIn();
      } else
        errorInfo = e.message;

      final snackBar = SnackBar(
        backgroundColor: mainColor,
        content: Text(
          errorInfo,
          textAlign: TextAlign.center,
        ),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    });
  }

  Widget getArticleTitlesBody() {
    return Selector<ArticleTitles, List<ArticleTitle>>(
        selector: (context, articleTitles) => articleTitles.filterTitles,
        builder: (context, filterTitles, child) {
          print("run Selector ArticleTitles");
          Widget body;
          if (filterTitles.length == 0)
            body = Container();
          else
            body = ScrollablePositionedList.builder(
              itemCount: filterTitles.length,
              itemBuilder: (context, index) {
                return ArticleTitlesSlidable(
                    articleTitle: filterTitles.reversed.toList()[index]);
              },
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionListener,
            );
          return ModalProgressHUD(
              opacity: 1,
              progressIndicator: getSpinkitProgressIndicator(context),
              color: Theme.of(context).scaffoldBackgroundColor,
              dismissible: true,
              child: body,
              inAsyncCall: filterTitles.length == 0);
        });
  }

  Future refresh() async {
    await syncArticleTitles();
    return;
  }

  // 滚动到那一条目
  scrollToArticleTitle(int index) {
    print("scrollToArticleTitle index=" + index.toString());
    // 稍微等等, 避免 build 时候滚动
    Future.delayed(Duration.zero, () {
      itemScrollController.scrollTo(
          index: index,
          duration: Duration(seconds: 2),
          curve: Curves.easeInOutCubic);
    });
  }

  @override
  Widget build(BuildContext context) {
    print("build $this");
    super.build(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: ArticleListsAppBar(scaffoldKey: _scaffoldKey),
      drawer: LeftDrawer(),
      endDrawer: RightDrawer(),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: getArticleTitlesBody(),
        color: mainColor,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _articleTitles.justNotifyListeners();
          //_controller.setMainSelectedIndex(3);
        },
        child: Icon(Icons.explore),
      ),
    );
  }
}
