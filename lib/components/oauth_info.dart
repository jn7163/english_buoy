import 'package:flutter/material.dart';
import 'package:provide/provide.dart';
import '../models/oauth_info.dart';

class OauthInfoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provide<OauthInfo>(builder: (context, child, oauthInfo) {
      if (oauthInfo.email == null) {
        return IconButton(
          icon: Icon(Icons.exit_to_app),
          tooltip: 'Sign',
          onPressed: () {
            Navigator.pushNamed(context, '/Sign');
          },
        );
      } else {
        return GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/Sign');
            },
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(oauthInfo.avatarURL),
                )));
      }
    });
  }
}
