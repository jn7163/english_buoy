import 'package:flutter/material.dart';
import '../store/article.dart';
import './article.dart';

TextEditingController _articleController = new TextEditingController();

class AddArticlePage extends StatefulWidget {
  AddArticlePage({Key key}) : super(key: key);
  @override
  _AddArticlePageState createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  bool _isEnable = true;
  void _add() {
    setState(() {
      _isEnable = false;
    });
    postArticle(_articleController.text).then((d) {
      _articleController.text = '';
      setState(() {
        _isEnable = true;
      });
    });
    _toArticle("Analysising", 0);
  }

  void _toArticle(String title, int articleID) {
    //导航到文章详情
    Navigator.push(context, new MaterialPageRoute(builder: (context) {
      return ArticlePage(title: title, articleID: articleID);
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("add new article"),
      ),
      body: SingleChildScrollView(
        child: Center(
            child: Column(
          children: <Widget>[
            TextField(
              textInputAction: TextInputAction.go,
              enabled: _isEnable,
              autofocus: true,
              controller: _articleController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
            )
          ],
        )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isEnable ? _add : null,
        tooltip: 'add article',
        child: Icon(_isEnable ? Icons.add : Icons.backup),
      ),
    );
  }
}
