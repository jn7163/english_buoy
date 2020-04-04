import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/controller.dart';
import '../models/article_titles.dart';

class ArticlesBottomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Controller _controller = Provider.of<Controller>(context, listen: false);
    ArticleTitles _articleTitles = Provider.of<ArticleTitles>(context, listen: false);
    int _currentIndex = 0;
    if (_controller.homeIndex == ArticleTitlesPageIndex) _currentIndex = 0;
    if (_controller.homeIndex == ExplorerPageIndex) _currentIndex = 1;
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedIconTheme: IconThemeData(color: Colors.white),
      unselectedIconTheme: IconThemeData(color: Colors.grey),
      unselectedItemColor: Colors.grey,
      selectedItemColor: Colors.white,
      onTap: (i) {
        if (i == 0) {
          if (_controller.homeIndex == ArticleTitlesPageIndex)
            _articleTitles.scrollToArticleTitle(0);
          else
            _controller.jumpToHome(ArticleTitlesPageIndex);
        }

        if (i == 1) _controller.jumpToHome(ExplorerPageIndex);
      },
      backgroundColor: Colors.black,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
          ),
          title: Text(
            "Home",
            style: TextStyle(
              fontSize: 10,
            ),
          ),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.explore,
          ),
          title: Text(
            "Explore",
            style: TextStyle(
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}
