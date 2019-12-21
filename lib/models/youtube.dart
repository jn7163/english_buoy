import 'package:flutter/material.dart';

class YouTube with ChangeNotifier {
  String newURL = "";

  set(String url) {
    newURL = url;
    print("set newURL=" + url);
    notifyListeners();
  }

  clean() {
    newURL = "";
  }
}
