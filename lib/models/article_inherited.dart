import 'package:flutter/material.dart';
import './article.dart';

class ArticleInherited extends InheritedWidget {
  const ArticleInherited({
    Key key,
    @required this.article,
    @required Widget child,
  })  : assert(article != null),
        assert(child != null),
        super(key: key, child: child);

  final Article article;

  static ArticleInherited of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ArticleInherited>();
  }

  @override
  bool updateShouldNotify(ArticleInherited old) {
    print("this.article.unlearnedCount=" +
        this.article.unlearnedCount.toString());
    print(
        "old.article.unlearnedCount=" + old.article.unlearnedCount.toString());
    print(this.article.unlearnedCount != old.article.unlearnedCount);
    return this.article.unlearnedCount != old.article.unlearnedCount;
    //return this.article != old.article;
  }
}
