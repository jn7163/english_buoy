import 'package:flutter/material.dart';

var mainColor = Colors.teal;
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
