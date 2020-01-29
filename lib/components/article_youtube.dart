import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:provider/provider.dart';

import '../models/article.dart';
import '../models/settings.dart';

class ArticleYouTube extends StatelessWidget {
  const ArticleYouTube({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Settings settings = Provider.of<Settings>(context);
    Article article = Provider.of<Article>(context);
    return YoutubePlayer(
      onPlayerInitialized: (controller) => article.setYouTube(controller),
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
      videoProgressIndicatorColor: Colors.teal,
      liveUIColor: Colors.teal,
      progressColors: ProgressColors(
        playedColor: Colors.teal,
        handleColor: Colors.tealAccent,
      ),
    );
  }
}
