import 'package:flutter/cupertino.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// 启动 youtube 的浮动按钮
class LaunchYoutubeButton extends StatelessWidget {
  const LaunchYoutubeButton({
    Key key,
    @required this.youtubeURL,
  }) : super(key: key);
  final String youtubeURL;

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: youtubeURL != '',
        child: FloatingActionButton(
          onPressed: () {
            _launchURL(youtubeURL);
          },
          tooltip: 'open youtube',
          child: Icon(FontAwesomeIcons.youtube,
              color: Theme.of(context).primaryTextTheme.title.color),
          //backgroundColor: Colors.grey[400],
        ));
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
