// 文章详情内容
import 'dart:async';
import 'dart:convert';
//import '../youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../functions/article.dart';
import '../functions/word.dart';
import './sentence.dart';
import './word.dart';
import '../store/store.dart';
import '../store/wordwise.dart';

class Article with ChangeNotifier {
  YoutubePlayerController youtubeController;
  String findWord = ""; //在文章中查找的单词
  int unlearnedCount;
  int articleID;
  Sentence notMasteredWord; // 尚未掌握的table中的单词, 用来滚回去
  Function setStateCallback; //beacause setStateCallback not work, must use callBack replace

  // 文章中的文字内容
  // List words = [];
  List<Sentence> sentences = List();

  // 标题
  String title;
  String youtube;
  String avatar;
  String thumbnailURL;
  int wordCount;

  setState() {
    if (setStateCallback != null) setStateCallback();
  }

  setNotMasteredWord(Sentence v) {
    notMasteredWord = v;
    setState();
  }

  setYouTube(YoutubePlayerController v) {
    youtubeController = v;
    notifyListeners();
  }

  setFindWord(String findWord) {
    this.findWord = findWord;
    setState();
    // just show 1 seconds
    Future.delayed(Duration(seconds: 1), () {
      this.findWord = "";
      setState();
    });
  }

  // 从 json 中设置
  setFromJSON(Map json) async {
    this.articleID = json['id'];
    this.title = json['title'];
    this.youtube = json['Youtube'];
    this.sentences = (json['Sentences'] as List).map((d) {
      if (d['Words'] != null) {
        return Sentence.fromJson(d);
      }
      return Sentence("", []);
    }).toList();
    this.unlearnedCount = json['UnlearnedCount'];
    this.avatar = json['Avatar'];
    this.wordCount = json['WordCount'];
    this.thumbnailURL = json['ThumbnailURL'];
  }

  queryWordWise() async {
    for (var i = 0; i < this.sentences.length; i++) {
      for (var j = 0; j < this.sentences[i].words.length; j++) {
        Word word = this.sentences[i].words[j];
        if (isNeedLearn(word) && word.learned == false) {
          await getDefinitionByWord(word.text.toLowerCase());
        }
      }
    }
  }

  updateLocal() {
    this.setToLocal(jsonEncode(this));
  }

  // trans to json string
  Map<String, dynamic> toJson() => {
        'id': this.articleID,
        'title': this.title,
        'Youtube': this.youtube,
        'Sentences': this.sentences,
        'UnlearnedCount': this.unlearnedCount,
        'Avatar': this.avatar,
        'WordCount': this.wordCount,
      };

  setToLocal(String data) async {
    // 登录后存储到临时缓存中
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('article_${this.articleID}', data);
  }

  Future<bool> getFromLocal(int articleID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String data = prefs.getString('article_${this.articleID}');
    if (data != null) {
      this.setFromJSON(json.decode(data));
      return true;
    }
    return false;
  }

  // 从服务器获取
  // justUpdateLocal 仅更新本地缓存, 避免延迟导致页面内容错乱
  Future getArticleByID(int articleID) async {
    this.articleID = articleID;
    var response = await dio().get(Store.baseURL + "article/${this.articleID}");

    this.setFromJSON(response.data);
    this.setToLocal(json.encode(response.data));
    return response;
  }

  updateWordStatusProcess(Word word) {
    this.setAllWordStatus(word.text, word.learned);
    this.recomputeUnmastered();
  }

  bool recomputeUnmastered() {
    bool isChange = this.computeUnmasteredCount();
    this.putUnlearnedCount();
    this.updateLocal();
    return isChange;
  }

  bool computeUnmasteredCount() {
    bool isChange = false;
    // 重新计算未掌握单词数
    Set<String> words = Set();
    this.sentences.forEach((sentence) {
      sentence.words.forEach((word) {
        keepWordHasSameStat(word);
        if (!word.learned && isNeedLearn(word)) {
          //print("unmastered: ${word.text}");
          words.add(word.text.toLowerCase());
        }
      });
    });
    if (unlearnedCount != words.length) isChange = true;
    this.unlearnedCount = words.length;
    return isChange;
  }

  // 更新文章未掌握单词数
  Future putUnlearnedCount() {
    computeUnmasteredCount();
    return dio().put(Store.baseURL + "article/unlearned_count",
        data: {"article_id": articleID, "unlearned_count": this.unlearnedCount});
  }

// 设置当前文章这个单词的学习状态
  setAllWordStatus(String word, bool isLearned) {
    for (final sentence in this.sentences) {
      sentence.words.forEach((w) {
        if (w.text.toLowerCase() == word.toLowerCase()) w.learned = isLearned;
      });
    }
    setState();
  }

// 增加学习次数
  increaseLearnCount(String word) {
    for (int i = 0; i < this.sentences.length; i++) {
      this.sentences[i].words.forEach((d) {
        if (d.text.toLowerCase() == word.toLowerCase()) {
          d.count++;
        }
      });
    }
  }
}
