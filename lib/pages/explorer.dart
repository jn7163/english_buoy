import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../components/article_titles_slidable.dart';
import '../components/articles_bottom_app_bar.dart';
import '../models/controller.dart';
import '../models/explorer.dart';
import '../models/article_title.dart';
import '../models/oauth_info.dart';

import '../themes/base.dart';

import '../functions/utility.dart';

class ExplorerPage extends StatefulWidget {
  ExplorerPage({Key key}) : super(key: key);

  @override
  ExplorerPageState createState() => ExplorerPageState();
}

class ExplorerPageState extends State<ExplorerPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  Explorer _explorer;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionListener = ItemPositionsListener.create();
  Controller _controller;
  bool _loading = false;
  @override
  initState() {
    super.initState();
    _explorer = Provider.of<Explorer>(context, listen: false);
    _controller = Provider.of<Controller>(context, listen: false);
    this.loadData();
  }

  loadData() async {
    bool hasLocal = await _explorer.getFromLocal();
    if (hasLocal)
      loadFromServer();
    else
      await loadFromServer(showLoading: true);
  }

  Future loadFromServer({bool showLoading = false}) async {
    if (showLoading)
      setState(() {
        _loading = true;
      });
    await _explorer.syncExplorer().catchError((e) {
      String errorInfo = "";
      if (isAccessTokenError(e)) {
        errorInfo = "Login expired";
        Provider.of<OauthInfo>(context, listen: false).signIn();
      } else {
        errorInfo = e.toString();
        if (errorInfo.contains('Connection terminated during handshake'))
          _controller.showSnackBar("Failed to load explor article titles.",
              retry: () => loadFromServer(showLoading: showLoading));
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

  Widget getArticleTitlesBody() {
    return Selector<Explorer, List<ArticleTitle>>(
        selector: (context, explorer) => explorer.titles,
        builder: (context, titles, child) {
          return ListView(
              children: titles
                  .map((d) => ArticleTitlesSlidable(
                        key: ValueKey(d.id),
                        articleTitle: d,
                        isExplorer: true,
                      ))
                  .toList());
        });
  }

  Widget body() {
    return ModalProgressHUD(
        color: darkMaterialColor[700],
        opacity: 1,
        progressIndicator: getSpinkitProgressIndicator(context, color: Colors.white),
        dismissible: true,
        child: RefreshIndicator(
          onRefresh: _explorer.syncExplorer,
          child: VisibilityDetector(
            key: UniqueKey(),
            onVisibilityChanged: (d) {
              if (d.visibleFraction == 1) _explorer.syncExplorer();
            },
            child: getArticleTitlesBody(),
          ),
          color: mainColor,
        ),
        inAsyncCall: _loading);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return WillPopScope(
        onWillPop: () async {
          if (_controller.homeIndex != ArticleTitlesPageIndex) {
            _controller.jumpToHome(ArticleTitlesPageIndex);
            return false;
          } else
            return true;
        },
        child: SafeArea(
            child: Scaffold(
          bottomNavigationBar: ArticlesBottomAppBar(),
          backgroundColor: darkMaterialColor[700],
          body: body(),
          /*
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _controller.jumpToHome(ArticleTitlesPageIndex);
            },
            child: Icon(Icons.arrow_back),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          */
        )));
  }
}
