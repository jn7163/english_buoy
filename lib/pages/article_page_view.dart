import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article_titles.dart';
import './article.dart';
import '../models/controller.dart';

class ArticlePageViewPage extends StatefulWidget {
  ArticlePageViewPage(this.articleID);
  final int articleID;
  @override
  _ArticlePageViewPage createState() => _ArticlePageViewPage();
}

class _ArticlePageViewPage extends State<ArticlePageViewPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  Controller _controller;
  ArticleTitles articleTitles;
  @override
  void initState() {
    _controller = Provider.of<Controller>(context, listen: false);
    _controller.setArticlePageController(PageController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return WillPopScope(
      onWillPop: () async {
        if (_controller.mainSelectedIndex == 1) {
          _controller.setMainSelectedIndex(0);
          return false;
        } else
          return true;
      },
      child: Consumer<ArticleTitles>(builder: (context, articleTitles, child) {
        this.articleTitles = articleTitles;
        print("build ArticlePageViewPage");
        List<Widget> children = articleTitles.filterTitles.map((d) {
          return ArticlePage(d.id);
        }).toList();
        return PageView(
            onPageChanged: (i) {
              //int articleID = articleTitles.filterTitles[i].id;
              // _controller.setSelectedArticleID(articleID); // 高亮列表
              articleTitles.currentArticleIndex = i;
              articleTitles.pauseYouTube();
            },
            controller: _controller.articlePageController,
            children: children);
      }),
    );
  }
}
