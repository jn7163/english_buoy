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
              backgroundColor: Theme.of(context).primaryColorDark,
              //automaticallyImplyLeading: false,
              leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                      backgroundImage: oauthInfo.avatarURL != null
                          ? NetworkImage(oauthInfo.avatarURL)
                          : AssetImage('assets/images/logo.png'))),
              actions: <Widget>[Container()],
              centerTitle: true,
              title: Text(
                "User Profile",
              )),
          ListTile(
            title: Center(child: Text(oauthInfo.name)),
            subtitle: Center(child: Text(oauthInfo.email)),
          ),
          RaisedButton(
            child: const Text('switch user'),
            onPressed: () {
              oauthInfo.switchUser();
              Navigator.of(context).pop();
            },
          ),
          Text(""),
          Text("version: 1.4.08")
        ],
      );
    }));
  }
}
