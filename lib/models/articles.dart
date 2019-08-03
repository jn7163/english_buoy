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

// always set data
  Future setByID(BuildContext context, int articleID) async {
    Article newArticle = Article();
    return newArticle
        .getArticleByID(context, articleID)
        .then((d) => this.set(newArticle));
  }

// is not exists add, else do nothing
  Future addByID(BuildContext context, int articleID) async {
    Article article = this.articles[articleID];
    if (article == null) {
      return this.setByID(context, articleID);
    }
  }
}
