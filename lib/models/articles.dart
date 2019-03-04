import 'package:flutter/material.dart';
import './article_title.dart';

class Articles with ChangeNotifier {
  // 存储文章对象
  List<ArticleTitle> articles = [];
  // Set 合集, 用于快速查找添加过的单词
  Set setArticleTitles = Set();
  set(List<ArticleTitle> articles) {
    this.articles = articles;
    notifyListeners();
  }

  clear() {
    this.articles.clear();
    notifyListeners();
  }

  setFromJSON(List json) {
    json.forEach((d) {
      ArticleTitle articleTitle = ArticleTitle();
      articleTitle.setFromJSON(d);
      this.articles.add(articleTitle);
      this.setArticleTitles.add(articleTitle.title);
    });
    notifyListeners();
  }
}
