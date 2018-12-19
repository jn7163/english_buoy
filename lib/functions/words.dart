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
  var lWords = List<TextSpan>(); //存储分割好的单词
  RegExp endWithWrap = new RegExp(r"\n$"); //以换行结尾
  RegExp reg = new RegExp(r"[a-zA-Z]+$");
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
