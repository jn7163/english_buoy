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

ArticleTitle getLoadingArticle() {
  ArticleTitle loadingArticleTitle = ArticleTitle();
  loadingArticleTitle.id = -1;
  loadingArticleTitle.title = "☕ 🍕   loading new youtube article ......";
  loadingArticleTitle.unlearnedCount = 1;
  loadingArticleTitle.wordCount = 1;
  loadingArticleTitle.loading = true;
  loadingArticleTitle.percent = 0;
  loadingArticleTitle.createdAt = DateTime.now();
  loadingArticleTitle.updatedAt = DateTime.now();
  return loadingArticleTitle;
}

class ArticleTitles with ChangeNotifier {
  String searchKey = ''; // 过滤关键字
  //List<ArticleTitle> filterTitles = []; // 过滤好的列表
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
    notifyListeners();
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

  Future<bool> newYouTube(String url) async {
    String result;
    if (scrollToSharedItem(url)) {
      result = exists;
      Store.dio.post(Store.baseURL + "Subtitle", data: {"Youtube": url});
      return true;
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
      return true;
    } on DioError catch (e) {
      this.removeLoadingItem();
      if (e.response != null) {
        if (e.response.data is String)
          result = e.message.toString() + ": " + e.response.data;
        else
          result = e.response.data['error'];
      }
      return false;
    } finally {
      if (newYouTubeCallBack != null) newYouTubeCallBack(result);
    }
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

  List<ArticleTitle> get filterTitles {
    // must make new list otherwise Selector will not trigger
    //List<ArticleTitle> _filterTitles = [...this.titles];
    List<ArticleTitle> _filterTitles = this.titles;
    if (searchKey != "")
      _filterTitles = _filterTitles
          .where((d) => d.title.toLowerCase().contains(searchKey.toLowerCase()))
          .toList();
    if (settings.filertPercent > 70)
      _filterTitles = _filterTitles
          .where((d) =>
              d.percent >= settings.filertPercent ||
              d.percent == 0) // show percent 0 used to show loading item
          .toList();
    //hide 100% aritcle
    if (settings.isHideFullMastered)
      _filterTitles = _filterTitles
          .where((d) =>
              d.percent != 100) // show percent 0 used to show loading item
          .toList();
    return _filterTitles;
  }

  filterByPercent(double percent) async {
    await settings.setFilertPercent(percent);
    notifyListeners();
  }

  filterHideMastered(bool b) async {
    await settings.setIsHideFullMastered(b);
    notifyListeners();
  }

  // 啥事都不干, 只是通知
  justNotifyListeners() {
    print("justNotifyListeners");
    notifyListeners();
  }

  showLoadingItem() {
    this.titles = [...this.titles];
    this.titles.add(getLoadingArticle());
    notifyListeners();
  }

  removeLoadingItemNoNotify() {
    //this.titles.removeAt(0);
    this.titles.removeLast();
  }

  removeLoadingItem() {
    //this.titles.removeAt(0);
    this.titles = [...this.titles];
    this.titles.removeLast();
    notifyListeners();
  }

  changeSort() {
    if (sortByUnlearned) {
      titles.sort((b, a) => b.percent.compareTo(a.percent));
    } else {
      titles.sort((b, a) => b.createdAt.compareTo(a.createdAt));
    }
    sortByUnlearned = !sortByUnlearned;
    notifyListeners();
  }

  setToLocal(String data) {
    // 登录后存储到临时缓存中
    _prefs.setString('article_titles', data);
  }

  Future<bool> getFromLocal() async {
    var prefs = await Store.prefs;
    String data = prefs.getString('article_titles');
    if (data != null) {
      this.setFromJSON(json.decode(data));
      return true;
    }
    return false;
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
  }

  removeFromList(ArticleTitle articleTitle) {
    this.titles = [...this.titles];
    titles.removeWhere((item) => item.id == articleTitle.id);
    notifyListeners();
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
    //need use new list to trigger Selector
    this.titles = [...this.titles];
    this.titles.add(articleTitle);
    print("addByArticle");
    notifyListeners();
  }

// 根据返回的 json 设置到对象
  setFromJSON(List json) {
    // must create new List for provider Selector
    this.titles = List<ArticleTitle>();
    json.forEach((d) {
      ArticleTitle articleTitle = ArticleTitle();
      articleTitle.setFromJSON(d);
      this.titles.add(articleTitle);
      // this.articles.add(articleTitle);
      // this.setArticleTitles.add(articleTitle.title);
    });
    notifyListeners();
  }

  int findIndexByArticleID(int articleID) {
    for (int i = 0; i < this.filterTitles.length; i++) {
      if (this.filterTitles[i].id == articleID) return i;
    }
    return -1;
  }
}
