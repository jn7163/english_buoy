import 'package:flutter/material.dart';
import '../store/article.dart';

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
      setState(() {
        _isEnable = true;
      });
      _articleController.text = '';
      Navigator.pop(context);
    });
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
            ),
            OutlineButton(
              child: Text(_isEnable ? "submit" : "submitting..."),
              onPressed: _isEnable ? _add : null,
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
