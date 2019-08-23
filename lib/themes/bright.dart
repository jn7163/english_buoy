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
    body1: brightArticleContent,
    display1: brightArticleContent.copyWith(color: Colors.teal[700]),
    //必学单词
    display2: brightArticleContent.copyWith(color: Colors.blueGrey) //非必学单词
    );

// list 选中高亮 Colors.blueGrey[50]
// 需要学习的单词 Colors.teal[700]
// 无需学习的单词 Colors.blueGrey
var brightTheme = ThemeData(
    // primarySwatch: Colors.blueGrey, //主色调
    primarySwatch: darkMaterialColor,
    textTheme: brightTextTheme);
