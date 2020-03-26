import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './article_title.dart';
import '../store/store.dart';

import 'dart:convert';

class Explorer with ChangeNotifier {
  String _key = "explorer";
  List<ArticleTitle> titles = [];
  SharedPreferences _prefs;
  Explorer() {
    SharedPreferences.getInstance().then((d) {
      _prefs = d;
    });
  }
  // 和服务器同步
  Future syncExplorer() async {
    var response = await dio().get(Store.baseURL + _key);
    this.setFromJSON(response.data);
    notifyListeners();
    this.setToLocal(json.encode(response.data));
    return response;
  }

  removeFromList(ArticleTitle articleTitle) {
    this.titles = [...this.titles];
    this.titles.removeWhere((item) => item.id == articleTitle.id);
    notifyListeners();
  }

// 根据返回的 json 设置到对象
  setFromJSON(List json) {
    this.titles = List<ArticleTitle>();
    json.forEach((d) {
      ArticleTitle articleTitle = ArticleTitle();
      articleTitle.setFromJSON(d);
      this.titles.add(articleTitle);
    });

    notifyListeners();
  }

  setToLocal(String data) {
    _prefs.setString(_key, data);
  }

  Future<bool> getFromLocal() async {
    var prefs = await Store.prefs;
    String data = prefs.getString(_key);
    if (data != null) {
      this.setFromJSON(json.decode(data));
      return true;
    }
    return false;
  }
}
