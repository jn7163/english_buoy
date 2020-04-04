import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './article_titles.dart';
import './explorer.dart';
import './article_page_view.dart';
import '../models/controller.dart';
import '../themes/base.dart';

import 'package:tuple/tuple.dart';

class HomePage extends StatelessWidget {
  SnackBar getSnackBar(String info, {SnackBarAction action}) {
    Duration durantion = action == null ? Duration(milliseconds: 4000) : Duration(milliseconds: 8000);

    return SnackBar(
      duration: durantion,
      action: action,
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
        body: Selector<Controller, Tuple2<String, Function>>(
            shouldRebuild: (previous, next) =>
                next.item1 != "" && next.item1 != null, //even the snackBarInfo not change, still need show
            selector: (context, controller) => Tuple2(controller.snackBarInfo, controller.retryFuc),
            builder: (context, data, child) {
              String snackBarInfo = data.item1;
              Function retryFuc = data.item2;
              if (snackBarInfo != null)
                Future.delayed(Duration.zero, () {
                  if (retryFuc != null) {
                    SnackBarAction action = SnackBarAction(
                      textColor: Colors.white,
                      onPressed: () => retryFuc(),
                      label: "RETRY",
                    );
                    Scaffold.of(context).showSnackBar(getSnackBar(snackBarInfo, action: action));
                  } else
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
