import 'package:flutter/material.dart';
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
  String thumbnailURL;
  double percent;
  bool loading = false;

  setFromJSON(Map json) {
    this.title = json['title'];
    this.id = json['id'];
    this.unlearnedCount = json['unlearned_count'];
    this.createdAt = DateTime.parse(json['CreatedAt']);
    this.updatedAt = DateTime.parse(json['UpdatedAt']);
    this.youtube = json['Youtube'];
    this.avatar = json['Avatar'];
    this.wordCount = json['WordCount'];
    this.thumbnailURL = json['ThumbnailURL'];
    //this.percent = 100-(this.unlearnedCount/this.wordCount)*100;
    setPercent();
  }

  setPercent() {
    this.percent = 100 - (this.unlearnedCount / this.wordCount) * 100;
  }

  // 删除文章
  Future deleteArticle() async {
    try {
      var response = await dio().delete(Store.baseURL + "article/${this.id}");
      return response.data;
    } finally {
      //allLoading.set(false);
    }
  }
}
