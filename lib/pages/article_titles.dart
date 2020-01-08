// 文章列表
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'package:ebuoy/components/config_autoplay.dart';
import 'package:ebuoy/components/config_dark_theme.dart';

import 'package:ebuoy/components/article_titles_app_bar.dart';
import 'package:ebuoy/models/youtube.dart';
import 'package:ebuoy/themes/bright.dart';

import 'package:flutter_widgets/flutter_widgets.dart';

import '../components/article_youtube_avatar.dart';

import '../models/loading.dart';
import 'package:ebuoy/store/article.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article_titles.dart';
import '../models/oauth_info.dart';
import '../models/article_title.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
  final ItemPositionsListener itemPositionListener = ItemPositionsListener.create();
  Loading loading;

  @override
  initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      loading = Provider.of<Loading>(context);
      articleTitles = Provider.of<ArticleTitles>(context, listen: false);
      if (articleTitles.titles.length == 0) {
        articleTitles.getFromLocal();
        await _syncArticleTitles();
      }
      String youtubeURL = ModalRoute.of(context).settings.arguments;
      if (youtubeURL != null) {
        print("youtubeURL=" + youtubeURL);
        articleTitles.showLoadingItem();
        syncFromServer(youtubeURL);
      }
    });
  }

  Future syncFromServer(url) async {
    print("url=" + url);
    return postYouTube(context, url, articleTitles).then((d) {
      scrollToSharedItem(articleTitles.selectedArticleID);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _syncArticleTitles() async {
    return articleTitles.syncServer(context).catchError((e) {
      print("_syncArticleTitles get e" + e.toString());
      if (e.response.statusCode == 401) {
        OauthInfo oauthInfo = Provider.of<OauthInfo>(context, listen: false);
        oauthInfo.signIn().then((d) {
          _syncArticleTitles();
        });
        // Navigator.pushNamed(context, '/Sign');
      }
    });
  }

  Widget getArticleTitlesBody() {
    return Consumer<ArticleTitles>(builder: (context, articleTitles, child) {
      return articleTitles.filterTitles.length > 0
          ? ScrollablePositionedList.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: articleTitles.filterTitles.length,
              itemBuilder: (context, index) {
                var d = articleTitles.filterTitles[index];
                return Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  child: Ink(
                      color: articleTitles.selectedArticleID == d.id
                          ? Theme.of(context).highlightColor
                          : Colors.transparent,
                      child: ListTile(
                        trailing: ArticleYoutubeAvatar(
                            youtubeURL: d.youtube, avatar: d.avatar, loading: d.deleting),
                        dense: false,
                        onTap: () {
                          articleTitles.setSelectedArticleID(d.id);
                          Navigator.pushNamed(context, '/Article', arguments: d.id);
                        },
                        leading: Text(
                            d.percent.toStringAsFixed(
                                    d.percent.truncateToDouble() == d.percent ? 0 : 1) +
                                "%",
                            style: TextStyle(
                              color: Colors.blueGrey,
                            )),
                        title: Text(d.title), // 用的 TextTheme.subhead
                      )),
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: 'Delete',
                      color: Colors.red,
                      icon: Icons.delete,
                      onTap: () => _delete(d),
                    ),
                  ],
                );
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
          index: _selectedIndex, duration: Duration(seconds: 2), curve: Curves.easeInOutCubic);
    });
  }

  Future _refresh() async {
    await _syncArticleTitles();
    return;
  }

  _delete(ArticleTitle articleTitle) async {
    setState(() {
      articleTitle.deleting = true;
    });
    await articleTitle.deleteArticle(context);
    articleTitles.removeFromList(articleTitle);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<YouTube>(builder: (context, youtube, child) {
      return Consumer<ArticleTitles>(builder: (context, articleTitlesNow, child) {
        if (youtube.newURL != "") {
          print("youtubeURL=" + youtube.newURL);
          syncFromServer(youtube.newURL);
          youtube.clean();
          articleTitlesNow.showLoadingItem();

          Future.delayed(Duration.zero, () {
            itemScrollController.scrollTo(
                index: 0, duration: Duration(seconds: 2), curve: Curves.easeInOutCubic);
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
      ],
    );
  }
}
