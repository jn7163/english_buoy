import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_alert/easy_alert.dart' as toast;
import 'package:rflutter_alert/rflutter_alert.dart';
import '../models/article_titles.dart';
import '../models/articles.dart';
import '../models/article.dart';
import '../models/loading.dart';

import 'package:dio/dio.dart';
import './store.dart';
import 'package:provider/provider.dart';
// import 'package:easy_alert/easy_alert.dart';

Future<Article> postYouTube(
    BuildContext context, String youtube, ArticleTitles articleTitles, Articles articles) async {
  var allLoading = Provider.of<Loading>(context);
  Dio dio = getDio(context);
  allLoading.set(true);
  try {
    var response = await dio.post(Store.baseURL + "Subtitle", data: {"Youtube": youtube});
    // 将新添加的文章添加到缓存中
    Article newArticle = Article();
    newArticle.setFromJSON(response.data);
    articles.set(newArticle);
    // 如果是 update exists, 确保更新手机当前数据
    if (response.data["exists"]) {
      toast.Alert.toast(context, "update article",
          position: toast.ToastPosition.bottom, duration: toast.ToastDuration.long);
    } else {
      // 先添加到 titles 加速显示
      articleTitles.addByArticle(newArticle);
    }
    // 跳转到添加的那个详情
    // debugPrint("to articleID=" + newArticle.articleID.toString());
    // Navigator.pushNamed(context, '/Article', arguments: newArticle.articleID);
    return newArticle;
  } on DioError catch (e) {
    // 如果是已经存在, 那么应该会把 article id 传过来
    if (e.response != null) {
      if (e.response.data is String) {
        toast.Alert.toast(context, e.message.toString(),
            position: toast.ToastPosition.bottom, duration: toast.ToastDuration.long);
      } else if (e.response.data['error'] == "no subtitle") {
        debugPrint(e.response.data['error']);
        // return e.response.data;
        Alert(
          context: context,
          type: AlertType.info,
          title: "Sorry",
          desc: "This YouTube video don't have any en subtitle!",
          buttons: [
            DialogButton(
              child: Text(
                "Ok",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => Navigator.pop(context),
              width: 120,
            )
          ],
        ).show();
      }
    }
    throw e;
  } finally {
    allLoading.set(false);
  }
}

// 提交新的文章进行分析
postArticle(BuildContext context, String article, ArticleTitles articleTitles, Articles articles,
    Loading topLoading) async {
  Dio dio = getDio(context);
  print("postArticle");
  // 替换奇怪的连写字符串
  article = article.replaceAll("—", "-");
  if (article == "") {
    return "article is null";
  }
  topLoading.set(true);
  try {
    var response = await dio.post(Store.baseURL + "analysis", data: {"article": article});
    // 将新添加的文章添加到缓存中
    Article newArticle = Article();
    newArticle.setFromJSON(response.data);
    articles.set(newArticle);
    // 如果是 update exists, 确保更新手机当前数据
    if (response.data["exists"]) {
      toast.Alert.toast(context, "update article",
          position: toast.ToastPosition.bottom, duration: toast.ToastDuration.long);
      // make sure reflash local data
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
        toast.Alert.toast(context, e.message.toString(),
            position: toast.ToastPosition.bottom, duration: toast.ToastDuration.long);
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
  Dio dio = getDio(context);
  print('getArticleByID: ' + id.toString());
  var response = await dio.get(Store.baseURL + "article/" + id.toString());
  // bus.emit('get_article_done', response.data);
  return response.data;
}

Future putUnlearnedCount(BuildContext context, int articleID, int unlearnedCount) async {
  Dio dio = getDio(context);
  if (articleID == 0) {
    return null;
  }
  print('putLearnedCount id=' + articleID.toString());
  print('putLearnedCount unlearnedCount=' + unlearnedCount.toString());
  var response = await dio.put(Store.baseURL + "article/unlearned_count",
      data: {"article_id": articleID, "unlearned_count": unlearnedCount});
  return response;
}


