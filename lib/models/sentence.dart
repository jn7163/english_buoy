// 文章中的每个文字的结构体
import 'package:flutter/material.dart';
import './word.dart';
import '../functions/utility.dart';

class Sentence {
  final String starTime;
  final List<Word> words;
  BuildContext c;
  bool highLight = false;
  RegExp _seekExp = RegExp(r"00[0-9]+\.[0-9]+00");

  Sentence(this.starTime, this.words);
  bool hasSeek() {
    return _seekExp.hasMatch(words[0].text);
  }

  // if play to current time, return true
  bool checkPlayToCurrent(Duration playTime) {
    if (!hasSeek()) {
      this.highLight = false;
      return false;
    }
    Duration sentenceTime = toDuration(this.words[0].text);
    if (sentenceTime.inSeconds != 0 &&
        sentenceTime.inSeconds == playTime.inSeconds)
      this.highLight = true;
    else
      this.highLight = false;
    return this.highLight;
  }

  // if don't have seek time, follow with last
  bool followHighLight() {
    if (hasSeek()) return false;
    this.highLight = true;

    return true;
  }

  Sentence.fromJson(Map json)
      : starTime = json['StarTime'],
        words = (json['Words'] as List).map((d) {
          Word w = Word.fromJson(d);
          return w;
        }).toList();
}
