import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../bus.dart';
// import 'dart:convert';

// getRegistedTextSpacn 获取监听了事件的 textSpan
TextSpan getRegistedTextSpan(String word) {
  return TextSpan(
    text: word,
    recognizer: TapGestureRecognizer()
      ..onTap = () => bus.emit('word_clicked', word),
  );
}

TextSpan getTextSpan(String word) {
  return TextSpan(
    text: word,
    style: TextStyle(color: Colors.grey, fontSize: 20),
  );
}

// 根据不同正则处理, 空格不要加事件
List<TextSpan> createWordsByArticle(String article) {
  var lWords = List<TextSpan>(); //存储分割好的单词
  RegExp endWithWrap = new RegExp(r"\n$"); //以换行结尾
  // RegExp reg = new RegExp(r"[a-zA-Z]+$");
  // 先按换行分割
  var wraps = article.split(new RegExp(r"\n"));
  var theWraps = wraps.map((d) {
    return d + '\n';
  }).toList();

  for (var i = 0; i < theWraps.length; i++) {
    var words = theWraps[i].split(" ");
    for (var j = 0; j < words.length; j++) {
      var word = words[j];
      if (endWithWrap.hasMatch(word)) {
        lWords.add(getRegistedTextSpan(word));
      } else {
        lWords.add(getRegistedTextSpan(word));
        lWords.add(getTextSpan(" "));
      }
    }
  }
  return lWords;
}

// 从 json 解析出文章
List<TextSpan> createWordsByList(List theWraps) {
  var lWords = List<TextSpan>(); //存储分割好的单词
  // var theWraps = jsonDecode(articleJSON);
  for (var i = 0; i < theWraps.length; i++) {
    var words = theWraps[i];
    for (var j = 0; j < words.length; j++) {
      var word = words[j];
      if (word['level'] != 0) {
        // 需要学习的单词
        lWords.add(getRegistedTextSpan(word['text']));
        lWords.add(getTextSpan(' '));
      } else {
        lWords.add(getTextSpan(word['text']));
        lWords.add(getTextSpan(' '));
      }
    }
    // 一句完成, 换行
    lWords.add(getTextSpan("\n"));
  }
  return lWords;
}

RichText getRichText(List article) {
  // var words = createWordsByArticle(article);
  var words = createWordsByList(article);
  return RichText(
    text: TextSpan(
      text: '',
      style: TextStyle(color: Colors.black87, fontSize: 20),
      children: words,
    ),
  );
}
