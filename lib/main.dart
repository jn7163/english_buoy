import 'package:flutter/material.dart';
import 'package:easy_alert/easy_alert.dart';
import './pages/article.dart';

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
      home: ArticlePage(title: 'Learn The Word'),
    );
  }
}
