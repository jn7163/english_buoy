import 'package:ebuoy/models/article.dart';
import 'package:ebuoy/components/article_sentences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/sentence.dart';
import '../models/word.dart';
import '../functions/article.dart';

// 文章对应的 youtube 图标或者头像
class NotMasteredVocabulary extends StatelessWidget {
  const NotMasteredVocabulary({Key key, @required this.article}) : super(key: key);
  final Article article;

  TableRow getTableRow({Widget one, Widget two, Widget three}) {
    /*
    TableRow row = TableRow(children: [
      Center(
          child: Text(
        one,
        style: Theme.of(context).textTheme.display2,
      )),
      Center(
          child: Text(
        two,
        style: Theme.of(context).textTheme.display2,
      )),
      Center(
          child: Text(
        three,
        style: Theme.of(context).textTheme.display2,
      )),
    ]);
    return row;
     */
    double p = 6;
    return TableRow(children: [
      Center(child: Padding(padding: EdgeInsets.all(p), child: one)),
      Center(child: Padding(padding: EdgeInsets.all(p), child: two)),
      Center(child: Padding(padding: EdgeInsets.all(p), child: three)),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    List<Word> mustLearnWords = List(); // in NESL
    List<String> mustLearnUnique = List();
    List<Word> needLearnWords = List(); // not in NESL
    article.sentences.forEach((s) {
      s.words.forEach((w) {
        // not mastered words
        if (!w.learned && isNeedLearn(w)) {
          if (w.level != null && w.level != 0 && !mustLearnUnique.contains(w.text.toLowerCase())) {
            w.belongSentence = s;
            mustLearnWords.add(w);
            mustLearnUnique.add(w.text.toLowerCase());
          } else if ((w.level == null || w.level == 0) &&
              !mustLearnUnique.contains(w.text.toLowerCase())) {
            w.belongSentence = s;
            mustLearnWords.add(w);
            mustLearnUnique.add(w.text.toLowerCase());
          }
        }
      });
    });
    List<Word> allWords = mustLearnWords + needLearnWords;
    TextStyle titleStyle = Theme.of(context).textTheme.display2;
    TableRow titleRow = getTableRow(
      one: Text("NGSL", style: titleStyle),
      two: Text("WORDS(" + allWords.length.toString() + ")", style: titleStyle),
      three: Text("FIND", style: titleStyle),
    );
    bool hideSome = false;
    if (allWords.length > 100) {
      hideSome = true;
      allWords = allWords.sublist(0, 100);
    }

    List<TableRow> allWordRows = allWords.map((d) {
      var sentence = Sentence('', [d]);
      // double p = 6;
      return getTableRow(
        one: Text(
          d.level == 0 ? "-" : d.level.toString(),
          style: Theme.of(context).textTheme.display2,
        ),
        two: ArticleSentences(
            article: article,
            sentences: [sentence],
            crossAxisAlignment: CrossAxisAlignment.baseline),
        three: GestureDetector(
            onTap: () => Scrollable.ensureVisible(d.belongSentence.c),
            child: Icon(
              Icons.find_in_page,
              color: Color(0xFF5F8A8B),
            )),
      );
    }).toList();
    TableRow moreRow = getTableRow(
      one: Text("...", style: titleStyle),
      two: Text("...", style: titleStyle),
      three: Text("...", style: titleStyle),
    );

    List<TableRow> renderWordRows =
        allWordRows.length != 0 ? [titleRow] + allWordRows : allWordRows;
    if (hideSome) renderWordRows = renderWordRows + [moreRow];

    return Table(
        border: TableBorder.all(color: Colors.teal),
        columnWidths: {
          0: IntrinsicColumnWidth(),
          1: FlexColumnWidth(8),
          2: IntrinsicColumnWidth(),
        },
        children: renderWordRows);
  }
}
