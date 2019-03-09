import 'package:flutter/material.dart';
import '../pages/article.dart';
import '../pages/sign.dart';
import '../pages/articles.dart';
import '../pages/add_article.dart';

toArticle(BuildContext context, int articleID) {
  Navigator.push(
      context,
      MaterialPageRoute(
          maintainState: true,
          builder: (context) {
            return ArticlePage(articleID: articleID);
          }));
}

toSignPage(BuildContext context) {
  //导航到新路由
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return SignInPage();
  }));
}

void toArticlesPage(BuildContext context) {
  //导航文章列表
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return ArticlesPage();
  }));
}

void toAddArticle(BuildContext context) {
  //添加文章
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return AddArticlePage();
  }));
}
