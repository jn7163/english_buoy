import 'package:flutter/material.dart';
import 'package:clipboard_manager/clipboard_manager.dart';
import '../store/article.dart';
import './article.dart';
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
              return ArticlePage(
                  articleID: articleID, articleTitles: widget.articleTitles);
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
              textInputAction: TextInputAction.newline,
              enabled: _isEnable,
              autofocus: false, // 不要默认焦点, 避免键盘弹出来
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
