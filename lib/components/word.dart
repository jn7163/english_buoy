import 'package:flutter/material.dart';
import '../bus.dart';

// 显示单词的组件
class Word extends StatelessWidget {
  const Word(this.text, {Key key}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          bus.emit('word_clicked', text);
        },
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Text(text),
        ));
  }
}
