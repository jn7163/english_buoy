import 'package:flutter/material.dart';

Map<int, Color> darkColorMap = {
  50: Color.fromRGBO(40, 40, 40, .1),
  100: Color.fromRGBO(40, 40, 40, .2),
  200: Color.fromRGBO(40, 40, 40, .3),
  300: Color.fromRGBO(40, 40, 40, .4),
  400: Color.fromRGBO(40, 40, 40, .5),
  500: Color.fromRGBO(40, 40, 40, .6),
  600: Color.fromRGBO(40, 40, 40, .7),
  700: Color.fromRGBO(40, 40, 40, .8),
  800: Color.fromRGBO(40, 40, 40, .9),
  900: Color.fromRGBO(40, 40, 40, 1),
};
MaterialColor darkMaterialColor = MaterialColor(0xFF282828, darkColorMap);

var darkTextStyle = TextStyle(color: Colors.grey, fontFamily: "NotoSans-Medium");
var darkArticleContent = darkTextStyle.copyWith(fontSize: 20); //显示文章正文需要放大文字
var darkTextTheme = TextTheme(
    headline:
        darkTextStyle.copyWith(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
var darkPrimaryTextTheme = TextTheme(title: darkTextStyle, button: darkTextStyle);
var darkTheme = ThemeData(
    primarySwatch: darkMaterialColor,
    textTheme: darkTextTheme,
    // 列表被选中的高亮颜色
    highlightColor: Colors.black54,
    primaryTextTheme: darkPrimaryTextTheme,
    // 阅读背景色
    backgroundColor: Color(0XFF3c3f41));
