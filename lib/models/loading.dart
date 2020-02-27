import 'package:flutter/material.dart';

class Loading with ChangeNotifier {
  bool loading = false;
  int _loadingCount = 0;

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
