// 文章中的每个文字的结构体
import 'package:flutter/material.dart';
import './word.dart';

class Sentence {
  final String startTime;
  final List<Word> words;
  BuildContext c;
  bool highlight = false;
  Function setStateCallback;

  Sentence(this.startTime, this.words);
  setState() {
    if (setStateCallback != null)
      setStateCallback();
    else
      print("setStateCallback is null!!");
  }

  setHightlight(bool h) {
    if (h != this.highlight) {
      this.highlight = h;
      setState();
    }
  }

  Sentence.fromJson(Map json)
      : startTime = json['StarTime'],
        words = (json['Words'] as List).map((d) {
          Word w = Word.fromJson(d);
          return w;
        }).toList();
  Map<String, dynamic> toJson() => {
        'StarTime': startTime,
        'Words': words,
      };
}
