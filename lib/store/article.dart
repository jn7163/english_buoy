import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_alert/easy_alert.dart' as toast;
import '../models/article_titles.dart';
import '../models/article.dart';
import '../models/loading.dart';

import 'package:dio/dio.dart';
import './store.dart';

// 提交新的文章进行分析
postArticle(BuildContext context, String article, ArticleTitles articleTitles,
    Loading topLoading) async {
  print("postArticle");
  // 替换奇怪的连写字符串
  article = article.replaceAll("—", "-");
  if (article == "") {
    return "article is null";
  }
  topLoading.set(true);
  try {
    var response = await Store.dio
        .post(Store.baseURL + "analysis", data: {"article": article});
    // 将新添加的文章添加到缓存中
    Article newArticle = Article();
    newArticle.setFromJSON(response.data);
    newArticle.setToLocal(json.encode(response.data));
    // 如果是 update exists, 确保更新手机当前数据
    if (response.data["exists"]) {
      toast.Alert.toast(context, "update article",
          position: toast.ToastPosition.bottom,
          duration: toast.ToastDuration.long);
      // make sure reflash local data
      // await articles.setByID(response.data["id"]);
    } else {
      // 先添加到 titles 加速显示
      articleTitles.addArticleTitleByArticle(newArticle);
    }
    //显示以后, 会计算未读数字, 需要刷新列表
    // await articleTitles.syncServer();
    return response.data;
  } on DioError catch (e) {
    // 如果是已经存在, 那么应该会把 article id 传过来
    if (e.response != null) {
      if (e.response.data is String) {
        toast.Alert.toast(context, e.message.toString(),
            position: toast.ToastPosition.bottom,
            duration: toast.ToastDuration.long);
      } else if (e.response.data['error'] == "already exists") {
        return e.response.data;
      }
    }
  } finally {
    topLoading.set(false);
  }
}

// 根据标题查询文章内容
Future getArticleByID(BuildContext context, int id) async {
  print('getArticleByID: ' + id.toString());
  var response =
      await Store.dio.get(Store.baseURL + "article/" + id.toString());
  // bus.emit('get_article_done', response.data);
  return response.data;
}

Future putUnlearnedCount(
    BuildContext context, int articleID, int unlearnedCount) async {
  if (articleID == 0) {
    return null;
  }
  print('putLearnedCount id=' + articleID.toString());
  print('putLearnedCount unlearnedCount=' + unlearnedCount.toString());
  var response = await Store.dio.put(Store.baseURL + "article/unlearned_count",
      data: {"article_id": articleID, "unlearned_count": unlearnedCount});
  return response;
}
