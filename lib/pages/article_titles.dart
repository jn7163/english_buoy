// 文章列表
import 'dart:async';

import 'package:ebuoy/components/article_lists_app_bar.dart';
import 'package:ebuoy/models/search.dart';

import '../components/article_youtube_avatar.dart';

import '../models/articles.dart';
import '../models/loading.dart';
import 'package:ebuoy/store/article.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article_titles.dart';
import '../models/receive_share.dart';
import '../models/article_title.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ArticleTitlesPage extends StatefulWidget {
  ArticleTitlesPage({Key key}) : super(key: key);

  @override
  ArticleTitlesPageState createState() => ArticleTitlesPageState();
}

class ArticleTitlesPageState extends State<ArticleTitlesPage> {
  int _selectedIndex = 0;
  ScrollController _scrollController = ScrollController();
  StreamSubscription _receiveShareLiveSubscription;

  @override
  initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      initReceiveShare();
      // if don't have data, get from server
      var articles = Provider.of<ArticleTitles>(context, listen: false);
      if (articles.articleTitles.length == 0) _syncArticleTitles();
    });
  }

  @override
  void dispose() {
    _receiveShareLiveSubscription.cancel();
    super.dispose();
  }

  void initReceiveShare() {
    var isReceiveShare = Provider.of<ReceiveShare>(context, listen: false);
    if (isReceiveShare.initialized == false) {
      // For sharing or opening urls/text coming from outside the app while the app is in the memory
      _receiveShareLiveSubscription = ReceiveSharingIntent.getTextStream().listen((String value) {
        receiveShare(value);
        debugPrint("share from app in memory text=" + value);
      }, onError: (err) {
        print("getLinkStream error: $err");
      });
      // For sharing or opening urls/text coming from outside the app while the app is closed
      ReceiveSharingIntent.getInitialText().then((String value) {
        // debugPrint("closed share=" + value);
        receiveShare(value);
      });
      isReceiveShare.done();
    }
  }

  void receiveShare(String sharedText) {
    if (sharedText == null) return;
    // 收到分享, 先跳转到 list 页面
    var articleTitles = Provider.of<ArticleTitles>(context, listen: false);
    var articles = Provider.of<Articles>(context, listen: false);
    // 先过去, 为了显示 loading
    Navigator.pushNamed(context, '/ArticleTitles');
    postYouTube(context, sharedText, articleTitles, articles).then((d) {
      articleTitles.setSelectedArticleID(d.articleID);
      scrollToSharedItem();
    });
    // debugPrint(shared.text);
  }

  Future _syncArticleTitles() async {
    var articles = Provider.of<ArticleTitles>(context, listen: false);
    return articles.syncServer(context).catchError((e) {
      if (e.response.statusCode == 401) {
        print("请登录");
        Navigator.pushNamed(context, '/Sign');
      }
    });
  }

  Widget getArticleTitles() {
    return Consumer<Search>(builder: (context, search, child) {
      return Consumer<ArticleTitles>(builder: (context, articleTitles, child) {
        List<ArticleTitle> filterTitles;
        if (search.key != "") {
          filterTitles = articleTitles.articleTitles
              .where((d) => d.title.toLowerCase().contains(search.key.toLowerCase()))
              .toList();
        } else {
          filterTitles = articleTitles.articleTitles.where((d) => d.unlearnedCount > 0).toList();
        }
        // 判断显示说明文字还是列表
        if (articleTitles.articleTitles.length != 0) {
          return ListView(
            // 收到分享时候, 把分享显示出来
            controller: _scrollController,
            children: filterTitles
                .asMap()
                .map((i, d) {
                  // set index to _selectedIndex, used by scrollToSharedItem
                  if (articleTitles.selectedArticleID == d.id) {
                    _selectedIndex = i;
                    //scrollToSharedItem();
                  }
                  return MapEntry(
                      i,
                      Ink(
                          color: articleTitles.selectedArticleID == d.id
                              ? Theme.of(context).highlightColor
                              : Colors.transparent,
                          child: ListTile(
                            trailing: ArticleYoutubeAvatar(
                              youtubeURL: d.youtube,
                              avatar: d.avatar,
                            ),
                            dense: false,
                            onTap: () {
                              articleTitles.setSelectedArticleID(d.id);
                              Navigator.pushNamed(context, '/Article', arguments: d.id);
                            },
                            leading: Text(d.unlearnedCount.toString(),
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                )),
                            title: Text(d.title), // 用的 TextTheme.subhead
                          )));
                })
                .values
                .toList(),
          );
        }
        return Center(
            child: Container(
                margin: EdgeInsets.only(top: 5.0, left: 5.0, bottom: 5, right: 5),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 96.0,
                    height: 96.0,
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          style: Theme.of(context).textTheme.body1,
                          text: "You can share YouTube ",
                        ),
                        WidgetSpan(
                          child: Icon(
                            FontAwesomeIcons.youtube,
                            color: Colors.red,
                          ),
                        ),
                        TextSpan(
                          style: Theme.of(context).textTheme.body1,
                          text: "  video to here",
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                  ),
                  RichText(
                      text: TextSpan(
                          style: Theme.of(context).textTheme.body1,
                          text: "Or click Add button to add English article"))
                ])));
      });
    });
  }

  // EnsureVisible 不支持 ListView 只有用 50 宽度估算的来 scroll 到分享过来的条目
  Future<void> scrollToSharedItem() async {
    // 稍微等等, 避免 build 时候滚动
    Future.delayed(Duration.zero, () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
            (50.0 * _selectedIndex), // 100 is the height of container and index of 6th element is 5
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("build article titles");
    Scaffold scaffold = Scaffold(
      appBar: ArticleListsAppBar(),
      body: Consumer<Loading>(builder: (context, allLoading, _) {
        return ModalProgressHUD(
            child: RefreshIndicator(onRefresh: _refresh, child: getArticleTitles()),
            inAsyncCall: allLoading.loading);
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/AddArticle');
        },
        tooltip: 'add article',
        child: Icon(Icons.add, color: Theme.of(context).primaryTextTheme.title.color),
      ),
    );
    return scaffold;
  }

  Future _refresh() async {
    // print("刷新了");
    await _syncArticleTitles();
    // print("刷新完成");
    return;
  }
}
