import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article_titles.dart';
import './article.dart';
import '../models/controller.dart';
import '../models/article_title.dart';

class ArticlePageViewPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //super.build(context);
    return WillPopScope(
      onWillPop: () async {
        Controller _controller = Provider.of<Controller>(context, listen: false);
        if (_controller.homeIndex != ArticleTitlesPageIndex) {
          _controller.jumpToHome(ArticleTitlesPageIndex);
          return false;
        } else
          return true;
      },
      child: Selector<ArticleTitles, List<ArticleTitle>>(
          selector: (context, articleTitles) => articleTitles.filterTitles,
          builder: (context, filterTitles, child) {
            Controller _controller = Provider.of<Controller>(context, listen: false);
            ArticleTitles _articleTitles = Provider.of<ArticleTitles>(context, listen: false);
            _controller.articlePageViewController = PageController(initialPage: _controller.articleIndex);
            return PageView(
                reverse: true,
                onPageChanged: (i) {
                  // is reversed to need change
                  _articleTitles.scrollToArticleTitle(_articleTitles.filterTitles.length - i - 1);
                  _controller.setSelectedArticleID(filterTitles[i].id);
                }, // used to highlight aritcleTitlePage item
                controller: _controller.articlePageViewController,
                children: filterTitles
                    .map((d) => ArticlePage(
                          key: ValueKey(d.id),
                          articleID: d.id,
                          articleTitle: d,
                        ))
                    .toList());
          }),
    );
  }
}
