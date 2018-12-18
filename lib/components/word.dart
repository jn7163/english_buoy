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
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20.0, // insert your font size here
        ),
      ),
    );
  }
}
