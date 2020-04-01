import '../models/article.dart';
import './article_sentences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/sentence.dart';
import '../models/word.dart';
import '../functions/article.dart';
import 'article_sentences.dart';

class NotMasteredVocabulary extends StatefulWidget {
  NotMasteredVocabulary(this._article);
  final Article _article;
  @override
  NotMasteredVocabularyState createState() => NotMasteredVocabularyState();
}

class NotMasteredVocabularyState extends State<NotMasteredVocabulary> {
  Article _article;
  List<Word> _mustLearnWords = List(); // in NESL
  List<Word> _needLearnWords = List(); // not in NESL
  List<Word> _allWords = List();
  Map<String, Word> _mustLearnUnique = Map();
  bool _hideSome = false;

  @override
  initState() {
    super.initState();
  }

  //when change aritcle need clear local list
  reset() {
    this.clear();
    _allWords.clear();
    _hideSome = false;
  }

  // keep _allWords state, clear other
  clear() {
    _mustLearnWords.clear();
    _needLearnWords.clear();
    _mustLearnUnique.clear();
  }

  filterMustNeedWords() {
    _mustLearnUnique.clear();
    _article.sentences.forEach((s) {
      s.words.forEach((w) {
        // not mastered words
        if (!w.learned && isNeedLearn(w)) {
          if (w.level != null && w.level != 0 && !_mustLearnUnique.containsKey(w.text.toLowerCase())) {
            w.belongSentence = s;
            _mustLearnWords.add(w);
            _mustLearnUnique[w.text.toLowerCase()] = w;
          } else if ((w.level == null || w.level == 0) && !_mustLearnUnique.containsKey(w.text.toLowerCase())) {
            w.belongSentence = s;
            _mustLearnWords.add(w);
            _mustLearnUnique[w.text.toLowerCase()] = w;
          }
        }
      });
    });
    // if first init
    if (_allWords.length == 0)
      _allWords = _mustLearnWords + _needLearnWords;
    else
      // if update words
      _allWords = updateAllWords(_allWords, _mustLearnWords + _needLearnWords);

    if (_allWords.length > 40) {
      _hideSome = true;
      _allWords = _allWords.sublist(0, 40);
    }
  }

  List<Word> updateAllWords(List<Word> oldWords, List<Word> newWords) {
    //first update to learned then use new update back
    oldWords.forEach((d) {
      d.learned = true;
      return d;
    });

    for (int i = 0; i < oldWords.length; i++) {
      if (_mustLearnUnique.containsKey(oldWords[i].text.toLowerCase())) oldWords[i].learned = false;
    }
    return oldWords;
  }

  TableRow getTableRow({Widget one, Widget two, Widget three}) {
    double p = 6;
    return TableRow(children: [
      Center(child: Padding(padding: EdgeInsets.all(p), child: one)),
      Center(child: Padding(padding: EdgeInsets.all(p), child: two)),
      Center(child: Padding(padding: EdgeInsets.all(p), child: three)),
    ]);
  }

  TableRow getTitleRow() {
    return getTableRow(
      one: Text("NGSL", style: bodyTextStyle),
      two: Text("words(${(_mustLearnWords + _needLearnWords).length})", style: bodyTextStyle),
      three: Text("find", style: bodyTextStyle),
    );
  }

  List<TableRow> getAllWordRows() {
    return _allWords.map((d) {
      Sentence sentence = Sentence('', [d]);
      return getTableRow(
        one: Text(
          d.level == 0 ? "-" : d.level.toString(), style: bodyTextStyle,
          //style: Theme.of(context).textTheme.display2,
        ),
        two: ArticleSentences(
            article: _article, sentences: [sentence], needWordWise: false, crossAxisAlignment: CrossAxisAlignment.baseline),
        three: GestureDetector(
            onTap: () {
              //跳转到文章中这一句
              if (d.belongSentence == null) this.filterMustNeedWords();
              Scrollable.ensureVisible(d.belongSentence.c);
              _article.setFindWord(d.text);
              _article.setNotMasteredWord(sentence);
            },
            child: Icon(
              Icons.find_in_page,
              color: Theme.of(context).primaryColorLight,
            )),
      );
    }).toList();
  }

  List<TableRow> getRenderWordRows() {
    TableRow titleRow = getTitleRow();
    List<TableRow> allWordRows = getAllWordRows();
    TableRow moreRow = getTableRow(
      one: Text("..."),
      two: Text("..."),
      three: Text("..."),
    );

    List<TableRow> renderWordRows = allWordRows.length != 0 ? [titleRow] + allWordRows : allWordRows;
    if (_hideSome) renderWordRows = renderWordRows + [moreRow];
    return renderWordRows;
  }

  @override
  Widget build(BuildContext context) {
    if (_article == null || _article.articleID != widget._article.articleID)
      this.reset();
    else
      this.clear();
    _article = widget._article;
    filterMustNeedWords();
    List<TableRow> renderWordRows = getRenderWordRows();
    return Table(
        border: TableBorder.all(color: Theme.of(context).primaryColorDark, width: 0.4),
        columnWidths: {
          0: IntrinsicColumnWidth(),
          1: FlexColumnWidth(8),
          2: IntrinsicColumnWidth(),
        },
        children: renderWordRows);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //filterMustNeedWords();
  }
}
