import 'package:flutter/material.dart';

const ArticleTitlesPageIndex = 0;
const ArticlePageViewPageIndex = 1;
const ExplorerPageIndex = 2;

class Controller with ChangeNotifier {
  String snackBarInfo;
  Function retryFuc;
  PageController homePageViewController; // the top PageController to show home sub page
  int homeIndex = 0; // current open main page index
  PageController articlePageViewController; // articles page view
  int articleIndex = 0; // current open article page index

  int selectedArticleID = 0; // current seelected article item
  int jumpTargeArticleID = 0; // want jump to this article
  Controller() {
    if (homePageViewController == null) homePageViewController = PageController(initialPage: 0);
    //if (articlePageViewController == null) articlePageViewController = PageController(initialPage: 0);
  }

  jumpToHome(int index) {
    this.homeIndex = index;
    homePageViewController.jumpToPage(this.homeIndex);
  }

  jumpToArticle(int index) {
    this.articleIndex = index;
    articlePageViewController.jumpToPage(this.articleIndex);
  }

  setSelectedArticleID(int id) {
    print("setSelectedArticleID $id");
    this.selectedArticleID = id;
    notifyListeners();
  }

  showSnackBar(String info, {Function retry}) {
    this.retryFuc = retry;
    this.snackBarInfo = info;
    notifyListeners();
  }
}
