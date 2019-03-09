// 文章列表
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provide/provide.dart';
import '../components/oauth_info.dart';
import '../models/article_titles.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ArticlesPage extends StatefulWidget {
  ArticlesPage({Key key}) : super(key: key);

  @override
  _ArticlesPageState createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('文章列表'),
        actions: <Widget>[
          OauthInfoWidget(),
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(top: 10.0, left: 10.0, bottom: 10, right: 10),
        child: Provide<ArticleTitles>(builder: (context, child, articles) {
          if (articles.articles.length != 0) {
            return ListView(
              children:
                  articles.articles.where((d) => d.unlearnedCount > 0).map((d) {
                return ListTile(
                  onTap: () {
                    Navigator.pushNamed(context, '/Article', arguments: d.id);
                  },
                  leading: Text(d.unlearnedCount.toString(),
                      style: TextStyle(
                          color: Colors.teal[700],
                          fontSize: 16,
                          fontFamily: "NotoSans-Medium")),
                  title: Text(d.title),
                );
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
