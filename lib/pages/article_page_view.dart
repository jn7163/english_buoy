import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article_titles.dart';
import './article.dart';
import '../models/controller.dart';
import 'dart:io' show Platform;


class ArticlePageViewPage extends StatefulWidget {
  @override
  _ArticlePageViewPage createState() => _ArticlePageViewPage();
}

class _ArticlePageViewPage extends State<ArticlePageViewPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  Controller _controller;
  ArticleTitles _articleTitles;
  @override
  void initState() {
    _controller = Provider.of<Controller>(context, listen: false);
    _articleTitles = Provider.of<ArticleTitles>(context, listen: false);
    super.initState();
  }

  Widget _pageView (BuildContext context ){
      return PageView(
          reverse: true,
          onPageChanged: (i) {
            _articleTitles.currentArticleIndex = i;
            // used to highlight aritcleTitlePage item
            _controller.setSelectedArticleID(_articleTitles.filterTitles[i].id);
          },
          controller: _controller.articlePageController,
          children: _articleTitles.filterTitles.map((d) {
            return ArticlePage(d.id);
          }).toList());
  }


  Widget _buildForAndroid (BuildContext context){
    return WillPopScope(
      onWillPop: () async {
        if (_controller.mainSelectedIndex == 1) {
          _controller.setMainSelectedIndex(0);
          return false;
        } else
          return true;
      },
      child: _pageView(context) ,
    );
  }

  Widget _buildForiOS ( BuildContext context){
    return Scaffold(
      appBar: null ,
      body: _pageView(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () { _controller.setMainSelectedIndex(0); },
        tooltip: 'back to home',
        child: Icon(Icons.home),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_controller.articlePageController == null) return Container();
    return Platform.isIOS ? _buildForiOS(context) : _buildForAndroid(context);
  }
}
