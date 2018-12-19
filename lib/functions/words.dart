import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../bus.dart';

// getRegistedTextSpacn 获取监听了事件的 textSpan
TextSpan getRegistedTextSpan(String word) {
  return TextSpan(
    text: word,
    recognizer: TapGestureRecognizer()
      ..onTap = () => bus.emit('word_clicked', word),
  );
}

TextSpan getTextSpan(String word) {
  return TextSpan(text: word);
}

// 根据不同正则处理, 空格不要加事件
List<TextSpan> createWordsByArticle(String article) {
  RegExp reg = new RegExp(r"[a-zA-Z]+$");
  RegExp p = new RegExp(r"[,|.|?|!]$");
  var words = article.split(" ");
  var lWords = List<TextSpan>();
  for (var i = 0; i < words.length; i++) {
    var word = words[i];
    if (reg.hasMatch(word)) {
      // 是否完全是字母
      lWords.add(getRegistedTextSpan(word));
    } else if (p.hasMatch(word)) {
      // 结尾有标点的情况
      var theP = word[word.length - 1];
      word = word.replaceFirst(theP, "");
      lWords.add(getRegistedTextSpan(word));
      lWords.add(getTextSpan(theP));
    } else {
      lWords.add(getTextSpan(word));
    }
    lWords.add(getTextSpan(" "));
  }
  return lWords;
}

RichText getRichText(String article) {
  var words = createWordsByArticle(article);
  return RichText(
    text: TextSpan(
      text: '',
      style: TextStyle(color: Colors.black87, fontSize: 20),
      children: words,
    ),
  );
}
