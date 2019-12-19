import 'package:ebuoy/models/article.dart';
import 'package:ebuoy/components/article_sentences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/sentence.dart';
import '../models/word.dart';

// 文章对应的 youtube 图标或者头像
class NotMasteredVocabulary extends StatelessWidget {
  const NotMasteredVocabulary({Key key, @required this.article}) : super(key: key);
  final Article article;

  TableRow getTableRow(BuildContext context, String one, String two, String three) {
    TableRow row = TableRow(children: [
      Container(
          height: 34,
          child: Center(
              child: Text(
            one,
            style: Theme.of(context).textTheme.display2,
          ))),
      Container(
          height: 34,
          child: Center(
              child: Text(
            two,
            style: Theme.of(context).textTheme.display2,
          ))),
      Container(
          height: 34,
          child: Center(
              child: Text(
            three,
            style: Theme.of(context).textTheme.display2,
          ))),
    ]);
    return row;
  }

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
            w.belongSentence = s;
            mustLearnWords.add(w);
            mustLearnUnique.add(w.text.toLowerCase());
          } else if ((w.level == null || w.level == 0) &&
              !needLearnUnique.contains(w.text.toLowerCase())) {
            if (w.text == "panic") print(w.level);
            w.belongSentence = s;
            needLearnWords.add(w);
            needLearnUnique.add(w.text.toLowerCase());
          }
        }
      });
    });
    // 排序
    mustLearnWords.sort((b, a) => a.level.toString().compareTo(b.level.toString()));
    List<Word> allWords = mustLearnWords + needLearnWords;
    bool hideSome = false;
    if (allWords.length > 10) {
      hideSome = true;
      allWords = allWords.sublist(0, 10);
    }

    TableRow titleRow = getTableRow(context, "NGSL", "WORDS", "FIND");

    List<TableRow> allWordRows = allWords.map((d) {
      var sentence = Sentence('', [d]);
      return TableRow(children: [
        Container(
            height: 34,
            child: Center(
                child: Text(
              d.level == 0 ? "-" : d.level.toString(),
              style: Theme.of(context).textTheme.display2,
            ))),
        Container(
            height: 34,
            child: Center(child: ArticleSentences(article: article, sentences: [sentence]))),
        Container(
            height: 34,
            child: GestureDetector(
                onTap: () => Scrollable.ensureVisible(d.belongSentence.c),
                child: Icon(
                  Icons.find_in_page,
                  color: Color(0xFF5F8A8B),
                ))),
      ]);
    }).toList();
    TableRow moreRow = getTableRow(context, "...", "...", "...");

    List<TableRow> renderWordRows =
        allWordRows.length != 0 ? [titleRow] + allWordRows : allWordRows;
    if (hideSome) renderWordRows = renderWordRows + [moreRow];

    return Table(
        border: TableBorder.all(color: Colors.teal),
        columnWidths: {1: FlexColumnWidth(2)},
        children: renderWordRows);
  }
}
