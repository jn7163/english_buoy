import 'dart:async';
import 'package:flutter/material.dart';
import '../models/article_titles.dart';
import '../models/articles.dart';
import '../models/article.dart';
import '../models/top_loading.dart';

import 'package:dio/dio.dart';
import '../bus.dart';
import './store.dart';

postYouTube(BuildContext context, String youtube, ArticleTitles articleTitles,
    Articles articles, TopLoading topLoading) async {
  Dio dio = getDio(context);
  topLoading.set(true);
  try {
    var response =
        await dio.post(Store.baseURL + "Subtitle", data: {"Youtube": youtube});
    bus.emit('analysis_done', response.data);
    // 将新添加的文章添加到缓存中
    Article newArticle = Article();
    newArticle.setFromJSON(response.data);
    articles.set(newArticle);
    // 如果是 update exists, 确保更新手机当前数据
    if (response.data["exists"]) {
      bus.emit('pop_show', "update article");
    } else {
      // 先添加到 titles 加速显示
      articleTitles.addByArticle(newArticle);
    }
    return response.data;
  } on DioError catch (e) {
    // 如果是已经存在, 那么应该会把 article id 传过来
    if (e.response != null) {
      debugPrint(e.response.toString());
      if (e.response.data is String) {
        bus.emit('pop_show', e.message);
      } else if (e.response.data['error'] == "no subtitle") {
        debugPrint(e.response.data['error']);
        bus.emit('pop_show', "This youbetu don't have en subtitle!");
        return e.response.data;
      }
    }
  } finally {
    topLoading.set(false);
  }
}

// 提交新的文章进行分析
postArticle(BuildContext context, String article, ArticleTitles articleTitles,
    Articles articles, TopLoading topLoading) async {
  Dio dio = getDio(context);
  print("postArticle");
  // 替换奇怪的连写字符串
  article = article.replaceAll("—", "-");
  if (article == "") {
    return "article is null";
  }
  topLoading.set(true);
  try {
    var response =
        await dio.post(Store.baseURL + "analysis", data: {"article": article});
    bus.emit('analysis_done', response.data);
    // 将新添加的文章添加到缓存中
    Article newArticle = Article();
    newArticle.setFromJSON(response.data);
    articles.set(newArticle);
    // 如果是 update exists, 确保更新手机当前数据
    if (response.data["exists"]) {
      bus.emit('pop_show', "update article");
      // make sure refalsh local data
      // await articles.setByID(response.data["id"]);
    } else {
      // 先添加到 titles 加速显示
      articleTitles.addByArticle(newArticle);
    }
    //显示以后, 会计算未读数字, 需要刷新列表
    // await articleTitles.syncServer();
    return response.data;
  } on DioError catch (e) {
    // 如果是已经存在, 那么应该会把 article id 传过来
    if (e.response != null) {
      if (e.response.data is String) {
        bus.emit('pop_show', e.message);
      } else if (e.response.data['error'] == "already exists") {
        return e.response.data;
      }
    }
  } finally {
    topLoading.set(false);
  }
}

// 根据标题查询文章内容
getArticleByID(BuildContext context, int id) async {
  Dio dio = getDio(context);
  print('getArticleByID: ' + id.toString());
  var response = await dio.get(Store.baseURL + "article/" + id.toString());
  // bus.emit('get_article_done', response.data);
  return response.data;
}

Future putUnlearnedCount(
    BuildContext context, int articleID, int unlearnedCount) async {
  Dio dio = getDio(context);
  if (articleID == 0) {
    return null;
  }
  print('putLearnedCount id=' + articleID.toString());
  print('putLearnedCount unlearnedCount=' + unlearnedCount.toString());
  var response = await dio.put(Store.baseURL + "article/unlearned_count",
      data: {"article_id": articleID, "unlearned_count": unlearnedCount});
  bus.emit('put_unlearned_count_done', response.data);
  return response;
}
