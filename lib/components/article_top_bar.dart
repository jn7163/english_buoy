import 'package:ebuoy/models/article.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'article_youtube_avatar.dart';

// 文章对应的 youtube 图标或者头像
class ArticleTopBar extends StatelessWidget {
  const ArticleTopBar({Key key, @required this.article}) : super(key: key);
  final Article article;

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 8, top: this.article.youtube == "" ? 10 : 260),
      color: Theme.of(context).primaryColor,
      child: ListTile(
          onTap: () {
            _launchURL(article.youtube);
          },
          leading: ArticleYoutubeAvatar(
              youtubeURL: article.youtube, avatar: article.avatar, loading: false),
          title: (article != null)
              ? Text(article.title + "  🔗", style: Theme.of(context).primaryTextTheme.title)
              : Text(
                  "loading...",
                  style: Theme.of(context).primaryTextTheme.title,
                )),
    );
  }
}
