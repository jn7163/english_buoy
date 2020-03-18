import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../models/settings.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
//import '../youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_widgets/flutter_widgets.dart';

class ArticleYouTube extends StatelessWidget {
  const ArticleYouTube({Key key, this.article}) : super(key: key);
  final Article article;
  @override
  Widget build(BuildContext context) {
    //print("build $this");
    //Article article = Provider.of<Article>(context);
    if (article == null || article.title == null || article.youtube == '')
      return Container(width: 0.0, height: 0.0);
    Settings settings = Provider.of<Settings>(context);
    return VisibilityDetector(
        key: Key("youtube_" + article.articleID.toString()),
        onVisibilityChanged: (d) {
          if (d.visibleFraction == 0) {
            article.youtubeController.pause();
            article.checkSentenceHighlight = false;
          }
          if (d.visibleFraction != 0) article.checkSentenceHighlight = true;
        },
        child: Container(
            color: Theme.of(context).primaryColorDark,
            child: SafeArea(
                child: YoutubePlayer(
              onPlayerInitialized: (controller) =>
                  article.setYouTube(controller),
              context: context,
              videoId: YoutubePlayer.convertUrlToId(article.youtube),
              flags: YoutubePlayerFlags(
                //自动播放
                autoPlay: settings.isAutoplay,
                // 下半部分小小的进度条
                showVideoProgressIndicator: true,
                // 允许全屏
                hideFullScreenButton: false,
                // 不可能是 live 的视频
                isLive: false,
                forceHideAnnotation: false,
              ),
              videoProgressIndicatorColor: Colors.blueGrey,
              liveUIColor: Colors.blueGrey,
              progressColors: ProgressColors(
                playedColor: Colors.blueGrey,
                handleColor: Colors.blueGrey,
              ),
            ))));
  }
}
