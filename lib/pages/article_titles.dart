import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
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
import '../pages/home.dart';

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
  Controller _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionListener =
      ItemPositionsListener.create();
  OauthInfo _oauthInfo;
  @override
  initState() {
    super.initState();
    _controller = Provider.of<Controller>(context, listen: false);
    _articleTitles = Provider.of<ArticleTitles>(context, listen: false);
    _articleTitles.getFromLocal();
    //when add new youtube done call this function
    _articleTitles.newYouTubeCallBack = this.newYouTubeCallBack;
    // use witch function srcoll to article item
    _articleTitles.scrollToArticleTitle = this.scrollToArticleTitle;

    _oauthInfo = Provider.of<OauthInfo>(context, listen: false);
    // if new login resync article title
    _oauthInfo.setAccessTokenCallBack = this.syncArticleTitles;
    _oauthInfo.backFromShared();
  }

  //添加新的youtube以后的处理回调
  newYouTubeCallBack(String result) {
    print("newYouTubeCallBack result=$result");
    switch (result) {
      case ArticleTitles.exists:
        _controller.showSnackBar("❦  Already exists!");
        break;
      case ArticleTitles.noSubtitle:
        _controller.showSnackBar("❕  Don't have any en subtitle!");
        break;
      case ArticleTitles.done:
        _controller.showSnackBar("❦  Success~~");
        break;
      default:
        _controller.showSnackBar("✗  Something wrong: $result!");
    }
  }

  Future syncArticleTitles() async {
    var result = await _articleTitles.syncArticleTitles().catchError((e) {
      String errorInfo = "";
      if (isAccessTokenError(e)) {
        errorInfo = "Login expired";
        _oauthInfo.signIn();
      } else
        errorInfo = e.message;
      _controller.showSnackBar(errorInfo);
    });
    return result;
  }

  Widget getArticleTitlesBody() {
    return Selector<ArticleTitles, List<ArticleTitle>>(
        selector: (context, articleTitles) => articleTitles.filterTitles,
        builder: (context, filterTitles, child) {
          print("Selector $this");
          if (filterTitles.length == 0)
            return getBlankPage();
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
  }

  Widget getBlankPage() {
    return Center(child: Image(image: AssetImage('assets/images/logo.png')));
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
        onPressed: () async {
          //_articleTitles.justNotifyListeners();
          _controller.setMainSelectedIndex(ExplorerPageIndex);
          //.showSnackBar("test");
        },
        child: Icon(Icons.explore),
      ),
    );
  }
}
