import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';

class ArticleFloatingActionButton extends StatelessWidget {
  //const ArticleFloatingActionButton({Key key, @required this.article})
  //   : super(key: key);
  const ArticleFloatingActionButton(this.article);
  final Article article;
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerRight,
        child: Visibility(
            visible: article.notMasteredWord != null,
            child: Opacity(
                opacity: 0.4,
                child: FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    Scrollable.ensureVisible(article.notMasteredWord.c);
                    article.setFindWord(article.notMasteredWord.words[0].text);
                    article.setNotMasteredWord(null);
                  },
                  child: Icon(Icons.arrow_upward,
                      color: Theme.of(context).primaryTextTheme.title.color),
                ))));
  }
}
