import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provide/provide.dart';
import '../store/article.dart';
import '../bus.dart';
import '../models/article_titles.dart';
import '../models/articles.dart';
import 'package:flutter/services.dart';
import '../components/oauth_info.dart';

TextEditingController _articleController = new TextEditingController();

class AddArticlePage extends StatefulWidget {
  AddArticlePage({Key key, this.articleTitles}) : super(key: key);
  final List articleTitles;
  @override
  _AddArticlePageState createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  @override
  void initState() {
    super.initState();
    _getFromClipboard().then((d) => _articleController.text = d);
  }

  bool _isEnable = true;
  _getFromClipboard() async {
    var clipboardData = await Clipboard.getData('text/plain');
    return clipboardData.text;
  }

  void _add() {
    setState(() {
      _isEnable = false;
    });
    postArticle(_articleController.text).then((d) {
      _articleController.text = '';

      // make sure refalsh local data
      if (d["exists"]) {
        bus.emit('pop_show', "update article");
        var articles = Provide.value<Articles>(context);
        articles.setByID(d["id"]).then((d2) {
          _loadArticleTitlesAndToArticle(d["id"]);
        });
      } else {
        _loadArticleTitlesAndToArticle(d["id"]);
      }
    });
  }

  void _loadArticleTitlesAndToArticle(int articleID) {
    setState(() {
      _isEnable = true;
    });
    //显示以后, 会计算未读数字, 需要刷新列表
    var articleTitles = Provide.value<ArticleTitles>(context);
    articleTitles.syncServer();
    Navigator.pushNamed(context, '/Article', arguments: articleID);
  }

  Widget _getLoadingOr() {
    if (_isEnable) {
      return SingleChildScrollView(
        child: Center(
            child: Column(
          children: <Widget>[
            TextField(
              textInputAction: TextInputAction.newline,
              enabled: _isEnable,
              autofocus: false, // 不要默认焦点, 避免键盘弹出来
              controller: _articleController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
            )
          ],
        )),
      );
    }
    return SpinKitChasingDots(
      color: Colors.blueGrey,
      size: 50.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("add new article"),
        actions: <Widget>[
          OauthInfoWidget(),
        ],
      ),
      body: _getLoadingOr(),
      floatingActionButton: FloatingActionButton(
        onPressed: _isEnable ? _add : null,
        tooltip: 'add article',
        child: Icon(_isEnable ? Icons.add : Icons.backup),
      ),
    );
  }
}
