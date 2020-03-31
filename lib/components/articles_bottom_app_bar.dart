import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../models/controller.dart';

class ArticlesBottomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Controller _controller = Provider.of<Controller>(context, listen: false);
    Color homeColor = _controller.homeIndex == ArticleTitlesPageIndex ? Colors.white : Colors.grey;
    Color exploreColor = _controller.homeIndex == ExplorerPageIndex ? Colors.white : Colors.grey;
    return BottomNavigationBar(
      onTap: (i) {
        if (i == 0) _controller.jumpToHome(ArticleTitlesPageIndex);
        if (i == 1) _controller.jumpToHome(ExplorerPageIndex);
      },
      backgroundColor: Colors.black,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            color: homeColor,
          ),
          title: Text(
            "Home",
            style: TextStyle(
              fontSize: 10,
              color: homeColor,
            ),
          ),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.explore,
            color: exploreColor,
          ),
          title: Text(
            "Explore",
            style: TextStyle(
              fontSize: 10,
              color: exploreColor,
            ),
          ),
        ),
      ],
    );
  }
}
