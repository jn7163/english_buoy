// 文章列表
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:flutter_widgets/flutter_widgets.dart';

import '../components/config_dark_theme.dart';
import '../components/config_autoplay.dart';
import '../components/config_filter_by_percent.dart';
import '../components/article_titles_app_bar.dart';
import '../components/article_titles_slidable.dart';

import '../models/youtube.dart';
import '../models/loading.dart';
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
  int _selectedIndex = 0;

  ArticleTitles articleTitles;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionListener =
      ItemPositionsListener.create();
  Loading loading;
  Settings settings;
  OauthInfo oauthInfo;
  @override
  initState() {
    super.initState();

    settings = Provider.of<Settings>(context, listen: false);
    loading = Provider.of<Loading>(context, listen: false);
    articleTitles = Provider.of<ArticleTitles>(context, listen: false);
    articleTitles.getFromLocal();
    oauthInfo = Provider.of<OauthInfo>(context, listen: false);
    oauthInfo.backFromShared();
  }

  Future newYouTube(url) async {
    print("url=" + url);
    return postYouTube(context, url, articleTitles).then((d) {
      scrollToSharedItem(articleTitles.selectedArticleID);
    });
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
    if (articleID == 0) return;
    //找到 id
    for (var i = 0; i < articleTitles.filterTitles.length; i++) {
      if (articleTitles.filterTitles[i].id == articleID) {
        _selectedIndex = i;
        break;
      }
    }
    // 稍微等等, 避免 build 时候滚动
    Future.delayed(Duration.zero, () {
      itemScrollController.scrollTo(
          index: _selectedIndex,
          duration: Duration(seconds: 2),
          curve: Curves.easeInOutCubic);
    });
  }

  Future _refresh() async {
    await _syncArticleTitles();
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<YouTube>(builder: (context, youtube, child) {
      return Consumer<ArticleTitles>(
          builder: (context, articleTitlesNow, child) {
        if (youtube.newURL != "") {
          print("youtubeURL=" + youtube.newURL);
          newYouTube(youtube.newURL);
          youtube.clean();
          articleTitlesNow.showLoadingItem();

          Future.delayed(Duration.zero, () {
            itemScrollController.scrollTo(
                index: 0,
                duration: Duration(seconds: 2),
                curve: Curves.easeInOutCubic);
          });
        }
        return Scaffold(
            key: _scaffoldKey,
            appBar: ArticleListsAppBar(scaffoldKey: _scaffoldKey),
            drawer: Drawer(child: leftDrawer()),
            endDrawer: Drawer(child: rightDrawer()),
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
                  tooltip: 'need more',
                  child: Icon(Icons.help_outline,
                      color: Theme.of(context).primaryTextTheme.title.color),
                )));
      });
    });
  }

  Widget leftDrawer() {
    return Consumer<OauthInfo>(builder: (context, oauthInfo, _) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppBar(
              //automaticallyImplyLeading: false,
              leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(oauthInfo.avatarURL == null
                        ? "https://ebuoydoc.bigzhu.net/assets/img/ic_launcher_APP.png"
                        : oauthInfo.avatarURL),
                  )),
              actions: <Widget>[Container()],
              centerTitle: true,
              title: Text(
                "Profile",
              )),
          ListTile(
            title: Center(child: Text(oauthInfo.name)),
            subtitle: Center(child: Text(oauthInfo.email)),
          ),
          RaisedButton(
            child: const Text('switch user'),
            onPressed: () => oauthInfo.switchUser(),
          ),
          Text(""),
          Text("version: 1.2.15")
        ],
      );
    });
  }

  Widget rightDrawer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppBar(
            automaticallyImplyLeading: false,
            actions: <Widget>[Container()],
            centerTitle: true,
            title: Text(
              "Settings",
            )),
        ConfigDarkTheme(),
        ConfigAutoPlay(),
        ConfigFilterByPercent(),
        RaisedButton(
          child: const Text('fliter by percent'),
          onPressed: () {
            articleTitles.filterByPercent(
                settings.fromPercent, settings.toPercent);
            Navigator.of(context).pop();
          },
        )
      ],
    );
  }
}
