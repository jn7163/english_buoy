import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provide/provide.dart';
import '../store/article.dart';
import './article.dart';
import '../models/articles.dart';
import '../models/article.dart';
import 'package:flutter/services.dart';

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
    Map<String, dynamic> result =
        await SystemChannels.platform.invokeMethod('Clipboard.getData');
    if (result != null) {
      return result['text'].toString();
    }
    return '';
  }

  void _add() {
    setState(() {
      _isEnable = false;
    });
    postArticle(_articleController.text).then((d) {
      _articleController.text = '';
      setState(() {
        _isEnable = true;
      });
      var article = Provide.value<Article>(context);
      article.clear();
      article.getArticleByID(d['id']).then((d) {
        //显示以后, 会计算未读数字, 需要刷新列表
        var articles = Provide.value<Articles>(context);
        articles.syncServer();
      });
      _toArticle(d['id']);
    });
  }

  void _toArticle(int articleID) {
    //导航到文章详情
    Navigator.push(
        context,
        MaterialPageRoute(
            maintainState: false,
            builder: (context) {
              return ArticlePage(articleID: articleID);
            }));
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
