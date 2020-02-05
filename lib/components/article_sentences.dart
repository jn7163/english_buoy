import 'package:ebuoy/models/word.dart';
import 'package:ebuoy/themes/base.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ebuoy/models/article.dart';
import 'package:provider/provider.dart';
import '../models/article_titles.dart';
import '../models/settings.dart';

import 'package:easy_alert/easy_alert.dart';

import 'package:flutter/services.dart';
import '../models/article.dart';
import '../models/word.dart';
import '../models/sentence.dart';
import './article_richtext.dart';
import '../functions/article.dart';

class ArticleSentences extends StatefulWidget {
  ArticleSentences(
      {Key key,
      @required this.article,
      @required this.sentences,
      this.crossAxisAlignment = CrossAxisAlignment.start})
      : super(key: key);
  final Article article; // 用于计算文章的未掌握数目
  final List<Sentence> sentences; // 需要渲染的多条句子
  final CrossAxisAlignment crossAxisAlignment; // 句子的位置

  @override
  ArticleSentencesState createState() => ArticleSentencesState();
}

class ArticleSentencesState extends State<ArticleSentences> {
  Map seekTextSpanTapStatus = Map<String, bool>();

  RegExp _startExp = RegExp(r"00[0-9]+\.[0-9]+00");

  // 后台返回的文章结构
  String _tapedText = ''; // 当前点击的文本
  String _lastTapedText = ''; // 上次点击的文本
  Settings settings;
  TextStyle bodyTextStyle;
  // 必学的高亮色
  TextStyle needLearnTextStyle;
  // 非必学的高亮色
  TextStyle noNeedLearnTextStyle;

  @override
  initState() {
    super.initState();
    settings = Provider.of<Settings>(context, listen: false);
    // init text style
    Future.delayed(Duration.zero, () {
      this.bodyTextStyle = TextStyle(
          color: Colors.black87, fontSize: 20.0, fontFamily: 'NotoSans-Medium');
      // 必学的高亮色
      this.needLearnTextStyle =
          bodyTextStyle.copyWith(color: Theme.of(context).primaryColorLight);
      // 非必学的高亮色
      this.noNeedLearnTextStyle =
          bodyTextStyle.copyWith(color: Theme.of(context).primaryColorDark);
    });
  }

  int _getIDByTitle(String title) {
    var articles = Provider.of<ArticleTitles>(context, listen: false);
    var titles = articles.titles
        .where((d) => d.title.toLowerCase() == title.toLowerCase())
        .toList();
    if (titles.length > 0) {
      return titles[0].id;
    }
    return 0;
  }

// 定义各种 tap 后的处理
// isNoNeed 是不需要学习的
  MultiTapGestureRecognizer _getTapRecognizer(Word word) {
    if (word.text == "") return null;
    // 标记是否长按, 长按不要触发单词查询
    bool longTap = false;
    return MultiTapGestureRecognizer()
      ..longTapDelay = Duration(milliseconds: 400)
      ..onLongTapDown = (i, detail) {
        longTap = true;
        setState(() {
          word.learned = !word.learned;
        });

        widget.article.putLearned(word).then((d) {
          //重新计算文章未掌握单词数
          var articleTitles =
              Provider.of<ArticleTitles>(context, listen: false);
          articleTitles.setUnlearnedCountByArticleID(
              widget.article.unlearnedCount, widget.article.articleID);
        });
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
            Alert.toast(context, word.level.toString(),
                position: ToastPosition.bottom, duration: ToastDuration.long);
          // 实时增加次数的效果
          widget.article.increaseLearnCount(word.text);
          // 记录学习次数
          word.putLearn();
          Clipboard.setData(ClipboardData(text: word.text));
          // 一个点击一个单词两次, 那么尝试跳转到这个单词列表
          // 已经在这个单词页, 就不要跳转了
          if (_lastTapedText.toLowerCase() == word.text.toLowerCase() &&
              word.text.toLowerCase() != widget.article.title.toLowerCase() &&
              settings.isJump) {
            int id = _getIDByTitle(word.text);
            if (id != 0) {
              Navigator.pushNamed(context, '/Article', arguments: id);
            }
          } else {
            _lastTapedText = word.text;
          }
        }
      };
  }

  // 生成修改播放位置的图标
  TextSpan getSeekTextSpan(BuildContext context, String time) {
    if (seekTextSpanTapStatus[time] == null)
      seekTextSpanTapStatus[time] = false;
    Duration seekTime = Duration(
      milliseconds: (double.parse(time) * 1000).round(),
    );
    // TextStyle style = Theme.of(context).textTheme.display3.copyWith(fontSize: 16);
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
    return TextSpan(
        text: " ▷ ",
        style: seekTextSpanTapStatus[time]
            ? needLearnTextStyle.copyWith(fontWeight: FontWeight.bold)
            : needLearnTextStyle,
        /*
            ? Theme.of(context)
                .textTheme
                .display1
                .copyWith(fontWeight: FontWeight.bold)
            : Theme.of(context).textTheme.display3,
            */
        recognizer: recognizer);
  }

