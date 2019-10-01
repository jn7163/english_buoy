import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../store/store.dart';
import '../models/loading.dart';
import 'package:provider/provider.dart';

class ArticleTitle with ChangeNotifier {
  String title;
  DateTime createdAt;
  int id;
  int unlearnedCount;
  String youtube;
  String avatar;

  setFromJSON(Map json) {
    this.title = json['title'];
    this.id = json['id'];
    this.unlearnedCount = json['unlearned_count'];
    this.createdAt = DateTime.parse(json['created_at']);
    this.youtube = json['Youtube'];
    this.avatar = json['Avatar'];
  }

  // 删除文章
  Future deleteArticle(BuildContext context) async {
    var allLoading = Provider.of<Loading>(context);
    allLoading.set(true);

    Dio dio = getDio(context);
    print('deleteArticle: ' + this.id.toString());

    try {
      var response = await dio.delete(Store.baseURL + "article/" + this.id.toString());
      return response.data;
    } finally {
      allLoading.set(false);
    }
  }
}
