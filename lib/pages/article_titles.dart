// 文章列表
import 'dart:async';

import 'package:ebuoy/components/article_lists_app_bar.dart';
import 'package:ebuoy/models/search.dart';
import '../scrollable_positioned_list/scrollable_positioned_list.dart';
import '../components/article_youtube_avatar.dart';

import '../models/articles.dart';
import '../models/loading.dart';
import 'package:ebuoy/store/article.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article_titles.dart';
import '../models/article_title.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ArticleTitlesPage extends StatefulWidget {
  ArticleTitlesPage({Key key}) : super(key: key);

  @override
  ArticleTitlesPageState createState() => ArticleTitlesPageState();
}

class ArticleTitlesPageState extends State<ArticleTitlesPage> {
  int _selectedIndex = 0;

  // ScrollController _scrollController = ScrollController();
  StreamSubscription _receiveShareLiveSubscription;
  ArticleTitles articleTitles;
  List<ArticleTitle> filterTitles; // now show list
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionListener = ItemPositionsListener.create();

  @override
  initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      //initReceiveShare();
      // if don't have data, get from server
      // sync from the waiting page, this no need, maybe delete
      articleTitles = Provider.of<ArticleTitles>(context, listen: false);
      if (articleTitles.titles.length == 0) _syncArticleTitles();

      String youtubeURL = ModalRoute.of(context).settings.arguments;
      if (youtubeURL != null) {
        var articles = Provider.of<Articles>(context, listen: false);
        postYouTube(context, youtubeURL, articleTitles, articles).then((d) {
          articleTitles.setSelectedArticleID(d.articleID);
          scrollToSharedItem(articleTitles.selectedArticleID);
        });
      }
    });
  }

  @override
  void dispose() {
    _receiveShareLiveSubscription.cancel();
    super.dispose();
  }

  void receiveShare(String sharedText) {
    if (sharedText == null) return;
    // 收到分享, 先跳转到 list 页面
    // 跳转到 list 页
    String youtubeURL = sharedText;
    Navigator.pushNamed(context, '/ArticleTitles', arguments: youtubeURL);
  }

  Future _syncArticleTitles() async {
    return articleTitles.syncServer(context).catchError((e) {
      if (e.response.statusCode == 401) {
        print("请登录");
        Navigator.pushNamed(context, '/Sign');
      }
    });
  }

  Widget getArticleTitles() {
    return Consumer<Search>(builder: (context, search, child) {
      return Consumer<ArticleTitles>(builder: (context, articleTitles, child) {
        // List<ArticleTitle> filterTitles;
        if (search.key != "") {
          filterTitles = articleTitles.titles
              .where((d) => d.title.toLowerCase().contains(search.key.toLowerCase()))
              .toList();
        } else {
          // filterTitles = articleTitles.titles.where((d) => d.unlearnedCount > 0).toList();
          filterTitles = articleTitles.titles;
        }
        // 判断显示说明文字还是列表
        if (articleTitles.titles.length != 0) {
          return ScrollablePositionedList.builder(
            itemCount: articleTitles.titles.length,
            itemBuilder: (context, index) {
              var d = articleTitles.titles[index];
              return Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                child: Ink(
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
          );

          /*
          return ListView(
            // 收到分享时候, 把分享显示出来
            controller: _scrollController,
            children: filterTitles.map((d) {
              return Ink(
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
                  ));
            }).toList(),
          );
          */
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
  Future<void> scrollToSharedItem(int articleID) async {
    if (articleID == 0) return;
    //找到 id
    for (var i = 0; i < filterTitles.length; i++) {
      if (filterTitles[i].id == articleID) {
        _selectedIndex = i;
        break;
      }
    }
    // 稍微等等, 避免 build 时候滚动
    Future.delayed(Duration.zero, () {
      itemScrollController.scrollTo(
          index: _selectedIndex, duration: Duration(seconds: 2), curve: Curves.easeInOutCubic);
      /*
      if (_scrollController.hasClients) {
        // 先跳到顶部, 再根据计算滚动
        _scrollController.jumpTo(0);
        _scrollController.animateTo((57.0 * _selectedIndex),
            // 100 is the height of container and index of 6th element is 5
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut);
      }
      */
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
          // Navigator.pushNamed(context, '/AddArticle');
          scrollToSharedItem(3754);
        },
        tooltip: 'add article',
        child: Icon(Icons.add, color: Theme.of(context).primaryTextTheme.title.color),
      ),
    );
    return scaffold;
  }

  Future _refresh() async {
    await _syncArticleTitles();
    return;
  }

  _delete(ArticleTitle articleTitle) async {
    await articleTitle.deleteArticle(context);
    articleTitles.removeFromList(articleTitle);
  }
}
