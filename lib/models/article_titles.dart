import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import './article_title.dart';
import './article.dart';
import '../store/store.dart';
import 'package:dio/dio.dart';
import './settings.dart';

class ArticleTitles with ChangeNotifier {
  String searchKey = ''; // 过滤关键字
  List<ArticleTitle> filterTitles = []; // 过滤好的列表
  List<ArticleTitle> titles = [];
  int selectedArticleID = 0;
  bool sortByUnlearned = true;

  // show article percent
  Settings settings;

  setSearchKey(String v) {
    searchKey = v;
    filter();
  }

  // init
  ArticleTitles() {
    settings = Settings();
  }

  Future<String> newYouTube(String url) async {
    this.showLoadingItem();
    final String exists = "exists";
    final String noSubtitle = "no_subtitle";
    final String done = "done";
    Dio dio = getDio();
    Response response;
    try {
      response =
          await dio.post(Store.baseURL + "Subtitle", data: {"Youtube": url});
    } on DioError catch (e) {
      this.removeLoadingItem();
      if (e.response != null && e.response.data['error'] == noSubtitle)
        return noSubtitle;
      else
        throw e;
    }

    Article article = Article();
    // 将新添加的文章添加到缓存中
    article.setFromJSON(response.data);
    article.saveToLocal(json.encode(response.data));
    // 设置高亮, 但是不要通知,等待后续来更新
    this.setHighlightArticleNoReset(article.articleID);
    this.removeLoadingItemNoNotify();
    if (response.data[exists]) {
      this.justNotifyListeners();
      return exists;
    } else {
      // 先添加到 titles 加速显示
      this.addArticleTitleByArticle(article);
    }
    return done;
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
    return [lastID, nextID];
  }

  filter() {
    filterTitles = titles;
    if (searchKey != "")
      filterTitles = filterTitles
          .where((d) => d.title.toLowerCase().contains(searchKey.toLowerCase()))
          .toList();
    /*
    if (settings.fromPercent != "" && settings.toPercent != "")
      filterTitles = filterTitles
          .where((d) =>
              (d.percent > double.parse(settings.fromPercent) &&
                  d.percent < double.parse(settings.toPercent)) ||
              d.percent == 0) // show percent 0 used to show loading item
          .toList();
          */
    notifyListeners();
  }

  filterByPercent(String from, String to) async {
    await settings.setFromPercent(from);
    await settings.setToPercent(to);
    filter();
  }

  // Set 合集, 用于快速查找添加过的单词
  Set setArticleTitles = Set();

  setHighlightArticleNoReset(int id) {
    this.selectedArticleID = id;
  }

  setSelectedArticleID(int id) {
    this.selectedArticleID = id;
    notifyListeners();
  }

  // 啥事都不干, 只是通知
  justNotifyListeners() {
    notifyListeners();
  }

  showLoadingItem() {
    ArticleTitle loadingArticleTitle = ArticleTitle();
    loadingArticleTitle.id = -1;
    loadingArticleTitle.title = "Loading new youtube article ......";
    loadingArticleTitle.unlearnedCount = 1;
    loadingArticleTitle.wordCount = 1;
    loadingArticleTitle.loading = true;
    loadingArticleTitle.percent = 0;
    loadingArticleTitle.createdAt = DateTime.now();
    loadingArticleTitle.updatedAt = DateTime.now();
    this.titles.insert(0, loadingArticleTitle);
    filter();
  }

  removeLoadingItemNoNotify() {
    this.titles.removeAt(0);
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
  Future syncArticleTitles() async {
    Dio dio = getDio();
    var response = await dio.get(Store.baseURL + "article_titles");
    this.setFromJSON(response.data);
    // save to local for cache
    saveToLocal(json.encode(response.data));
    return response;
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
    //titles.remove(articleTitle);
    titles.removeWhere((item) => item.id == articleTitle.id);
    filter();
  }

// 退出清空数据
  clear() {
    this.titles.clear();
    filter();
  }

  addArticleTitleByArticle(Article article) {
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
    print("addByArticle");
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
