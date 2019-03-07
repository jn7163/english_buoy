import 'package:flutter/material.dart';
import 'package:provide/provide.dart';
import '../pages/sign.dart';
import '../models/oauth_info.dart';

class OauthInfoWidget extends StatelessWidget {
  _toSignPage(BuildContext context) {
    //导航到新路由
    Navigator.push(
        context,
        MaterialPageRoute(
            maintainState: false, // 每次都新建一个详情页
            builder: (context) {
              return SignInPage();
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Provide<OauthInfo>(builder: (context, child, oauthInfo) {
      if (oauthInfo.email == null) {
        return IconButton(
          icon: Icon(Icons.exit_to_app),
          tooltip: 'Sign',
          onPressed: () {
            this._toSignPage(context);
          },
        );
      } else {
        return GestureDetector(
            onTap: () {
              this._toSignPage(context);
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
