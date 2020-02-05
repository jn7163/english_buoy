import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/oauth_info.dart';

//登录后显示头像的组件
// loading 时候显示 loading
class OauthInfoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<OauthInfo>(builder: (context, oauthInfo, child) {
      if (oauthInfo.email == null) {
        return IconButton(
          icon: Icon(Icons.exit_to_app),
          tooltip: 'Sign',
          onPressed: () {},
        );
      } else {
        return Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
                backgroundImage: oauthInfo.avatarURL != null
                    ? NetworkImage(oauthInfo.avatarURL)
                    : AssetImage('assets/images/logo.png')));
      }
    });
  }
}
