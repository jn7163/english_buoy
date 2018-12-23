import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import '../bus.dart';
import 'package:clipboard_manager/clipboard_manager.dart';

// getRegistedTextSpacn 获取监听了事件的 textSpan
TextSpan getRegistedTextSpan(String word, int level) {
  return TextSpan(
    text: word,
    style: TextStyle(background: Paint()..color = Color(0xFF3b9c00)),
    recognizer: TapGestureRecognizer()
      ..onTap = () {
        bus.emit('word_clicked', level);
        ClipboardManager.copyToClipBoard(word);
      },
  );
}

TextSpan getTextSpan(String word) {
  return TextSpan(
    text: word,
    style: TextStyle(color: Colors.grey, fontSize: 20),
  );
}

// 从 json 解析出文章
List<TextSpan> createWordsByList(List theWraps) {
  var lWords = List<TextSpan>(); //存储分割好的单词
  for (var i = 0; i < theWraps.length; i++) {
    // 每行开头加入空格
    lWords.add(getTextSpan("    "));
    var words = theWraps[i];
    for (var j = 0; j < words.length; j++) {
      var word = words[j];
      if (word['level'] != 0) {
        // 需要学习的单词
        lWords.add(getRegistedTextSpan(word['text'], word['level']));
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
