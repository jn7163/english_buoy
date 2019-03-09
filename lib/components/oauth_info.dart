import 'package:flutter/material.dart';
import 'package:provide/provide.dart';
import '../models/oauth_info.dart';
import '../functions/router.dart';

class OauthInfoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provide<OauthInfo>(builder: (context, child, oauthInfo) {
      if (oauthInfo.email == null) {
        return IconButton(
          icon: Icon(Icons.exit_to_app),
          tooltip: 'Sign',
          onPressed: () {
            toSignPage(context);
          },
        );
      } else {
        return GestureDetector(
            onTap: () {
              toSignPage(context);
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
