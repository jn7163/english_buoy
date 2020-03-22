import 'package:flutter/material.dart';
import '../models/article.dart';

class ArticleFloatingActionButton extends StatefulWidget {
  ArticleFloatingActionButton(this._article);
  final Article _article;
  @override
  ArticleFloatingActionButtonState createState() => ArticleFloatingActionButtonState();
}

class ArticleFloatingActionButtonState extends State<ArticleFloatingActionButton> {
  @override
  Widget build(BuildContext context) {
    Article article = widget._article;
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
                    setState(() {
                      article.notMasteredWord = null;
                    });
                  },
                  child: Icon(Icons.arrow_upward),
                ))));
  }
}
