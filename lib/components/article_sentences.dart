import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './article_sentence.dart';
import '../models/article.dart';

class ArticleSentences extends StatelessWidget {
  const ArticleSentences({Key key, @required this.article}) : super(key: key);
  final Article article;

  @override
  Widget build(BuildContext context) {
    //只有一个单词时候不要用 Column封装,避免位置上移
    //if (sentences.length == 1) return ArticleSentence(widget.sentences[0]);
    List<Widget> richTextList = article.sentences.map((s) {
      return ArticleSentence(
        article: article,
        sentence: s,
      );
    }).toList();

    return Column(children: richTextList, crossAxisAlignment: CrossAxisAlignment.start);
  }
}
