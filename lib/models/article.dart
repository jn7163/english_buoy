// 文章详情内容
import 'package:flutter/material.dart';
import 'dart:async';

import './word.dart';
import 'package:dio/dio.dart';
import '../store/store.dart';

class Article {
  int unlearnedCount;
  int articleID;
  // 文章中的文字内容
  List words = [];
  // 标题
  String title;
  String youtube;
  String avatar;
  // 从 json 中设置
  setFromJSON(Map json) {
    this.articleID = json['id'];
    this.title = json['title'];
    this.youtube = json['Youtube'];
    this.words = json['words'].map((d) => Word.fromJson(d)).toList();
    this.unlearnedCount = json['UnlearnedCount'];
    this.avatar = json['Avatar'];
    // notifyListeners();
  }

  clear() {
    this.youtube = '';
    this.title = '';
    this.words.clear();
    // notifyListeners();
  }

  // 从服务器获取
  Future getArticleByID(BuildContext context, int articleID) async {
    this.articleID = articleID;
    Dio dio = getDio(context);
    var response =
        await dio.get(Store.baseURL + "article/" + this.articleID.toString());

    // debugPrint(response.data.toString());
    this.setFromJSON(response.data);
    // 获取以后, 就计算一遍未读数, 然后提交
    // this._putUnlearnedCount(context);
    return response;
  }

  // 更新提交未学会单词数
  Future _putUnlearnedCount(BuildContext context) async {
    if (articleID == null) {
      return null;
    }
    // 重新计算未掌握单词数
    unlearnedCount = this
        .words
        .map((d) {
          if (!d.learned) {
            return d.text;
          }
        })
        .toSet()
        .length;
    unlearnedCount--;
    // 设置本地的列表
    Dio dio = getDio(context);
    var response = await dio.put(Store.baseURL + "article/unlearned_count",
        data: {"article_id": articleID, "unlearned_count": unlearnedCount});
    return response;
  }

// 设置当前文章这个单词的学习状态
  _setWordIsLearned(String word, bool isLearned) {
    this.words.forEach((d) {
      if (d.text.toLowerCase() == word.toLowerCase()) {
        d.learned = isLearned;
      }
    });
    // notifyListeners();
  }

// 增加学习次数
  increaseLearnCount(String word) {
    this.words.forEach((d) {
      if (d.text.toLowerCase() == word.toLowerCase()) {
        d.count++;
      }
    });
  }

  // 记录学习状态
  Future putLearned(BuildContext context, Word word) async {
    // 标记所有单词为对应状态, 并通知
    this._setWordIsLearned(word.text, word.learned);
    return word.putLearned(context).then((d) => _putUnlearnedCount(context));
  }
}
