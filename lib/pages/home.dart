import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './article_titles.dart';
import './explorer.dart';
import './article_page_view.dart';
import '../models/controller.dart';

const ArticleTitlesPageIndex = 0;
const ArticlePageViewPageIndex = 1;
const ExplorerPageIndex = 2;

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageView(
        //disable scroll
        physics: NeverScrollableScrollPhysics(),
        children: [
          ArticleTitlesPage(),
          ArticlePageViewPage(),
          ExplorerPage(),
        ],
        controller:
            Provider.of<Controller>(context, listen: false).mainPageController);
  }
}
