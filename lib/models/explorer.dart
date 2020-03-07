import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './article_title.dart';
import '../store/store.dart';
import 'package:dio/dio.dart';

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
    Dio dio = getDio();
    var response = await dio.get(Store.baseURL + _key);
    this.setFromJSON(response.data);
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
      // this.articles.add(articleTitle);
      // this.setArticleTitles.add(articleTitle.title);
    });

    notifyListeners();
  }

  setToLocal(String data) {
    _prefs.setString(_key, data);
  }

  getFromLocal() async {
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();
    String data = _prefs.getString(_key);
    if (data != null) {
      this.setFromJSON(json.decode(data));
    }
  }
}
