import 'dart:async';
import 'package:flutter/material.dart';
import './article_title.dart';
import '../store/store.dart';
import 'package:dio/dio.dart';

class Explorer with ChangeNotifier {
  List<ArticleTitle> titles = [];

  // 和服务器同步
  Future syncArticleTitles() async {
    Dio dio = getDio();
    var response = await dio.get(Store.baseURL + "explorer");
    this.setFromJSON(response.data);
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
}
