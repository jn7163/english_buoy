import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/oauth_info.dart';

// 左边抽屉
class LeftDrawer extends StatelessWidget {
  const LeftDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(child: Consumer<OauthInfo>(builder: (context, oauthInfo, _) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppBar(
              //automaticallyImplyLeading: false,
              leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(oauthInfo.avatarURL == null
                        ? "https://ebuoydoc.bigzhu.net/assets/img/ic_launcher_APP.png"
                        : oauthInfo.avatarURL),
                  )),
              actions: <Widget>[Container()],
              centerTitle: true,
              title: Text(
                "Profile",
              )),
          ListTile(
            title: Center(child: Text(oauthInfo.name)),
            subtitle: Center(child: Text(oauthInfo.email)),
          ),
          RaisedButton(
            child: const Text('switch user'),
            onPressed: () => oauthInfo.switchUser(),
          ),
          Text(""),
          Text("version: 1.2.15")
        ],
      );
    }));
  }
}
