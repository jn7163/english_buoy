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
    var response = await Store.dio.get(Store.baseURL + _key);
    this.setFromJSON(response.data);
    notifyListeners();
    setToLocal(json.encode(response.data));
    return response;
  }

  add(ArticleTitle articleTitle) {
    this.titles.add(articleTitle);
  }

// 根据返回的 json 设置到对象
  setFromJSON(List json) {
    this.titles.clear();
    json.forEach((d) {
      ArticleTitle articleTitle = ArticleTitle();
      articleTitle.setFromJSON(d);
      add(articleTitle);
    });

    //print("syncExplorer this.titles.length=" + this.titles.length.toString());
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
