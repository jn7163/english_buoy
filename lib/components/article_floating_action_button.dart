import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article.dart';

class ArticleFloatingActionButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Article article = Provider.of<Article>(context);
    return Visibility(
        visible: article.notMasteredWord != null,
        child: Opacity(
            opacity: 0.4,
            child: FloatingActionButton(
              onPressed: () {
                Scrollable.ensureVisible(article.notMasteredWord.c);
                article.setFindWord(article.notMasteredWord.words[0].text);
                article.setNotMasteredWord(null);
              },
              child: Icon(Icons.arrow_upward,
                  color: Theme.of(context).primaryTextTheme.title.color),
            )));
  }
}
