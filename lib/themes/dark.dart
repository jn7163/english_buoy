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

var baseTextStyle =
    TextStyle(color: Colors.grey, fontFamily: "NotoSans-Medium");
var darkTextTheme = TextTheme(
  headline: baseTextStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
  title: baseTextStyle.copyWith(
    fontSize: 36.0,
    fontStyle: FontStyle.italic,
  ),
  body1: baseTextStyle.copyWith(fontSize: 14.0),
);

// 阅读背景色 Color(0XFF3c3f41)
// list 选中高亮 Colors.black54
var darkTheme = ThemeData(
  primarySwatch: darkMaterialColor,
  textTheme: darkTextTheme,
);
