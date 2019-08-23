import 'package:ebuoy/themes/dark.dart';
import 'package:flutter/material.dart';

var brightTextStyle =
TextStyle(color: Colors.black87, fontFamily: "NotoSans-Medium");
var brightArticleContent =
brightTextStyle.copyWith(fontSize: 20); //显示文章正文需要放大文字
var brightTextTheme = TextTheme(
    headline: brightTextStyle.copyWith(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    title: brightTextStyle.copyWith(
      fontSize: 36.0,
      fontStyle: FontStyle.italic,
    ),
    // article 列表文字
    subhead: brightTextStyle,
    // article 正文文字
    body1: brightArticleContent,
    //必学单词
    display1: brightArticleContent.copyWith(color: Colors.teal[700]),
    //非必学单词
    display2: brightArticleContent.copyWith(color: Colors.blueGrey));

// list 选中高亮 Colors.blueGrey[50]
// 需要学习的单词 Colors.teal[700]
// 无需学习的单词 Colors.blueGrey
var brightTheme = ThemeData(
  // primarySwatch: Colors.blueGrey, //主色调
  primarySwatch: darkMaterialColor,
  textTheme: brightTextTheme,
  // 阅读背景色
  backgroundColor: Colors.white70
  ,);
