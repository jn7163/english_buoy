import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ArticleStatus with ChangeNotifier {
  //String tapedText = ''; // 当前点击的文本
  //String lastTapedText = ''; // 上次点击的文本
  //bool isWrap = true; // 当前字符是否换行符
  YoutubePlayerController youtubeController = YoutubePlayerController();

  /*
  setTapedText(String v) {
    tapedText = v;
    notifyListeners();
    Future.delayed(Duration(milliseconds: 800), () {
      tapedText = '';
      notifyListeners();
    });
  }

  setLastTapedText(String v) {
    lastTapedText = v;
    notifyListeners();
  }

  setIsWrap(bool v) {
    isWrap = v;
    //notifyListeners();
  }
   */

  setYouTube(YoutubePlayerController v) {
    youtubeController = v;
    notifyListeners();
  }
}
