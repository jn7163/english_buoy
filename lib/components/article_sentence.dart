import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:easy_alert/easy_alert.dart';

import '../models/article.dart';
import '../models/word.dart';
import '../models/sentence.dart';
import '../store/store.dart';

import '../functions/article.dart';
import '../functions/utility.dart';
import '../functions/word.dart';
import '../themes/base.dart';

// init text style
TextStyle bodyTextStyle = TextStyle(color: Colors.black87, fontSize: 20.0, fontFamily: 'NotoSans-Medium');

class ArticleSentence extends StatefulWidget {
  ArticleSentence(
      {Key key,
      @required this.article,
      @required this.sentence,
      this.needWordWise = true,
      this.crossAxisAlignment = CrossAxisAlignment.start})
      : super(key: key);
  final bool needWordWise;
  final Article article; // 用于计算文章的未掌握数目
  final Sentence sentence; // 需要渲染的多条句子
  final CrossAxisAlignment crossAxisAlignment; // 句子的位置

  @override
  ArticleSentenceState createState() => ArticleSentenceState();
}

class ArticleSentenceState extends State<ArticleSentence> {
  Map seekTextSpanTapStatus = Map<String, bool>();

  RegExp _startExp = RegExp(r"00[0-9]+\.[0-9]+00");

  // 后台返回的文章结构
  String _tapedText = ''; // 当前点击的文本

  // 必学的高亮色
  TextStyle needLearnTextStyle;
  // 非必学的高亮色
  TextStyle noNeedLearnTextStyle;

  @override
  initState() {
    widget.sentence.setStateCallback = () {
      setState(() {});
    };
    super.initState();
  }

// 定义各种 tap 后的处理
// isNoNeed 是不需要学习的
  MultiTapGestureRecognizer _getTapRecognizer(Word word) {
    if (word.text == "") return null;
    // 标记是否长按, 长按不要触发单词查询
    bool longTap = false;
    return MultiTapGestureRecognizer()
      ..longTapDelay = Duration(milliseconds: 400)
      ..onLongTapDown = (i, detail) async {
        longTap = true;
        // set current word state for speed up change
        bool learned = !word.learned;
        word.learned = learned;
        //update server side word status
        word.putLearned();
        //update global word status
        Store.wordStatus[word.text.toLowerCase()] = word;
        widget.article.setState();
      }
      ..onTap = (i) {
        // 避免长按的同时触发
        if (!longTap) {
          setState(() {
            _tapedText = word.text;
          });
          Future.delayed(Duration(milliseconds: 800), () {
            setState(() {
              _tapedText = '';
            });
          });
          // 无需学的, 没必要显示级别
          if (word.level != 0)
            Alert.toast(context, word.level.toString(), position: ToastPosition.bottom, duration: ToastDuration.long);
          // 实时增加次数的效果
          widget.article.increaseLearnCount(word.text);
          // 记录学习次数
          word.putLearn();
          Clipboard.setData(ClipboardData(text: word.text));
        }
      };
  }

  // 生成修改播放位置的图标
  TextSpan getSeekTextSpan(BuildContext context, String time, Sentence s) {
    if (seekTextSpanTapStatus[time] == null) seekTextSpanTapStatus[time] = false;
    Duration seekTime = toDuration(time);
    TapGestureRecognizer recognizer = TapGestureRecognizer()
      ..onTap = () {
        widget.article.youtubeController.makeSureSeekTo(seekTime);
        setState(() {
          seekTextSpanTapStatus[time] = true;
        });
        Future.delayed(Duration(milliseconds: 800), () {
          setState(() {
            seekTextSpanTapStatus[time] = false;
          });
        });
      };
    TextStyle playTextStyle = bodyTextStyle.copyWith(color: mainColor[700]);
    return TextSpan(
        text: " ▷ ",
        style: seekTextSpanTapStatus[time] || s.highlight ? playTextStyle.copyWith(fontWeight: FontWeight.bold) : playTextStyle,
        recognizer: recognizer);
  }

// 根据规则, 判断单词前是否需要添加空白
  String _getBlank(String text) {
    return noNeedBlank.contains(text.toLowerCase()) ? "" : " ";
  }

