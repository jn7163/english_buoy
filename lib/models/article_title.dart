import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../store/store.dart';

class ArticleTitle with ChangeNotifier {
  String title;
  DateTime createdAt;
  DateTime updatedAt;
  int id;
  int unlearnedCount;
  int wordCount;
  String youtube;
  String avatar;
  double percent;
  bool deleting=false;

  setFromJSON(Map json) {
    this.title = json['title'];
    this.id = json['id'];
    this.unlearnedCount = json['unlearned_count'];
    this.createdAt = DateTime.parse(json['CreatedAt']);
    this.updatedAt = DateTime.parse(json['UpdatedAt']);
    this.youtube = json['Youtube'];
    this.avatar = json['Avatar'];
    this.wordCount = json['WordCount'];
    //this.percent = 100-(this.unlearnedCount/this.wordCount)*100;
    setPercent();
  }
  setPercent(){
    this.percent = 100-(this.unlearnedCount/this.wordCount)*100;
  }

  // 删除文章
  Future deleteArticle(BuildContext context) async {
    //var allLoading = Provider.of<Loading>(context);
    //allLoading.set(true);

    Dio dio = getDio(context);
    print('deleteArticle: ' + this.id.toString());

    try {
      var response = await dio.delete(Store.baseURL + "article/" + this.id.toString());
      return response.data;
    } finally {
      //allLoading.set(false);
    }
  }
}
