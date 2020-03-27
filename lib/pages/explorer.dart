import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../components/article_titles_slidable.dart';
import '../models/controller.dart';
import '../models/explorer.dart';
import '../models/article_title.dart';

import '../themes/base.dart';

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
  @override
  initState() {
    super.initState();
    _explorer = Provider.of<Explorer>(context, listen: false);
    _controller = Provider.of<Controller>(context, listen: false);
    this.loadData();
  }

  loadData() async {
    bool hasLocal = await _explorer.getFromLocal();
    if (hasLocal) {
      setState(() {});
      _explorer.syncExplorer();
    } else {
      await _explorer.syncExplorer();
      setState(() {});
    }
  }

  Widget getArticleTitlesBody() {
    return Selector<Explorer, List<ArticleTitle>>(
        selector: (context, explorer) => explorer.titles,
        builder: (context, titles, child) {
          return ScrollablePositionedList.builder(
            itemCount: titles.length,
            itemBuilder: (context, index) {
              return index == 0
                  ? Container()
                  : ArticleTitlesSlidable(
                      articleTitle: titles.reversed.toList()[index],
                      isExplorer: true,
                    );
            },
            itemScrollController: itemScrollController,
            itemPositionsListener: itemPositionListener,
          );
        });
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
          backgroundColor: darkMaterialColor[700],
          body: RefreshIndicator(
            onRefresh: _explorer.syncExplorer,
            child: getArticleTitlesBody(),
            color: mainColor,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _controller.jumpToHome(ArticleTitlesPageIndex);
            },
            child: Icon(Icons.arrow_back),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        )));
  }
}
