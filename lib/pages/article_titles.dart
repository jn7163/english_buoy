// 文章列表
import 'dart:async';

import 'package:loading_overlay/loading_overlay.dart';

import '../models/articles.dart';
import 'package:ebuoy/store/article.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter/material.dart';
import 'package:provide/provide.dart';
import '../components/oauth_info.dart';
import '../models/article_titles.dart';
import '../models/all_loading.dart';
import '../models/receive_share.dart';
import '../models/article_title.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
//import 'package:share/share.dart';

class ArticlesPage extends StatefulWidget {
  ArticlesPage({Key key}) : super(key: key);

  @override
  _ArticlesPageState createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  TextEditingController _searchQuery = new TextEditingController();
  bool _isSearching = false;
  String _searchText = "";
  int _selectArticleID = 0;
  StreamSubscription _receivelShareLiveSubscription;
  initState() {
    super.initState();
    //enableShareReceiving();
    print('init articles');
    // 需要初始化后才能使用 context
    Future.delayed(Duration.zero, () {
      initReceiveShare();
      _syncArticleTitles();
    });
    _searchQuery.addListener(() {
      if (!_isSearching) {
        _searchQuery.text = "";
      }
      if (_searchQuery.text.isNotEmpty) {
        setState(() {
          // _isSearching = true;
          _searchText = _searchQuery.text;
          // debugPrint(_sharedText);
        });
      }
    });
  }

  @override
  void dispose() {
    _receivelShareLiveSubscription.cancel();
    super.dispose();
  }

  void initReceiveShare() {
    var isReceiveShare = Provide.value<ReceiveShare>(context);
    if (isReceiveShare.initialized == false) {
      // For sharing or opening urls/text coming from outside the app while the app is in the memory
      _receivelShareLiveSubscription =
          ReceiveSharingIntent.getTextStream().listen((String value) {
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
    var articleTitles = Provide.value<ArticleTitles>(context);
    var articles = Provide.value<Articles>(context);
    // 获取完成,再跳到详情页面
    postYouTube(context, sharedText, articleTitles, articles);
    // debugPrint(shared.text);
    // 收到分享, 先跳转到 list 页面
    Navigator.pushNamed(context, '/Articles');
  }

  Future _syncArticleTitles() async {
    var articles = Provide.value<ArticleTitles>(context);
    return articles.syncServer(context).catchError((e) {
      if (e.response.statusCode == 401) {
        print("请登录");
        Navigator.pushNamed(context, '/Sign');
      }
    });
  }

  Widget getArticleTitles() {
    return Provide<ArticleTitles>(builder: (context, child, articleTitles) {
      List<ArticleTitle> filterTiltes;
      if (_isSearching) {
        filterTiltes = articleTitles.articleTitles
            .where((d) =>
                d.title.toLowerCase().contains(_searchText.toLowerCase()))
            .toList();
      } else {
        filterTiltes = articleTitles.articleTitles
            .where((d) => d.unlearnedCount > 0)
            .toList();
      }
      // 应该用 loading 判断是否显示 loading
      if (articleTitles.articleTitles.length != 0) {
        return ListView(
          children: filterTiltes.map((d) {
            return Ink(
                color: this._selectArticleID == d.id
                    ? Colors.blueGrey[50]
                    : Colors.transparent,
                child: ListTile(
                  trailing: Visibility(
                      visible: d.youtube == '' ? false : true,
                      child: d.avatar == ''
                          ? Icon(
                              FontAwesomeIcons.youtube,
                              color: Colors.red,
                            )
                          : CircleAvatar(
                              backgroundImage: NetworkImage(d.avatar),
                            )),
                  dense: false,
                  onTap: () {
                    this._selectArticleID = d.id;
                    Navigator.pushNamed(context, '/Article', arguments: d.id);
                  },
                  leading: Text(d.unlearnedCount.toString(),
                      style: TextStyle(
                          color: Colors.teal[700],
                          fontSize: 16,
                          fontFamily: "NotoSans-Medium")),
                  title: Text(d.title),
                ));
          }).toList(),
        );
      }
      return Center(
          child: Container(
              margin: EdgeInsets.only(top: 5.0, left: 5.0, bottom: 5, right: 5),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                            style: TextStyle(color: Colors.black, fontSize: 14),
                            text: "You can share YouTube ",
                          ),
                          WidgetSpan(
                            child: Icon(
                              FontAwesomeIcons.youtube,
                              color: Colors.red,
                            ),
                          ),
                          TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: 14),
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
                            style: TextStyle(color: Colors.black, fontSize: 14),
                            text: "Or click Add button to add English article"))
                  ])));
      /*else {
        return SpinKitChasingDots(
          color: Colors.blueGrey,
          size: 50.0,
        );
      }
      */
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                autofocus: true, // 自动对焦
                decoration: null, // 不要有下划线
                cursorColor: Colors.white,
                controller: _searchQuery,
                style: TextStyle(
                  color: Colors.white,
                ),
              )
            : Text(
                "The Articles",
                style: TextStyle(color: Colors.white),
              ),
        actions: <Widget>[
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            tooltip: 'go to articles',
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
              });
            },
          ),
          OauthInfoWidget(),
        ],
      ),
      body: Provide<AllLoading>(builder: (context, child, allLoading) {
        return LoadingOverlay(
            child: Container(
                // margin: EdgeInsets.only(top: 10.0, left: 10.0, bottom: 10, right: 10),
                child: RefreshIndicator(
                    onRefresh: _refresh, child: getArticleTitles())),
            isLoading: allLoading.articleTitlesLoading,
            progressIndicator: const CircularProgressIndicator());
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/AddArticle');
        },
        tooltip: 'add article',
        child: Icon(Icons.add),
      ),
    );
  }

  Future _refresh() async {
    // print("刷新了");
    await _syncArticleTitles();
    // print("刷新完成");
    return;
  }
}
