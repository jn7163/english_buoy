import 'dart:async';
import 'package:provider/provider.dart';
import 'package:easy_alert/easy_alert.dart';

import 'package:flutter/material.dart';
import './article_title.dart';
import './article.dart';
import '../store/store.dart';
import 'package:dio/dio.dart';
import '../models/loading.dart';

class ArticleTitles with ChangeNotifier {
  List<ArticleTitle> articleTitles = [];

  // Set 合集, 用于快速查找添加过的单词
  Set setArticleTitles = Set();

  // 和服务器同步
  Future syncServer(BuildContext context) async {
    var allLoading = Provider.of<Loading>(context);
    allLoading.set(true);
    debugPrint("set loading=true");
    Dio dio = getDio(context);
    try {
      var response = await dio.get(Store.baseURL + "article_titles");
      this.setFromJSON(response.data);
      return response;
    } on DioError catch (e) {
      if (e.response != null && e.response.statusCode == 401) {
      } else {
        Alert.toast(context, e.message.toString(),
            position: ToastPosition.bottom, duration: ToastDuration.long);
      }
      return e;
    } finally {
      allLoading.set(false);
      debugPrint("set loading=false");
    }
  }

  setUnlearnedCountByArticleID(int unlearnedCount, int articleID) {
    for (int i = 0; i < articleTitles.length; i++) {
      if (articleTitles[i].id == articleID) {
        articleTitles[i].unlearnedCount = unlearnedCount;
        notifyListeners();
        return;
      }
    }
  }

// 退出清空数据
  clear() {
    this.articleTitles.clear();
    notifyListeners();
  }

  addByArticle(Article article) {
    ArticleTitle articleTitle = ArticleTitle();
    articleTitle.title = article.title;
    articleTitle.id = article.articleID;
    articleTitle.unlearnedCount = article.unlearnedCount;
    articleTitle.createdAt = DateTime.now();
    articleTitle.youtube = article.youtube;
    articleTitle.avatar = article.avatar;
    // 新增加的插入到第一位
    this.articleTitles.insert(0, articleTitle);
    this.setArticleTitles.add(articleTitle.title);
    notifyListeners();
  }

  add(ArticleTitle articleTitle) {
    this.articleTitles.add(articleTitle);
    this.setArticleTitles.add(articleTitle.title);
  }

// 根据返回的 json 设置到对象
  setFromJSON(List json) {
    this.articleTitles.clear();
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
