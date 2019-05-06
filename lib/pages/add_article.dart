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
    setState(() {
      this._isEnable = false;
    });
    var clipboardData = await Clipboard.getData('text/plain');
    setState(() {
      this._isEnable = true;
    });
    return clipboardData.text;
  }

  void _add() {
    setState(() {
      _isEnable = false;
    });
    var articleTitles = Provide.value<ArticleTitles>(context);
    bool showNewArticle = false;
    postArticle(_articleController.text, articleTitles).then((d) {
      _articleController.text = '';
      // make sure refalsh local data
      if (d["exists"]) {
        bus.emit('pop_show', "update article");
        var articles = Provide.value<Articles>(context);
        articles.setByID(d["id"]).then((d2) {
          if (showNewArticle) _loadArticleTitlesAndToArticle(d["id"]);
        });
      } else {
        if (showNewArticle) _loadArticleTitlesAndToArticle(d["id"]);
      }
    });
    // 如果不需要显示新加入的, 返回上一页
    if (!showNewArticle) Navigator.pop(context);
  }

  void _loadArticleTitlesAndToArticle(int articleID) {
    setState(() {
      _isEnable = true;
    });
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
