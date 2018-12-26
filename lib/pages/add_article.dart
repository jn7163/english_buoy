import 'package:flutter/material.dart';
import '../store/article.dart';

TextEditingController _unameController = new TextEditingController();

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
    postArticle(_unameController.text).then((d) {
      setState(() {
        _isEnable = true;
      });
      _unameController.text = '';
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("New route"),
        ),
        body: SingleChildScrollView(
          child: Center(
              child: Column(
            children: <Widget>[
              Text("This is new route"),
              TextField(
                enabled: _isEnable,
                autofocus: true,
                controller: _unameController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
              OutlineButton(
                child: Text(_isEnable ? "提交" : "提交中..."),
                onPressed: _isEnable ? _add : null,
              )
            ],
          )),
        ));
  }
}
