// 文章中的每个文字的结构体
import 'dart:async';
import '../store/store.dart';
import 'package:flutter/material.dart';
import './sentence.dart';

class Word with ChangeNotifier {
  Sentence belongSentence; // 属于哪一个句子
  final String text;
  final int level;
  bool learned;
  int count;

  Word(this.text, [this.level, this.learned = false, this.count = 0]);

  Word.fromJson(Map json)
      : text = json['text'],
        learned = json['learned'],
        level = json['level'],
        count = json['count'];

  Map toJson() => {
        'text': text,
        'learned': learned,
        'count': count,
        'level': level,
      };
  setLearned(bool v) {
    this.learned = v;
    notifyListeners();
  }

// 记录学习状态
  Future putLearned() async {
    // 标记所有单词为对应状态, 并通知
    return dio().put('${Store.baseURL}learned', data: {'word': this.text, 'learned': this.learned});
  }

// 记录学习次数
  Future putLearn() async {
    return dio().put(Store.baseURL + "learn", data: {"word": this.text});
  }
}
