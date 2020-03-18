import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import './article_title.dart';
import './article.dart';
import '../store/store.dart';
import 'package:dio/dio.dart';
import './settings.dart';
import 'controller.dart';

class ArticleTitles with ChangeNotifier {
  int currentArticleIndex = -1; // current play article index
  String searchKey = ''; // 过滤关键字
  List<ArticleTitle> filterTitles = []; // 过滤好的列表
  List<ArticleTitle> titles = [];
  bool sortByUnlearned = true;
  // 完成添加后的回调
  Function newYouTubeCallBack;
  // 滚动到顶部
  Function scrollToArticleTitle;

  static const String exists = "exists";
  static const String noSubtitle = "no subtitle";
  static const String done = "done";
  SharedPreferences _prefs;
  // show article percent
  Settings settings;
  Controller controller;
  ArticleTitles() {
    SharedPreferences.getInstance().then((d) {
      _prefs = d;
    });
  }

  setSearchKey(String v) {
    searchKey = v;
    filter();
  }

  // EnsureVisible 不支持 ListView 只有用 50 宽度估算的来 scroll 到分享过来的条目
  bool scrollToSharedItem(String url) {
    bool hasShared = false;
    //整个数据中判断是否已经同步过
    for (int i = 0; i < this.titles.length; i++) {
      if (this.titles[i].youtube == url) {
        hasShared = true;
        break;
      }
    }
    //找到 id
    if (hasShared) {
      for (int i = 0; i < this.filterTitles.length; i++) {
        if (this.filterTitles[i].youtube == url) {
          //this.selectedArticleID = this.filterTitles[i].id;
          controller.selectedArticleID = this.filterTitles[i].id;
          scrollToArticleTitle(this.filterTitles.length - 1 - i);
          this.justNotifyListeners();
          break;
        }
      }
    }
    return hasShared;
  }

  Future newYouTube(String url) async {
    String result;
    if (scrollToSharedItem(url)) {
      result = exists;
      Store.dio.post(Store.baseURL + "Subtitle", data: {"Youtube": url});
      return;
    }
    this.showLoadingItem();
    if (scrollToArticleTitle != null) scrollToArticleTitle(0);

    Response response;
    try {
      response = await Store.dio
          .post(Store.baseURL + "Subtitle", data: {"Youtube": url});
      Article article = Article();
      // 将新添加的文章添加到缓存中
      article.setFromJSON(response.data);
      article.setToLocal(json.encode(response.data));
      // 设置高亮, 但是不要通知,等待后续来更新
      this.controller.selectedArticleID = article.articleID;
      this.removeLoadingItemNoNotify();
      if (response.data[exists]) {
        this.justNotifyListeners();
        result = exists;
      } else {
        // 先添加到 titles 加速显示
        this.addArticleTitleByArticle(article);
        result = done;
      }
      // 只更新本地缓存, 避免下次打开是老的
      syncArticleTitles(justSetToLocal: true);
    } on DioError catch (e) {
      this.removeLoadingItem();
      if (e.response != null) {
        if (e.response.data is String)
          result = e.message.toString() + ": " + e.response.data;
        else
          result = e.response.data['error'];
      }
    }
    if (newYouTubeCallBack != null) newYouTubeCallBack(result);
  }

  // 根据给出的articleID，找到在 filterTitles 中的 前后 articleID
  List<int> findLastNextArticleByID(int id) {
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
    if (settings.filertPercent > 70)
      filterTitles = filterTitles
          .where((d) =>
              d.percent >= settings.filertPercent ||
              d.percent == 0) // show percent 0 used to show loading item
          .toList();
    //hide 100% aritcle
    if (settings.isHideFullMastered)
      filterTitles = filterTitles
          .where((d) =>
              d.percent != 100) // show percent 0 used to show loading item
          .toList();
    notifyListeners();
  }

  filterByPercent(double percent) async {
    await settings.setFilertPercent(percent);
    filter();
  }

  filterHideMastered(bool b) async {
    await settings.setIsHideFullMastered(b);
    filter();
  }

  // 啥事都不干, 只是通知
  justNotifyListeners() {
    print("justNotifyListeners");
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
    //this.titles.insert(0, loadingArticleTitle);
    this.titles.add(loadingArticleTitle);
    filter();
  }

  removeLoadingItemNoNotify() {
    //this.titles.removeAt(0);
    this.titles.removeLast();
  }

  removeLoadingItem() {
    //this.titles.removeAt(0);
    this.titles.removeLast();
    filter();
  }

  changeSort() {
    if (sortByUnlearned) {
      titles.sort((b, a) => b.percent.compareTo(a.percent));
    } else {
      titles.sort((b, a) => b.createdAt.compareTo(a.createdAt));
    }
    sortByUnlearned = !sortByUnlearned;
    filter();
  }

  setToLocal(String data) {
    // 登录后存储到临时缓存中
    _prefs.setString('article_titles', data);
  }

  getFromLocal() async {
    if (_prefs == null) _prefs = await SharedPreferences.getInstance();
    String data = _prefs.getString('article_titles');
    if (data != null) {
      this.setFromJSON(json.decode(data));
    }
  }

  syncArticleTitlesIfNoData() {
    if (this.titles.length == 0) {
      syncArticleTitles();
    }
  }

  // 和服务器同步
  Future syncArticleTitles({bool justSetToLocal = false}) async {
    print("syncArticleTitles");
    Response response = await Store.dio.get(Store.baseURL + "article_titles");
    if (!justSetToLocal) this.setFromJSON(response.data);
    // save to local for cache
    setToLocal(json.encode(response.data));
    return response;
  }

  setUnlearnedCountByArticleID(int unlearnedCount, int articleID) {
    for (int i = 0; i < titles.length; i++) {
      if (titles[i].id == articleID) {
        titles[i].unlearnedCount = unlearnedCount;
        titles[i].setPercent();
        return;
      }
    }
    //filter();
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
    //this.titles.insert(0, articleTitle);
    this.titles.add(articleTitle);
    print("addByArticle");
    filter();
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
    filter();
  }

  int findIndexByArticleID(int articleID) {
    for (int i = 0; i < this.filterTitles.length; i++) {
      if (this.filterTitles[i].id == articleID) return i;
    }
    return -1;
  }
}
