import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './article_titles.dart';
import 'article_page_view.dart';
import '../models/controller.dart';
import '../models/article_titles.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Controller _controller;
  ArticleTitles _articleTitles;

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    ArticleTitlesPage(),
    ArticlePageViewPage(0),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _articleTitles = Provider.of<ArticleTitles>(context, listen: false);
    _controller = Provider.of<Controller>(context, listen: false);
    _controller.setMainPageController(PageController());
  }

  void _onItemTapped(int index) {
    _controller.setMainSelectedIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Controller>(
      builder: (context, currentController, child) {
        return Scaffold(
          body: PageView(
            children: _widgetOptions,
            controller: _controller.mainPageController,
            onPageChanged: (index) {
              _articleTitles.pauseYouTube();
            },
          ),

          //_widgetOptions.elementAt(_selectedIndex),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
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
            ],
            currentIndex: currentController.mainSelectedIndex,
            //selectedItemColor: Colors.amber[800],
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }
}