  // 定义应该的 style
  TextStyle _defineStyle(Word word) {
    bool isCommandWord = (word.level != null && word.level != 0); // 是否3000常用
    bool isSelected = (_tapedText.toLowerCase() == word.text.toLowerCase()); // 是否选中
    // 常用高亮色
    this.needLearnTextStyle = bodyTextStyle.copyWith(color: mainColor[700]);
    // 非常用的高亮色
    this.noNeedLearnTextStyle = bodyTextStyle.copyWith(color: Colors.blueGrey);

    //根据条件逐步加工修改的样式
    TextStyle processTextStyle = bodyTextStyle;
    // 是常用
    processTextStyle = isCommandWord ? needLearnTextStyle : noNeedLearnTextStyle;
    //无需学习的非标准单词
    if (!isNeedLearn(word)) processTextStyle = bodyTextStyle;
    // 已经学会且没有选中, 不用任何修改
    if (word.learned == true) processTextStyle = bodyTextStyle;

    if (isSelected)
      processTextStyle = processTextStyle.copyWith(
          //fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.wavy);
    // 查找时高亮
    if (widget.article.findWord.toLowerCase() == word.text.toLowerCase())
      processTextStyle = processTextStyle.copyWith(
          color: Colors.deepOrange[700], decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.wavy);
    return processTextStyle;
  }

// 组装为需要的 textSpan
  TextSpan getTextSpan(Word word) {
    keepWordHasSameStat(word);
    if (word.text == "\n" || _startExp.hasMatch(word.text)) {
      return TextSpan(text: "");
    }
    var wordStyle = _defineStyle(word); // 文字样式

    TextSpan subscript = TextSpan(); // 显示该单词查询次数的下标

    //需要学习的单词
    if (word.learned == false && isNeedLearn(word)) {
      String shortDef = "";
      if (word.count != 0) shortDef += " ${word.count}";
      if (widget.needWordWise && Store.wordwiseMap[word.text.toLowerCase()] != null)
        shortDef += " -" + Store.wordwiseMap[word.text.toLowerCase()];
      subscript = TextSpan(text: shortDef, style: wordStyle.copyWith(fontSize: 12)); // 下标样式和原本保持一致, 只是变小
    }

    return TextSpan(text: _getBlank(word.text), children: [
      // if not letter no need recognizer
      hasLetter(word.text)
          ? TextSpan(text: word.text, style: wordStyle, recognizer: _getTapRecognizer(word))
          : TextSpan(text: word.text, style: wordStyle, recognizer: _getTapRecognizer(word)),
      subscript,
    ]);
  }

  // check is the seek button or just blank
  TextSpan getSeekButton(BuildContext context, String text, Sentence s) {
    TextSpan star;
    if (_startExp.hasMatch(text)) {
      star = getSeekTextSpan(context, text, s);
    } else {
      star = TextSpan(text: "");
    }
    return star;
  }

  Widget buildArticleRichText(Sentence s) {
    TextSpan star = getSeekButton(context, s.words[0].text, s);
    List<TextSpan> words = s.words.map((d) {
      return getTextSpan(d);
    }).toList();
    words.insert(0, star);

    TextStyle playingStyle = TextStyle();
    //if play to current sentence
    if (s.highlight)
      playingStyle = TextStyle(
        backgroundColor: Colors.teal[50],
      );
    RichText content = RichText(
        text: TextSpan(
      style: playingStyle,
      text: "",
      children: words,
    ));

    s.c = context;
    return ExcludeSemantics(
      excluding: true,
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildArticleRichText(widget.sentence);
  }
}
