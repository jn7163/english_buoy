import 'package:flutter/material.dart';

import 'package:ebuoy/components/article_titles_app_bar.dart';

class GuidPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Scaffold scaffold = Scaffold(
      appBar: ArticleListsAppBar(),
      body: Column(children: [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/ArticleTitles');
          },
          child: Image(image: AssetImage('assets/images/how_to_use.jpg')),
        ),
        OutlineButton(
            onPressed: () {
              //Navigator.pushNamed(context, '/ArticleTitles');
              Navigator.pop(context);
            },
            child: Text("ok, I know"))
      ]),
    );
    return scaffold;
  }
}
