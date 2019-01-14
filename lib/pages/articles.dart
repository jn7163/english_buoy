// 文章列表
import 'package:flutter/material.dart';
import '../pages/sign.dart';
import './add_article.dart';
import '../store/articles.dart';
import './article.dart';

class ArticlesPage extends StatefulWidget {
  ArticlesPage({Key key}) : super(key: key);

  @override
  _ArticlesPageState createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  List _articleTitles = [];

  initState() {
    super.initState();
    // 进入的时候, 获取一次文章列表
    getArticleTitles().then((d) {
      setState(() {
        // _articleTitles.clear();
        _articleTitles = d;
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
    Navigator.push(context, MaterialPageRoute(builder: (context) {
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
              return ArticlePage(
                  articleID: articleID, articleTitles: _articleTitles);
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('文章列表'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            tooltip: 'Sign',
            onPressed: _toSignPage,
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(top: 10.0, left: 10.0, bottom: 10, right: 10),
        child: ListView(
          children: _articleTitles.map((d) {
            return ListTile(
              onTap: () {
                _toArticle(d['id']);
                // getArticleByID(d['id']);
              },
              leading: Text(d['unlearned_count'].toString(),
                  style: TextStyle(
                      color: Colors.teal[700],
                      fontSize: 16,
                      fontFamily: "NotoSans-Medium")),
              title: Text(d['title']),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toAddArticle,
        tooltip: 'add article',
        child: Icon(Icons.add),
      ),
    );
  }
}
