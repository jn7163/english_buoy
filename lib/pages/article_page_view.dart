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
          onPageChanged: (i) {
            int articleID = articleTitles.filterTitles[i].id;
            articleTitles.setSelectedArticleID(articleID); // 高亮列表
            Map instanceArticles = articleTitles.instanceArticles;
            if (i - 1 > 0) {
              int lastArticleID = articleTitles.filterTitles[i - 1].id;
              if (instanceArticles[lastArticleID] != null &&
                  instanceArticles[lastArticleID].youtubeController != null)
                instanceArticles[lastArticleID].youtubeController.pause();
            }
            if (i + 1 <= articleTitles.filterTitles.length) {
              int nextArticleID = articleTitles.filterTitles[i + 1].id;
              if (instanceArticles[nextArticleID] != null &&
                  instanceArticles[nextArticleID].youtubeController != null)
                instanceArticles[nextArticleID].youtubeController.pause();
            }
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
