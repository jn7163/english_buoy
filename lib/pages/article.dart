import 'package:flutter/gestures.dart';
import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flutter/material.dart';
import '../bus.dart';
import 'package:easy_alert/easy_alert.dart';
import '../dto/word.dart';
import '../pages/add_article.dart';
import '../pages/sign.dart';
import '../store/learned.dart';

class ArticlePage extends StatefulWidget {
  ArticlePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  List _words = [
    Word('big'),
    Word('fuck'),
  ];
  // 后台返回的文章结构
  String _tapedText = ''; // 当前点击的文本
  initState() {
    super.initState();
    bus.on("analysis_done", (arg) {
      setState(() {
        _words = arg.map((d) => Word.fromJson(d)).toList();
      });
    });
    // 显示单词级别
    bus.on("word_clicked", (arg) {
      Alert.toast(context, arg.toString(),
          position: ToastPosition.bottom, duration: ToastDuration.short);
    });
    bus.on("learned", (d) {
      String info;
      if (d.learned) {
        info = d.text + "已经学会";
      } else {
        info = "重新学习" + d.text;
      }
      Alert.toast(context, info,
          position: ToastPosition.bottom, duration: ToastDuration.long);
    });
    // postArticle();
  }

// 无需学习的单词
  TextSpan _getNoNeedLearnTextSpan(String word, int level) {
    String blank = " ";
    // 这些符号前面不要加空格
    List noNeedBlank = [".", "!", "'", ",", "n't", "'s"];
    if (noNeedBlank.contains(word)) blank = "";
    if (word == "\n") word = "\n   "; // 如果换行了, 下一行加上3个空格, 保证缩进
    return TextSpan(text: blank, children: [
      TextSpan(
          text: word,
          style: TextStyle(color: Colors.grey[600]),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (level != 0) {
                bus.emit('word_clicked', level);
              }
              ClipboardManager.copyToClipBoard(word);
            })
    ]);
  }

// 需要学习的单词
  TextSpan _getNeedLearnTextSpan(Word word) {
    var _tapRecognizer = MultiTapGestureRecognizer()
      ..longTapDelay = Duration(milliseconds: 500)
      ..onLongTapDown = (i, detail) {
        print("onLongTapDown");
        setState(() {
          word.learned = !word.learned;
        });
        putLearned(word.text, word.learned);
        bus.emit('learned', word);
      }
      ..onTap = (i) {
        bus.emit('word_clicked', word.level);
        ClipboardManager.copyToClipBoard(word.text);
        putLearn(word.text);
      }
      ..onTapDown = (i, d) {
        setState(() {
          this._tapedText = word.text;
        });
      }
      ..onTapUp = (i, d) {
        setState(() {
          this._tapedText = '';
        });
      };
    return TextSpan(text: " ", children: [
      TextSpan(
          text: word.text,
          style: (this._tapedText == word.text)
              ? TextStyle(color: Colors.teal[500], fontWeight: FontWeight.bold)
              : TextStyle(color: Colors.teal[700]),
          recognizer: _tapRecognizer)
    ]);
  }

// 已经学会的单词
  TextSpan _getLearnedTextSpan(Word word) {
    var _tapRecognizer = MultiTapGestureRecognizer()
      ..longTapDelay = Duration(milliseconds: 500)
      ..onLongTapDown = (i, detail) {
        print("onLongTapDown");
        // 设置为已经学会
        setState(() {
          word.learned = !word.learned;
        });
        putLearned(word.text, word.learned);
        bus.emit('learned', word);
      }
      ..onTap = (i) {
        // bus.emit('word_clicked', word.level);
      }
      ..onTapDown = (i, detail) {
        setState(() {
          this._tapedText = word.text;
        });
      }
      ..onTapUp = (i, detail) {
        setState(() {
          this._tapedText = '';
        });
      };
    return TextSpan(text: " ", children: [
      TextSpan(
        text: word.text,
        style: (this._tapedText == word.text)
            ? TextStyle(fontWeight: FontWeight.bold)
            : TextStyle(),
        recognizer: _tapRecognizer,
      )
    ]);
  }

  void _toAddArticle() {
    //导航到新路由
    Navigator.push(context, new MaterialPageRoute(builder: (context) {
      return AddArticlePage();
    }));
  }

  void _toSignPage() {
    //导航到新路由
    Navigator.push(context, new MaterialPageRoute(builder: (context) {
      return SignInPage();
    }));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            tooltip: 'Air it',
            onPressed: _toSignPage,
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.only(top: 10.0, left: 10.0, bottom: 10, right: 10),
        child: SingleChildScrollView(
            child: RichText(
          text: TextSpan(
            text: '   ', // 第一句的空格
            style: TextStyle(color: Colors.black87, fontSize: 20),
            children: _words.map((d) {
              if (d.learned) {
                return _getLearnedTextSpan(d);
              }
              // if (d.level != null && d.level > 0 && d.level < 1000) {
              if (d.level != null && d.level != 0) {
                return _getNeedLearnTextSpan(d);
              } else {
                return _getNoNeedLearnTextSpan(d.text, d.level);
              }
            }).toList(),
          ),
        )),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toAddArticle,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
