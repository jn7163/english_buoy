// 文章详情内容
import 'dart:async';

import 'package:flutter/material.dart';
import './article.dart';

class Articles with ChangeNotifier {
  Map articles = Map();
  set(Article article) {
    articles[article.articleID] = article;
    notifyListeners();
  }

  Future addByID(int articleID) async {
    Article article = this.articles[articleID];
    if (article == null) {
      Article newArticle = Article();
      return newArticle
          .getArticleByID(articleID)
          .then((d) => this.set(newArticle));
    }
  }
}
