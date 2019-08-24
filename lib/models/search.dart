import 'package:flutter/material.dart';

class Search with ChangeNotifier {
  String key = '';

  set(String v) {
    debugPrint(v);
    this.key = v;
    notifyListeners();
  }
}
