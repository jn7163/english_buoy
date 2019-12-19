import 'package:ebuoy/models/article.dart';
import 'package:ebuoy/components/article_richtext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/sentence.dart';
import '../models/word.dart';

// 文章对应的 youtube 图标或者头像
class NotMasteredVocabulary extends StatelessWidget {
  const NotMasteredVocabulary({Key key, @required this.article}) : super(key: key);
  final Article article;

  @override
  Widget build(BuildContext context) {
    List<Word> mustLearnWords = List(); // in NESL
    List<String> mustLearnUnique = List();
    List<Word> needLearnWords = List(); // not in NESL
    List<String> needLearnUnique = List();
    article.sentences.forEach((s) {
      s.words.forEach((w) {
        // not mastered words
        if (!w.learned && w.text.length > 1 && !noNeedBlank.contains(w.text) && hasLetter(w.text)) {
          if (w.level != null && w.level != 0 && !mustLearnUnique.contains(w.text.toLowerCase())) {
            w.belongSentence=s;
            mustLearnWords.add(w);
            mustLearnUnique.add(w.text.toLowerCase());
          } else if (!needLearnUnique.contains(w.text.toLowerCase())) {
            w.belongSentence=s;
            needLearnWords.add(w);
            needLearnUnique.add(w.text.toLowerCase());
          }
        }
      });
    });
    // 排序
    mustLearnWords.sort((a, b) => a.level.toString().compareTo(b.level.toString()));
    return Column(children: [
      Table(
          border: TableBorder.all(color: Colors.black12),
          columnWidths: {1: FlexColumnWidth(2)},
          children: mustLearnWords.map((d) {
            var sentence = Sentence('', [d]);
            return TableRow(children: [
              Center(
                  child: Text(
                d.level.toString(),
                style: Theme.of(context).textTheme.display3,
              )),
              Center(child: ArticleRichText(article: article, sentence: sentence)),
              Center(child: Text("⤵", style: Theme.of(context).textTheme.display3)),
            ]);
          }).toList()),
      Table(
          border: TableBorder.all(color: Colors.black12),
          columnWidths: {1: FlexColumnWidth(2)},
          children: needLearnWords.map((d) {
            var sentence = Sentence('', [d]);
            return TableRow(children: [
              Center(
                  child: Text(
                "--",
                style: Theme.of(context).textTheme.display3,
              )),
              Center(child: ArticleRichText(article: article, sentence: sentence)),
              Center(
                  child: FlatButton(
                      onPressed: () => Scrollable.ensureVisible(d.belongSentence.c),
                      child: Text(
                        "↙",
                        style: Theme.of(context).textTheme.display3,
                      ))),
            ]);
          }).toList()),
    ]);
    /*
    return Consumer<NotMasteredVocabularies>(builder: (context, notMasteredVocabularies, child) {
      return Column(
          children: notMasteredVocabularies.notMasteredVocabularies.entries.map((d) {
        var sentence = Sentence('', [d.value["word"]]);
        return ArticleRichText(article: article, sentence: sentence);
      }).toList());
    });
     */
  }
}
