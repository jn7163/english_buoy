import 'package:flutter/material.dart';

class TopLoading with ChangeNotifier {
  bool loading = false;
  set(bool loading) {
    this.loading = loading;
    notifyListeners();
  }
}
