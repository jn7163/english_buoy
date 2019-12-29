import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_alert/easy_alert.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import './article_title.dart';
import './article.dart';
import '../store/store.dart';
import 'package:dio/dio.dart';

class ArticleTitles with ChangeNotifier {
  String searchKey = ''; // 过滤关键字
  List<ArticleTitle> filterTitles = []; // 过滤好的列表
  List<ArticleTitle> titles = [];
  int selectedArticleID = 0;
  bool sortByUnlearned = true;

  setSearchKey(String v) {
    searchKey = v;
    filter();
  }

  // 根据给出的id，找到在 filterTitles 中的 index
   findLastNextArticleByID(int id) {
    int index, lastID, nextID;
    for (int i = 0; i < filterTitles.length; i++) {
      if (filterTitles[i].id == id) {
        index = i;
        break;
      }
    }
    if (index != 0)
      lastID = filterTitles[index - 1].id;
    else
      lastID = null;
    if (index != filterTitles.length - 1)
      nextID = filterTitles[index + 1].id;
    else
      nextID = null;
    return [lastID,nextID];
  }

  filter() {
    if (searchKey != "") {
      filterTitles =
          titles.where((d) => d.title.toLowerCase().contains(searchKey.toLowerCase())).toList();
    } else {
      filterTitles = titles;
    }
    notifyListeners();
  }

  // Set 合集, 用于快速查找添加过的单词
  Set setArticleTitles = Set();

  setSelectedArticleID(int id) {
    this.selectedArticleID = id;
    notifyListeners();
  }

  showLoadingItem() {
    var loadingArticleTitle = ArticleTitle();
    loadingArticleTitle.id = -1;
    loadingArticleTitle.title = "loading new youtube article ......";
    loadingArticleTitle.unlearnedCount = 1;
    loadingArticleTitle.unlearnedCount = 1;
    loadingArticleTitle.wordCount = 1;
    loadingArticleTitle.deleting = true;
    loadingArticleTitle.setPercent();
    this.titles.insert(0, loadingArticleTitle);
    filter();
  }

  removeLoadingItem() {
    this.titles.removeAt(0);
    filter();
  }

  changeSort() {
    if (sortByUnlearned) {
      titles.sort((a, b) => b.percent.compareTo(a.percent));
    } else {
      titles.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    sortByUnlearned = !sortByUnlearned;
    filter();
  }

  saveToLocal(String data) async {
    // 登录后存储到临时缓存中
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('article_titles', data);
  }

  getFromLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = prefs.getString('article_titles');
    if (data != null) {
      this.setFromJSON(json.decode(data));
    }
  }

  // 和服务器同步
  Future syncServer(BuildContext context) async {
    Dio dio = getDio(context);
    try {
      var response = await dio.get(Store.baseURL + "article_titles");
      this.setFromJSON(response.data);
      // save to local for cache
      saveToLocal(json.encode(response.data));
      return response;
    } on DioError catch (e) {
      if (e.response != null && e.response.statusCode == 401) {} else {
        Alert.toast(context, e.message.toString(),
            position: ToastPosition.bottom, duration: ToastDuration.long);
      }
      return e;
    } finally {}
  }

  setUnlearnedCountByArticleID(int unlearnedCount, int articleID) {
    for (int i = 0; i < titles.length; i++) {
      if (titles[i].id == articleID) {
        titles[i].unlearnedCount = unlearnedCount;
        titles[i].setPercent();
        filter();
        return;
      }
    }
  }

  removeFromList(ArticleTitle articleTitle) {
    titles.remove(articleTitle);
    filter();
  }

// 退出清空数据
  clear() {
    this.titles.clear();
    filter();
  }

  addByArticle(Article article) {
    ArticleTitle articleTitle = ArticleTitle();
    articleTitle.title = article.title;
    articleTitle.id = article.articleID;
    articleTitle.unlearnedCount = article.unlearnedCount;
    articleTitle.createdAt = DateTime.now();
    articleTitle.youtube = article.youtube;
    articleTitle.avatar = article.avatar;
    articleTitle.wordCount = article.wordCount;
    articleTitle.setPercent();
    // 新增加的插入到第一位
    this.titles.insert(0, articleTitle);
    this.setArticleTitles.add(articleTitle.title);
    filter();
  }

  add(ArticleTitle articleTitle) {
    this.titles.add(articleTitle);
    this.setArticleTitles.add(articleTitle.title);
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
    filter();
  }
}
