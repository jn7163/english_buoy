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
    return GestureDetector(
        onTap: () {
          _launchURL(article.youtube);
        },
        child: Container(
            padding: EdgeInsets.only(left: 8, top: this.article.youtube == "" ? 10 : 264),
            color: Theme.of(context).primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ArticleYoutubeAvatar(
                  youtubeURL: article.youtube,
                  avatar: article.avatar,
                ),
                Expanded(
                    child: Container(
                        padding: EdgeInsets.only(top: 0, left: 5, bottom: 15, right: 0),
                        child: (article != null)
                            ? Text(article.title + "  🔗",
                                style: Theme.of(context).primaryTextTheme.title)
                            : Text(
                                "loading...",
                                style: Theme.of(context).primaryTextTheme.title,
                              ))),
                //OauthInfoWidget(),
              ],
            )));
  }
}
