import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/sentence.dart';

class ArticleRichText extends StatelessWidget {
  const ArticleRichText({Key key, @required this.textSpan, this.sentence})
      : super(key: key);
  final TextSpan textSpan;
  final Sentence sentence;

  @override
  Widget build(BuildContext context) {
    //print("build $this");
    sentence.c = context;
    return RichText(text: textSpan);
  }
}
