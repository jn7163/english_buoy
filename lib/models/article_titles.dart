import 'dart:async';

import 'package:flutter/material.dart';
import './article_title.dart';
import './article.dart';
import '../store/store.dart';
import 'package:dio/dio.dart';

class ArticleTitles with ChangeNotifier {
  List<ArticleTitle> articles = [];
  // Set 合集, 用于快速查找添加过的单词
  Set setArticleTitles = Set();
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

  addByArticle(Article article) {
    ArticleTitle articleTitle = ArticleTitle();
    articleTitle.title = article.title;
    articleTitle.id = article.articleID;
    articleTitle.unlearnedCount = 99;
    articleTitle.createdAt = DateTime.now();
    // 新增加的插入到第一位
    this.articles.insert(0, articleTitle);
    this.setArticleTitles.add(articleTitle.title);
    notifyListeners();
  }

  add(ArticleTitle articleTitle) {
    this.articles.add(articleTitle);
    this.setArticleTitles.add(articleTitle.title);
  }

// 根据返回的 json 设置到对象
  setFromJSON(List json) {
    this.articles.clear();
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
