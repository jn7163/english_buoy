import 'package:ebuoy/models/article.dart';
import 'package:ebuoy/components/article_richtext.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../models/sentence.dart';
import '../models/not_mastered_vocabularis.dart';

// 文章对应的 youtube 图标或者头像
class NotMasteredVocabulary extends StatelessWidget {
  const NotMasteredVocabulary({Key key, @required this.article}) : super(key: key);
  final Article article;

  @override
  Widget build(BuildContext context) {
    return Consumer<NotMasteredVocabularies>(builder: (context, notMasteredVocabularies, child) {
      return Column(
          children: notMasteredVocabularies.notMasteredVocabularies.entries.map((d) {
        var sentence = Sentence('', [d.value["word"]]);
        return ArticleRichText(article: article, sentence: sentence);
      }).toList());
    });
  }
}
