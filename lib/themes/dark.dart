import 'package:flutter/material.dart';
import 'base.dart';

/*
var darkTextStyle =
    TextStyle(color: Colors.grey, fontFamily: "NotoSans-Medium");
var darkArticleContent = darkTextStyle.copyWith(fontSize: 20); //显示文章正文需要放大文字

var darkTextTheme = TextTheme(
    headline: darkTextStyle.copyWith(
        color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    // login subtitle 文字
    caption: darkTextStyle,
    // article 列表文字
    subhead: darkTextStyle,
    // 一般的文字颜色
    body1: darkTextStyle,
    // article 正文需要放大
    // ??? 使用 body2 传递会变成 weight 500 的粗体
    body2: darkArticleContent,
    display3: darkArticleContent,
    //必学单词
    display1: darkArticleContent.copyWith(color: Colors.blueGrey[400]),
    //非必学单词
    display2: darkArticleContent.copyWith(color: Colors.blueGrey));
// 控制 app bar 之类的
var darkPrimaryTextTheme =
    TextTheme(title: darkTextStyle, button: darkTextStyle);

var darkTheme = ThemeData(
    hoverColor: Colors.red,
    // drawer 的背景颜色
    canvasColor: Color(0XFF3c3f41),
    // youtube 播放器的弹出框背景颜色
    cardColor: Color(0XFF3c3f41),
    // 按钮样式
    buttonTheme: ButtonThemeData(
        textTheme: ButtonTextTheme.primary, buttonColor: Colors.grey),
    primarySwatch: darkMaterialColor,
    textTheme: darkTextTheme,
    // 列表被选中的高亮颜色
    highlightColor: Colors.black54,
    primaryTextTheme: darkPrimaryTextTheme,
    // 阅读背景色
    scaffoldBackgroundColor: Color(0XFF3c3f41));
    */

ThemeData darkTheme = ThemeData(
  primarySwatch: darkMaterialColor,
  primaryColorLight: mainColor[700],
  primaryColorDark: Colors.black,
  accentColor: mainColor, // loading 动画的颜色
  fontFamily: "NotoSans-Medium",
  scaffoldBackgroundColor: Color(0XFF3c3f41), // 阅读背景色
);
