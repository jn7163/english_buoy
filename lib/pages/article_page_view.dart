import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article_titles.dart';
import './article.dart';
import '../models/controller.dart';
import '../models/article_title.dart';

class ArticlePageViewPage extends StatefulWidget {
  @override
  _ArticlePageViewPage createState() => _ArticlePageViewPage();
}

class _ArticlePageViewPage extends State<ArticlePageViewPage> {
  //with AutomaticKeepAliveClientMixin {
  //@override
  //bool get wantKeepAlive => false;
  Controller _controller;
  @override
  void initState() {
    _controller = Provider.of<Controller>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //super.build(context);
    if (_controller.articlePageController == null) return Container();
    return WillPopScope(
      onWillPop: () async {
        if (_controller.mainSelectedIndex == 1) {
          _controller.setMainSelectedIndex(0);
          return false;
        } else
          return true;
      },
      child: Selector<ArticleTitles, List<ArticleTitle>>(
          selector: (context, articleTitles) => articleTitles.filterTitles,
          builder: (context, filterTitles, child) {
            print("build $this Selector");
            return PageView(
                reverse: true,
                onPageChanged: (i) {
                  // used to highlight aritcleTitlePage item
                  _controller.setSelectedArticleID(filterTitles[i].id);
                },
                controller: _controller.articlePageController,
                children: filterTitles.map((d) {
                  return ArticlePage(d.id);
                }).toList());
          }),
    );
  }
}
