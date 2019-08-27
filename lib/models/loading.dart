import 'package:flutter/material.dart';

class Loading with ChangeNotifier {
  bool loading = false;
  int _loadingCount = 0;

  /*
  bool articleTitlesLoading = false;
  setArticleTitlesLoading(bool loading) {
    this.articleTitlesLoading = loading;
    debugPrint(
        "this.articleTitlesLoading=" + this.articleTitlesLoading.toString());
    notifyListeners();
  }
   */

  set(bool loading) {
    if (loading) {
      this._loadingCount++;
      this.loading = loading;
      notifyListeners();
    } else {
      this._loadingCount--;
      if (this._loadingCount == 0) {
        this.loading = loading;
        notifyListeners();
      }
    }
    //this.loading = loading;
  }
}
