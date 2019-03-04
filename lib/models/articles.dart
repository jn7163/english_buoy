import 'dart:async';

import 'package:flutter/material.dart';
import './article_title.dart';
import '../store/store.dart';
import 'package:dio/dio.dart';

class Articles with ChangeNotifier {
  // 存储文章对象
  List<ArticleTitle> articles = [];
  // Set 合集, 用于快速查找添加过的单词
  Set setArticleTitles = Set();
  //set(List<ArticleTitle> articles) {
  //  this.articles = articles;
  //  notifyListeners();
  //}
  // 和服务器同步
  Future syncServer() async {
    Dio dio = getDio();
    var response = await dio.get(Store.baseURL + "article_titles");
    this.setFromJSON(response.data);
    return response;
  }

// 退出清空数据
  clear() {
    this.articles.clear();
    notifyListeners();
  }

// 根据返回的 json 设置到对象
  setFromJSON(List json) {
    this.articles.clear();
    json.forEach((d) {
      ArticleTitle articleTitle = ArticleTitle();
      articleTitle.setFromJSON(d);
      this.articles.add(articleTitle);
      this.setArticleTitles.add(articleTitle.title);
    });
    notifyListeners();
  }
}
