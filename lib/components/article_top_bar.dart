import 'package:ebuoy/models/article.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'article_youtube_avatar.dart';

// 文章对应的 youtube 图标或者头像
class ArticleTopBar extends StatelessWidget {
  const ArticleTopBar({this.article, Key key}) : super(key: key);
  final Article article;
  final TextStyle textStyle = const TextStyle(
      color: Colors.white, fontSize: 20, fontFamily: "NotoSans-Medium");
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 8, top: 30),
        color: Theme.of(context).primaryColorDark,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            ArticleYoutubeAvatar(
              youtubeURL: article.youtube,
              avatar: article.avatar,
            ),
            Expanded(
                child: Container(
                    padding:
                        EdgeInsets.only(top: 10, left: 5, bottom: 15, right: 0),
                    child: (article != null)
                        ? Text(article.title, style: textStyle)
                        : Text("loading..."))),
            //OauthInfoWidget(),
          ],
        ));
  }
}
