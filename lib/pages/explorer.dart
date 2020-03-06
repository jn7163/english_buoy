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
import '../models/explorer.dart';

import '../functions/utility.dart';
import '../themes/base.dart';

class ExplorerPage extends StatefulWidget {
  ExplorerPage({Key key}) : super(key: key);

  @override
  ExplorerPageState createState() => ExplorerPageState();
}

class ExplorerPageState extends State<ExplorerPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  Explorer _articleTitles;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionListener =
      ItemPositionsListener.create();
  Controller _controller;
  @override
  initState() {
    super.initState();
    _articleTitles = Provider.of<Explorer>(context, listen: false);
    _controller = Provider.of<Controller>(context, listen: false);
    syncArticleTitles();
  }

  Future syncArticleTitles() async {
    return _articleTitles.syncArticleTitles();
  }

  Widget getArticleTitlesBody() {
    return Consumer<Explorer>(builder: (context, articleTitles, child) {
      var body;
      if (articleTitles.titles.length == 0)
        body = Container();
      else
        body = ScrollablePositionedList.builder(
          itemCount: articleTitles.titles.length,
          itemBuilder: (context, index) {
            return ArticleTitlesSlidable(
                articleTitle: articleTitles.titles.reversed.toList()[index]);
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
          inAsyncCall: articleTitles.titles.length == 0);
    });
  }

  Future refresh() async {
    await syncArticleTitles();
    return;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("build ArticleTitlesPage");
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
          _controller.setMainSelectedIndex(0);
        },
        child: Icon(Icons.arrow_back),
      ),
    );
  }
}
