import 'package:flutter/material.dart';

class Controller with ChangeNotifier {
  PageController mainPageController;
  int mainSelectedIndex = 0; // current open main page index

  PageController articlePageController;
  int pageSelectedIndex = 0;

  int selectedArticleID = 0; // current seelected article item
  Controller() {
    if (mainPageController == null)
      mainPageController = PageController(initialPage: 0);
  }

  setSelectedArticleID(int id) {
    debugPrint("setSelectedArticleID=" + id.toString());
    this.selectedArticleID = id;
    //notifyListeners will make articleTitlesPage rebuild
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
