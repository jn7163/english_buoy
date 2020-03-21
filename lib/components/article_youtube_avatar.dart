import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

// 文章对应的 youtube 图标或者头像
// 删除时候显示 loading 动画
class ArticleYoutubeAvatar extends StatelessWidget {
  const ArticleYoutubeAvatar({
    Key key,
    @required this.avatar,
    @required this.loading,
  }) : super(key: key);
  final String avatar;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) return RefreshProgressIndicator();
    return CircleAvatar(
      backgroundImage: avatar == null || avatar == '' ? AssetImage('assets/images/logo.png') : CachedNetworkImageProvider(avatar),
    );
  }
}
