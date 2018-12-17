import 'package:flutter/material.dart';

// 显示单词的组件
class Word extends StatelessWidget {
  const Word({Key key, this.text}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          print("onTap " + text);
        },
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Text(text),
        ));
  }
}
