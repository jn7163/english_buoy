import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article_titles.dart';
import './article.dart';
import '../models/controller.dart';

class ArticlePageViewPage extends StatefulWidget {
  ArticlePageViewPage(this.articleID);
  final int articleID;
  final _ArticlePageViewPage _articlePageViewPage = _ArticlePageViewPage();
  @override
  //_ArticlePageViewPage createState() => _articlePageViewPage;
  _ArticlePageViewPage createState() => _ArticlePageViewPage();

  void setShowArticle(int articleID) {
    _articlePageViewPage.setShowArticle(articleID);
  }
}

class _ArticlePageViewPage extends State<ArticlePageViewPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  Controller _controller;
  PageView pageView;
  ArticleTitles articleTitles;
  @override
  void initState() {
    _controller = Provider.of<Controller>(context, listen: false);
    _controller.setArticlePageController(PageController());
    super.initState();
  }

  int getPageIndexByArticleID(int articleID) {
    if (articleID == 0) return 0;
    for (int i = 0; i < this.articleTitles.filterTitles.length; i++) {
      if (articleTitles.filterTitles[i].id == articleID) return i;
    }
    return 0;
  }

  void setShowArticle(int articleID) {
    this
        .pageView
        .controller
        .jumpTo(getPageIndexByArticleID(articleID).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ArticleTitles>(builder: (context, articleTitles, child) {
      this.articleTitles = articleTitles;
      print("build ArticlePageViewPage");
      List<Widget> children = articleTitles.filterTitles.map((d) {
        return ArticlePage(d.id);
      }).toList();
      this.pageView = PageView(
          onPageChanged: (i) {
            //int articleID = articleTitles.filterTitles[i].id;
            // _controller.setSelectedArticleID(articleID); // 高亮列表
            // pause playing youtube video
            print("i=" + i.toString());
            articleTitles.currentArticleIndex = i;
            articleTitles.pauseYouTube();
          },
          controller: _controller.articlePageController,
          children: children);
      return this.pageView;
    });
  }
}
