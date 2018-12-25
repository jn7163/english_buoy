import 'package:flutter/gestures.dart';
import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:flutter/material.dart';
import './bus.dart';
import 'package:easy_alert/easy_alert.dart';
import './dto/word.dart';
import './pages/addarticle.dart';

// void main() => runApp(MyApp());
void main() => runApp(AlertProvider(
      child: MyApp(),
      config: AlertConfig(
          ok: "OK text for `ok` button in AlertDialog",
          cancel: "CANCEL text for `cancel` button in AlertDialog"),
    ));

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List _words = [
    Word("""
    big
    """),
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
    bus.on("word_clicked", (arg) {
      Alert.toast(context, arg.toString(),
          position: ToastPosition.bottom, duration: ToastDuration.short);
    });
    // postArticle();
  }

  TextSpan _getTextSpan(String word) {
    String blank = " ";
    // 这些符号前面不要加空格
    List noNeedBlank = [".", "!", "'", ",", "n't"];
    if (noNeedBlank.contains(word)) blank = "";
    if (word == "\n") word = "\n   "; // 如果换行了, 下一行加上3个空格, 保证缩进
    return TextSpan(text: blank, children: [
      TextSpan(
        text: word,
        style: TextStyle(color: Colors.grey[600], fontSize: 20),
      )
    ]);
  }

// 生成一个注册好的 textSpan
  TextSpan _getRegistedTextSpan(String word, int level) {
    return TextSpan(text: " ", children: [
      TextSpan(
        text: word,
        style: (this._tapedText == word)
            ? TextStyle(fontWeight: FontWeight.bold)
            : TextStyle(),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            bus.emit('word_clicked', level);
            ClipboardManager.copyToClipBoard(word);
          }
          ..onTapDown = (o) {
            setState(() {
              this._tapedText = word;
            });
          }
          ..onTapUp = (o) {
            setState(() {
              this._tapedText = '';
            });
          },
      )
    ]);
  }

  void _toAddArticle() {
    //导航到新路由
    Navigator.push(context, new MaterialPageRoute(builder: (context) {
      return AddArticlePage();
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
      ),
      body: Container(
        margin: EdgeInsets.only(top: 10.0, left: 10.0, bottom: 10, right: 10),
        child: SingleChildScrollView(
            child: RichText(
          text: TextSpan(
            text: '',
            style: TextStyle(color: Colors.black87, fontSize: 20),
            children: _words.map((d) {
              if (d.level != 0) {
                return _getRegistedTextSpan(d.text, d.level);
              } else {
                return _getTextSpan(d.text);
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
