import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// 文章对应的 youtube 图标或者头像
class ArticleYoutubeAvatar extends StatelessWidget {
  const ArticleYoutubeAvatar({this.youtubeURL, this.avatar, Key key})
      : super(key: key);
  final String youtubeURL;
  final String avatar;

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: youtubeURL != '',
        child: avatar == ''
            ? Icon(
                FontAwesomeIcons.youtube,
                color: Colors.red,
              )
            : CircleAvatar(
                backgroundImage: NetworkImage(avatar),
              ));
  }
}
