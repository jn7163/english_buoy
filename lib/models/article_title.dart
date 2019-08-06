import 'package:flutter/material.dart';

class ArticleTitle with ChangeNotifier {
  String title;
  DateTime createdAt;
  int id;
  int unlearnedCount;
  String youtube;
  setFromJSON(Map json) {
    this.title = json['title'];
    this.id = json['id'];
    this.unlearnedCount = json['unlearned_count'];
    this.createdAt = DateTime.parse(json['created_at']);
    this.youtube = json['Youtube'];
  }
}
