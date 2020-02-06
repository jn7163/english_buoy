import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article_titles.dart';
import './article.dart';

class ArticlePageViewPage extends StatelessWidget {
  ArticlePageViewPage(this.articleID);
  final int articleID;
  int getPageIndexByArticleID(ArticleTitles articleTitles) {
    for (int i = 0; i < articleTitles.filterTitles.length; i++) {
      if (articleTitles.filterTitles[i].id == articleID) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ArticleTitles>(builder: (context, articleTitles, child) {
      return PageView(
          onPageChanged: (d) {
            print(d);
          },
          controller: PageController(
            initialPage: getPageIndexByArticleID(articleTitles),
            keepPage: true,
          ),
          children: articleTitles.filterTitles.map((d) {
            return ArticlePage(initID: d.id);
          }).toList());
    });
  }
}
