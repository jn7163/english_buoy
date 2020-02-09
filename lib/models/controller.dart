import 'package:flutter/material.dart';

class Controller with ChangeNotifier {
  PageController mainPageController; //主页面切换
  int mainSelectedIndex = 0; // 主页当前index
  PageController articlePageController; //article页面切换
  int selectedArticleID = 0;
  int pageSelectedIndex = 0;
  Controller() {
    if (mainPageController == null)
      mainPageController = PageController(initialPage: 0);
  }

  setSelectedArticleID(int id) {
    this.selectedArticleID = id;
    //notifyListeners();
  }

  setPageSelectedIndex(int id) {
    pageSelectedIndex = id;
    if (articlePageController == null) {
      articlePageController = PageController(initialPage: pageSelectedIndex);
      notifyListeners();
    }
    articlePageController.jumpToPage(pageSelectedIndex);
  }

  setMainSelectedIndex(int id) {
    this.mainSelectedIndex = id;
    mainPageController.jumpToPage(id);
    notifyListeners();
  }
  //setYouTube(YoutubePlayerController v) {
  //  youtubeController = v;
  //}
}