// 根据规则, 判断单词前是否需要添加空白
  String _getBlank(String text) {
    return noNeedBlank.contains(text.toLowerCase()) ? "" : " ";
  }

  // 定义应该的 style
  TextStyle _defineStyle(Word word) {
    bool needLearn = (word.level != null && word.level != 0); // 是否需要掌握
    var articleTitles = Provider.of<ArticleTitles>(context, listen: false);
    bool inArticleTitles = articleTitles.setArticleTitles
        .contains(word.text.toLowerCase()); // 是否添加

    bool isSelected =
        (_tapedText.toLowerCase() == word.text.toLowerCase()); // 是否选中

    //根据条件逐步加工修改的样式
    TextStyle processTextStyle = bodyTextStyle;

    if (!isNeedLearn(word)) return bodyTextStyle;
    // 已经学会且没有选中, 不用任何修改
    if (word.learned == true && !isSelected) return bodyTextStyle;

    // 是否必学
    processTextStyle = needLearn ? needLearnTextStyle : noNeedLearnTextStyle;
    // 单词作为文章标题添加
    if (inArticleTitles) {
      //无需掌握的添加单词高亮为需要学习的颜色
      processTextStyle = needLearnTextStyle.copyWith(
        //添加下划线区分
        decoration: TextDecoration.underline,
        decorationStyle: TextDecorationStyle.dotted,
      );
    }
    // 一旦选中, 还原本来的样式
    // 长按选中 显示波浪下划线
    if (isSelected)
      processTextStyle = processTextStyle.copyWith(
          //fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.wavy);
    // 查找时高亮
    if (widget.article.findWord.toLowerCase() == word.text.toLowerCase())
      processTextStyle = processTextStyle.copyWith(
          color: Colors.deepOrange[700],
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.wavy);
    return processTextStyle;
  }

// 组装为需要的 textSpan
  TextSpan getTextSpan(Word word) {
    if (word.text == "\n" || _startExp.hasMatch(word.text)) {
      return TextSpan(text: "");
    }
    var wordStyle = _defineStyle(word); // 文字样式

    TextSpan subscript = TextSpan(); // 显示该单词查询次数的下标

    //需要学习的单词
    if (word.learned == false && hasLetter(word.text) && word.text.length > 1) {
      //有查询下标则显示
      if (word.count != 0) {
        subscript = TextSpan(
            text: word.count.toString(),
            style: wordStyle.copyWith(fontSize: 12)); // 数字样式和原本保持一致, 只是变小
      }
    }

    return TextSpan(text: _getBlank(word.text), children: [
      // if not letter no need recognizer
      hasLetter(word.text)
          ? TextSpan(
              text: word.text,
              style: wordStyle,
              recognizer: _getTapRecognizer(word))
          : TextSpan(text: word.text, style: wordStyle),
      subscript,
    ]);
  }

  // check is the seek button or just blank
  TextSpan getStar(BuildContext context, String text) {
    TextSpan star;
    if (_startExp.hasMatch(text)) {
      star = getSeekTextSpan(context, text);
    } else {
      star = TextSpan(text: "");
    }
    return star;
  }

  ArticleRichText buildArticleRichText(Sentence s) {
    TextSpan star = getStar(context, s.words[0].text);
    List<TextSpan> words = s.words.map((d) {
      return getTextSpan(d);
    }).toList();
    words.insert(0, star);
    return ArticleRichText(
        textSpan: TextSpan(
          text: "",
          //style: Theme.of(context).textTheme.display3, // 没有这个样式,会导致单词点击时错位
          children: words,
        ),
        sentence: s);
  }

  @override
  Widget build(BuildContext context) {
    //只有一个单词时候不要用 Column封装,避免位置上移
    if (widget.sentences.length == 1)
      return buildArticleRichText(widget.sentences[0]);
    List<Widget> richTextList = widget.sentences.map((s) {
      return buildArticleRichText(s);
    }).toList();

    return Column(
        children: richTextList, crossAxisAlignment: CrossAxisAlignment.start);
  }
}
