// 文章列表
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provide/provide.dart';
import 'package:dio/dio.dart';
import '../pages/sign.dart';
import './add_article.dart';
import './article.dart';
import '../models/oauth_info.dart';
import '../models/articles.dart';

class ArticlesPage extends StatefulWidget {
  ArticlesPage({Key key}) : super(key: key);

  @override
  _ArticlesPageState createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  initState() {
    super.initState();
    // 需要初始化后才能使用 context
    Future.delayed(Duration.zero, () {
      var articles = Provide.value<Articles>(context);
      articles.syncServer().catchError((e) {
        if (e.response.statusCode == 401) {
          print("未授权");
          _toSignPage();
        }
      });
    });
  }

  void _toAddArticle() {
    //添加文章
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddArticlePage();
    }));
  }

  void _toSignPage() {
    //导航到新路由
    Navigator.push(
        context,
        MaterialPageRoute(
            maintainState: false, // 每次都新建一个详情页
            builder: (context) {
              return SignInPage();
            }));
  }

  void _toArticle(int articleID) {
    //导航到文章详情
    Navigator.push(
        context,
        MaterialPageRoute(
            maintainState: false, // 每次都新建一个详情页
            builder: (context) {
              return ArticlePage(articleID: articleID);
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('文章列表'),
        actions: <Widget>[
          Provide<OauthInfo>(builder: (context, child, oauthInfo) {
            if (oauthInfo.email == null) {
              return IconButton(
                icon: Icon(Icons.exit_to_app),
                tooltip: 'Sign',
                onPressed: _toSignPage,
              );
            } else {
              return GestureDetector(
                  onTap: _toSignPage,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(oauthInfo.avatarURL),
                      )));
            }
          }),
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(top: 10.0, left: 10.0, bottom: 10, right: 10),
        child: Provide<Articles>(builder: (context, child, articles) {
          if (articles.articles.length != 0) {
            return ListView(
              children: articles.articles.map((d) {
                return ListTile(
                  onTap: () {
                    _toArticle(d.id);
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
          return Text('加载中');
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toAddArticle,
        tooltip: 'add article',
        child: Icon(Icons.add),
      ),
    );
  }
}
