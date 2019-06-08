import 'package:flutter/material.dart';
import 'package:provide/provide.dart';
import '../models/oauth_info.dart';
import '../models/top_loading.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class OauthInfoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provide<TopLoading>(builder: (context, child, topLoading) {
      return Provide<OauthInfo>(builder: (context, child, oauthInfo) {
        if (topLoading.loading) {
          return SpinKitChasingDots(
            color: Colors.white,
            size: 50.0,
          );
        }
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
    });
  }
}
