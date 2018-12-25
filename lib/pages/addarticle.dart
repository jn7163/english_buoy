import 'package:flutter/material.dart';
import '../store/article.dart';

TextEditingController _unameController = new TextEditingController();

class AddArticlePage extends StatelessWidget {
  var _isEnable = true;
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
                child: Text("提交"),
                onPressed: () {
                  _isEnable = false;
                  postArticle(_unameController.text).then((d) {
                    _isEnable = true;
                    _unameController.text = '';
                    Navigator.pop(context);
                  });
                },
              )
            ],
          )),
        ));
  }
}
