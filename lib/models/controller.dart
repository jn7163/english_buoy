import 'package:flutter/material.dart';

class Controller with ChangeNotifier {
  PageController mainPageController; //主页面切换
  int mainSelectedIndex = 0; // 主页当前index
  PageController articlePageController; //article页面切换
  int selectedArticleID = 0;

  //YoutubePlayerController youtubeController;
  setMainPageController(PageController v) {
    this.mainPageController = v;
    //notifyListeners();
  }

  setArticlePageController(PageController v) {
    this.articlePageController = v;
    //notifyListeners();
  }

  setSelectedArticleID(int id) {
    this.selectedArticleID = id;
    //notifyListeners();
  }

  setMainSelectedIndex(int id) {
    this.mainSelectedIndex = id;
    mainPageController.jumpToPage(id);
    print("setMainSelectedIndex=" + id.toString());
    notifyListeners();
  }
  //setYouTube(YoutubePlayerController v) {
  //  youtubeController = v;
  //}
}
