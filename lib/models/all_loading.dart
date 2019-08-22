import 'package:flutter/material.dart';

class AllLoading with ChangeNotifier {
  bool loading = false;
  bool articleTitlesLoading = false;
  setArticleTitlesLoading(bool loading) {
    this.articleTitlesLoading = loading;
    notifyListeners();
  }

  set(bool loading) {
    this.loading = loading;
    notifyListeners();
  }
}
