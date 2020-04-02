import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class YouTubeThumbnail extends StatelessWidget {
  YouTubeThumbnail({Key key, @required this.thumbnailURL, this.backgroundColor = Colors.transparent, this.height, this.width})
      : super(key: key);
  final String thumbnailURL;
  final Color backgroundColor;
  final double height;
  final double width;
  @override
  Widget build(BuildContext context) {
    return Container(
        color: backgroundColor, // must have color property otherwise can't tap to enter
        height: MediaQuery.of(context).size.width * 9 / 16,
        width: MediaQuery.of(context).size.width,
        child: CachedNetworkImage(
          height: MediaQuery.of(context).size.width * 9 / 16,
          width: MediaQuery.of(context).size.width,
          //BoxFit.fill don't work
          //fit: BoxFit.fill,
          imageUrl: thumbnailURL,
          errorWidget: (context, url, error) {
            return Container(
                height: MediaQuery.of(context).size.width * 9 / 16,
                child: Center(
                  child: Text("Please check your network and try again later.\n$error",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        //fontWeight: controller.selectedArticleID == articleTitle.id ? FontWeight.bold : null)), // 用的 TextTheme.subhead
                      )),
                ));
          },
          //placeholder: (context, url) => const CircularProgressIndicator(),
        ));
  }
}
