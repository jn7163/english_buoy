import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article_titles.dart';
import './article.dart';
import 'article_titles.dart';

class ArticlePageViewPage extends StatefulWidget {
  ArticlePageViewPage(this.articleID);
  final int articleID;
  final _ArticlePageViewPage _articlePageViewPage = _ArticlePageViewPage();
  @override
  _ArticlePageViewPage createState() => _articlePageViewPage;

  void setShowArticle(int articleID) {
    _articlePageViewPage.setShowArticle(articleID);
  }
}

class _ArticlePageViewPage extends State<ArticlePageViewPage> {
  PageView pageView;
  ArticleTitles articleTitles;
  @override
  void initState() {
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
    return Consumer<ArticleTitles>(builder: (context, articleTitles, child) {
      this.articleTitles = articleTitles;
      print("build ArticlePageViewPage");
      List<Widget> children = articleTitles.filterTitles.map((d) {
        return ArticlePage(initID: d.id);
      }).toList();
      this.pageView = PageView(
          onPageChanged: (i) {
            int articleID = articleTitles.filterTitles[i].id;
            articleTitles.setSelectedArticleID(articleID); // 高亮列表
            // pause playing youtube video
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
            initialPage: getPageIndexByArticleID(widget.articleID),
            keepPage: true,
          ),
          children: children);
      return this.pageView;
    });
  }
}
