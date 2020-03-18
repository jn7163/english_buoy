import 'package:flutter/material.dart';
import '../models/article.dart';
import '../models/article_inherited.dart';

class ArticleFloatingActionButton extends StatefulWidget {
  @override
  ArticleFloatingActionButtonState createState() =>
      ArticleFloatingActionButtonState();
}

class ArticleFloatingActionButtonState
    extends State<ArticleFloatingActionButton> {
  @override
  Widget build(BuildContext context) {
    print("build $this");
    Article article = ArticleInherited.of(context).article;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // build方法中没有依赖InheritedWidget，此回调不会被调用。
    print("ArticleFloatingActionButton Dependencies change");
  }
}
