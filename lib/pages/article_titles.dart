// 文章列表
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:easy_alert/easy_alert.dart' as toast;
import 'package:rflutter_alert/rflutter_alert.dart';

import '../components/article_titles_app_bar.dart';
import '../components/article_titles_slidable.dart';
import '../components/right_drawer.dart';
import '../components/left_drawer.dart';

import '../models/article_titles.dart';
import '../models/oauth_info.dart';
import '../models/settings.dart';

import '../store/article.dart';
import '../themes/bright.dart';

class ArticleTitlesPage extends StatefulWidget {
  ArticleTitlesPage({Key key}) : super(key: key);

  @override
  ArticleTitlesPageState createState() => ArticleTitlesPageState();
}

class ArticleTitlesPageState extends State<ArticleTitlesPage> {
  ArticleTitles articleTitles;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionListener =
      ItemPositionsListener.create();
  Settings settings;
  OauthInfo oauthInfo;
  @override
  initState() {
    super.initState();

    settings = Provider.of<Settings>(context, listen: false);
    articleTitles = Provider.of<ArticleTitles>(context, listen: false);
    articleTitles.getFromLocal();
    oauthInfo = Provider.of<OauthInfo>(context, listen: false);
    oauthInfo.backFromShared();
    //设置回调
    articleTitles.newYouTubeCallBack = this.newYouTubeCallBack;
    articleTitles.scrollToArticleTitle = this.scrollToArticleTitle;
  }

  //添加新的youtube以后的处理回调
  newYouTubeCallBack(String result) {
    print("newYouTubeCallBack result=" + result);
    switch (result) {
      case ArticleTitles.exists:
        {
          this.showToast("article is exists");
        }
        break;
      case ArticleTitles.noSubtitle:
        {
          Alert(
            context: context,
            type: AlertType.info,
            title: "Sorry",
            desc: "This YouTube video don't have any en subtitle!",
            buttons: [
              DialogButton(
                child: Text(
                  "Ok",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () => Navigator.pop(context),
                width: 120,
              )
            ],
          ).show();
        }
        break;
      case ArticleTitles.done:
        {
          debugPrint("newYouTubeCallBack done");
        }
        break;
      default:
        {
          this.showToast("article is exists");
        }
    }
  }

  showToast(String info) {
    toast.Alert.toast(context, info,
        position: toast.ToastPosition.bottom,
        duration: toast.ToastDuration.long);
  }

  Future _syncArticleTitles() async {
    return articleTitles.syncArticleTitles().catchError((e) {
      if (e.response && e.response.statusCode == 401) oauthInfo.signIn();
    });
  }

  Widget getArticleTitlesBody() {
    return Consumer<ArticleTitles>(builder: (context, articleTitles, child) {
      return articleTitles.filterTitles.length > 0
          ? ScrollablePositionedList.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: articleTitles.filterTitles.length,
              itemBuilder: (context, index) {
                return ArticleTitlesSlidable(
                    articleTitle: articleTitles.filterTitles[index]);
              },
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionListener,
            )
          : Container();
    });
  }

  // EnsureVisible 不支持 ListView 只有用 50 宽度估算的来 scroll 到分享过来的条目
  Future<void> scrollToSharedItem(int articleID) async {
    int selectedIndex;
    if (articleID == 0) return;
    //找到 id
    for (int i = 0; i < articleTitles.filterTitles.length; i++) {
      if (articleTitles.filterTitles[i].id == articleID) {
        selectedIndex = i;
        break;
      }
    }
    scrollToArticleTitle(selectedIndex);
  }

  Future _refresh() async {
    await _syncArticleTitles();
    return;
  }

  // 滚动到那一条目
  scrollToArticleTitle(int index) {
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
    return Consumer<ArticleTitles>(builder: (context, articleTitlesNow, child) {
      return Scaffold(
          key: _scaffoldKey,
          appBar: ArticleListsAppBar(scaffoldKey: _scaffoldKey),
          drawer: LeftDrawer(),
          endDrawer: RightDrawer(),
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: getArticleTitlesBody(),
            color: mainColor,
          ),
          floatingActionButton: Visibility(
              visible: articleTitlesNow.titles.length > 10 ? false : true,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/Guid');
                },
                child: Icon(Icons.help_outline,
                    color: Theme.of(context).primaryTextTheme.title.color),
              )));
    });
  }
}
