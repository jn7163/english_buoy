import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './article_titles.dart';
import 'explorer.dart';
import 'article_page_view.dart';
import '../models/controller.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Controller _controller;
  //ArticleTitles _articleTitles;

  static List<BottomNavigationBarItem> bottomNavigationBarItem =
      <BottomNavigationBarItem>[
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      title: Text('Home'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.library_books),
      title: Text('Article'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.local_library),
      title: Text('Lib'),
    ),
  ];
  @override
  void initState() {
    super.initState();
    _controller = Provider.of<Controller>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        //disable scroll
        physics: NeverScrollableScrollPhysics(),
        children: [
          ArticleTitlesPage(),
          ArticlePageViewPage(),
          ExplorerPage(),
          //Center(child: Text('Developing')),
        ],
        controller: _controller.mainPageController,
        onPageChanged: (index) {},
      ),
    );
  }
}
