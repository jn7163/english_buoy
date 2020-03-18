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
  bool _loading = false;
  @override
  initState() {
    super.initState();
    _articleTitles = Provider.of<ArticleTitles>(context, listen: false);
    _controller = Provider.of<Controller>(context, listen: false);

    //_articleTitles.getFromLocal();
    //设置回调
    _articleTitles.newYouTubeCallBack = this.newYouTubeCallBack;
    _articleTitles.scrollToArticleTitle = this.scrollToArticleTitle;
    _oauthInfo = Provider.of<OauthInfo>(context, listen: false);
    _oauthInfo.setAccessTokenCallBack = this.syncArticleTitles;
    _oauthInfo.backFromShared();
    //this.syncArticleTitles();
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
    setState(() {
      _loading = true;
    });
    var result = await _articleTitles.syncArticleTitles()
        //.catchError((_) => oauthInfo.signIn());
        .catchError((e) {
      String errorInfo = "";
      if (isAccessTokenError(e)) {
        errorInfo = "Login expired";
        _oauthInfo.signIn();
      } else
        errorInfo = e.message;
      this.showInfo(errorInfo);
    });
    setState(() {
      _loading = false;
    });
    return result;
  }

  Widget getArticleTitlesBody() {
    Widget body = Selector<ArticleTitles, List<ArticleTitle>>(
        selector: (context, articleTitles) => articleTitles.filterTitles,
        builder: (context, filterTitles, child) {
          print("run Selector ArticleTitles");
          if (filterTitles.length == 0)
            return Container();
          else
            return ScrollablePositionedList.builder(
              itemCount: filterTitles.length,
              itemBuilder: (context, index) {
                return ArticleTitlesSlidable(
                    articleTitle: filterTitles.reversed.toList()[index]);
              },
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionListener,
            );
        });
    return ModalProgressHUD(
        opacity: 1,
        progressIndicator: getSpinkitProgressIndicator(context),
        color: Theme.of(context).scaffoldBackgroundColor,
        dismissible: true,
        child: body,
        inAsyncCall: _loading);
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
    super.build(context);
    print("build $this");
    return Scaffold(
      key: _scaffoldKey,
      appBar: ArticleListsAppBar(scaffoldKey: _scaffoldKey),
      drawer: LeftDrawer(),
      endDrawer: RightDrawer(),
      body: RefreshIndicator(
        onRefresh: syncArticleTitles,
        child: getArticleTitlesBody(),
        color: mainColor,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller.setMainSelectedIndex(3);
        },
        child: Icon(Icons.explore),
      ),
    );
  }
}
