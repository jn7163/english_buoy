import 'package:flutter/material.dart';
import 'base.dart';

/*
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
    body1: brightTextStyle,
    body2: brightArticleContent,
    display3: brightArticleContent,
    //必学单词
    display1: brightArticleContent.copyWith(color: mainColor),
    //非必学单词
    display2: brightArticleContent.copyWith(color: Colors.blueGrey));

// list 选中高亮 Colors.blueGrey[50]
// 需要学习的单词 Colors.teal[700]
// 无需学习的单词 Colors.blueGrey
var brightTheme = ThemeData(
  accentColor: mainColor, // 动画的颜色
  // primarySwatch: Colors.blueGrey, //主色调
  primarySwatch: darkMaterialColor,
  //textTheme: brightTextTheme,
  scaffoldBackgroundColor: Colors.white70,
  backgroundColor: Colors.white,
  snackBarTheme: SnackBarThemeData()
      .copyWith(backgroundColor: mainColor, actionTextColor: Colors.white),
);
*/

var brightTheme = ThemeData(
  primarySwatch: darkMaterialColor,
  primaryColor: mainColor,
  primaryColorLight: mainColor[700],
  primaryColorDark: Colors.black,
  accentColor: mainColor, // loading 动画的颜色
  //brightness: Brightness.light,
  fontFamily: "NotoSans-Medium",
  scaffoldBackgroundColor: Colors.blueGrey[50], // 阅读背景色
  /*
  textTheme: TextTheme(
      //headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      //title: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
      //body1: TextStyle(
      //   color: Colors.black87, fontSize: 20.0, fontFamily: 'NotoSans-Medium'),
      ),
      */
);
