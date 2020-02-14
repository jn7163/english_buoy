import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'article_youtube_avatar.dart';
import '../models/article.dart';

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
      color: Theme.of(context).primaryColorDark,
      child: ListTile(
          onTap: () {
            _launchURL(article.youtube);
          },
          leading: ArticleYoutubeAvatar(
              youtubeURL: article.youtube,
              avatar: article.avatar,
              loading: false),
          title: (article != null)
              ? Text(article.title,
                  style: Theme.of(context).primaryTextTheme.title)
              : Text(
                  "loading...",
                  style: Theme.of(context).primaryTextTheme.title,
                )),
    );
  }
}
