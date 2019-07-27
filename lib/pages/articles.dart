// 文章列表
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provide/provide.dart';
import '../components/oauth_info.dart';
import '../models/article_titles.dart';
import '../models/article_title.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ArticlesPage extends StatefulWidget {
  ArticlesPage({Key key}) : super(key: key);

  @override
  _ArticlesPageState createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  TextEditingController _searchQuery = new TextEditingController();
  bool _isSearching = false;
  String _searchText = "";
  int _selectArticleID = 0;
  initState() {
    super.initState();
    print('init articles');
    // 需要初始化后才能使用 context
    Future.delayed(Duration.zero, () {
      var articles = Provide.value<ArticleTitles>(context);
      articles.syncServer().catchError((e) {
        if (e.response.statusCode == 401) {
          print("未授权");
          Navigator.pushNamed(context, '/Sign');
        }
      });
    });
    _searchQuery.addListener(() {
      if (!_isSearching) {
        _searchQuery.text = "";
      }
      if (_searchQuery.text.isNotEmpty) {
        setState(() {
          // _isSearching = true;
          _searchText = _searchQuery.text;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                autofocus: true, // 自动对焦
                decoration: null, // 不要有下划线
                cursorColor: Colors.white,
                controller: _searchQuery,
                style: TextStyle(
                  color: Colors.white,
                ),
              )
            : Text(
                "The Articles",
                style: TextStyle(color: Colors.white),
              ),
        actions: <Widget>[
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            tooltip: 'go to articles',
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
              });
            },
          ),
          OauthInfoWidget(),
        ],
      ),
      body: Container(
        // margin: EdgeInsets.only(top: 10.0, left: 10.0, bottom: 10, right: 10),
        child: Provide<ArticleTitles>(builder: (context, child, articleTitles) {
          List<ArticleTitle> filterTiltes;
          if (_isSearching) {
            filterTiltes = articleTitles.articles
                .where((d) =>
                    d.title.toLowerCase().contains(_searchText.toLowerCase()))
                .toList();
          } else {
            filterTiltes = articleTitles.articles
                .where((d) => d.unlearnedCount > 0)
                .toList();
          }
          if (articleTitles.articles.length != 0) {
            return ListView(
              children: filterTiltes.map((d) {
                return Ink(
                    color: this._selectArticleID == d.id
                        ? Colors.blueGrey[50]
                        : Colors.transparent,
                    child: ListTile(
                      onTap: () {
                        this._selectArticleID = d.id;
                        Navigator.pushNamed(context, '/Article',
                            arguments: d.id);
                      },
                      leading: Text(d.unlearnedCount.toString(),
                          style: TextStyle(
                              color: Colors.teal[700],
                              fontSize: 16,
                              fontFamily: "NotoSans-Medium")),
                      title: Text(d.title),
                    ));
              }).toList(),
            );
          }
          return SpinKitChasingDots(
            color: Colors.blueGrey,
            size: 50.0,
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/AddArticle');
        },
        tooltip: 'add article',
        child: Icon(Icons.add),
      ),
    );
  }
}
