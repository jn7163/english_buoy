import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:async';

import '../components/article_titles_slidable.dart';
import '../models/controller.dart';
import '../models/explorer.dart';
import '../models/article_title.dart';

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
  Explorer _explorer;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionListener =
      ItemPositionsListener.create();
  Controller _controller;
  @override
  initState() {
    super.initState();
    _explorer = Provider.of<Explorer>(context, listen: false);
    _controller = Provider.of<Controller>(context, listen: false);
    _explorer.getFromLocal();
    syncExplorer();
  }

  Future syncExplorer() async {
    return _explorer.syncExplorer();
  }

  Widget getArticleTitlesBody() {
    return Selector<Explorer, List<ArticleTitle>>(
        shouldRebuild: (previous, next) => previous == next,
        selector: (context, explorer) => explorer.titles,
        builder: (context, titles, child) {
          var body;
          if (titles.length == 0)
            body = Container();
          else
            body = ScrollablePositionedList.builder(
              itemCount: titles.length,
              itemBuilder: (context, index) {
                return ArticleTitlesSlidable(
                    articleTitle: titles.reversed.toList()[index]);
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
              inAsyncCall: titles.length == 0);
        });
  }

  Future refresh() async {
    await syncExplorer();
    return;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("build ArticleTitlesPage");
    return WillPopScope(
        onWillPop: () async {
          if (_controller.mainSelectedIndex == 3) {
            _controller.setMainSelectedIndex(0);
            return false;
          } else
            return true;
        },
        child: SafeArea(
            child: Scaffold(
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
        )));
  }
}
