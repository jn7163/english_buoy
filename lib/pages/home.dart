import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './article_titles.dart';
import './explorer.dart';
import './article_page_view.dart';
import '../models/controller.dart';
import '../themes/base.dart';

class HomePage extends StatelessWidget {
  SnackBar getSnackBar(String info) {
    return SnackBar(
      backgroundColor: mainColor,
      content: Text(
        info,
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Selector<Controller, String>(
            shouldRebuild: (previous, next) => next != "", //even the snackBarInfo not change, still need show
            selector: (context, controller) => controller.snackBarInfo,
            builder: (context, snackBarInfo, child) {
              if (snackBarInfo != null)
                Future.delayed(Duration.zero, () {
                  Scaffold.of(context).showSnackBar(getSnackBar(snackBarInfo));
                  Provider.of<Controller>(context, listen: false).snackBarInfo = null;
                });
              return child;
            },
            child: PageView(
                //disable scroll
                physics: NeverScrollableScrollPhysics(),
                children: [
                  ArticleTitlesPage(),
                  ArticlePageViewPage(),
                  ExplorerPage(),
                ],
                controller: Provider.of<Controller>(context, listen: false).homePageViewController)));
  }
}
