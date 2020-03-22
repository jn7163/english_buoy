import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/sentence.dart';

class ArticleSentence extends StatelessWidget {
  const ArticleSentence({Key key, @required this.textSpan, this.sentence}) : super(key: key);
  final TextSpan textSpan;
  final Sentence sentence;

  @override
  Widget build(BuildContext context) {
    sentence.c = context;
    return ExcludeSemantics(excluding: true, child: RichText(text: textSpan));
  }
}
