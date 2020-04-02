import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/oauth_info.dart';

// 左边抽屉
class LeftDrawer extends StatelessWidget {
  const LeftDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    OauthInfo _oauthInfo = Provider.of<OauthInfo>(context, listen: false);
    Selector selectorAvatar = Selector<OauthInfo, String>(
        selector: (context, oauthInfo) => oauthInfo.avatarURL,
        builder: (context, avatarURL, child) {
          return CircleAvatar(
              backgroundImage: avatarURL != null ? NetworkImage(avatarURL) : AssetImage('assets/images/logo.png'));
        });

    Selector selectorName = Selector<OauthInfo, String>(
        selector: (context, oauthInfo) => oauthInfo.name,
        builder: (context, name, child) {
          return Text(name);
        });

    Selector selectorEmail = Selector<OauthInfo, String>(
        selector: (context, oauthInfo) => oauthInfo.email,
        builder: (context, email, child) {
          return Text(email);
        });

    return Drawer(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppBar(
            backgroundColor: Theme.of(context).primaryColorDark,
            //automaticallyImplyLeading: false,
            leading: Padding(padding: const EdgeInsets.all(8.0), child: selectorAvatar),
            actions: <Widget>[Container()],
            centerTitle: true,
            title: Text(
              "User Profile",
            )),
        ListTile(
          title: Center(child: selectorName),
          subtitle: Center(child: selectorEmail),
        ),
        RaisedButton(
          child: const Text('switch user'),
          onPressed: () {
            _oauthInfo.switchUser();
            Navigator.of(context).pop();
          },
        ),
        Divider(),
        Text("version: 1.4.18")
      ],
    ));
  }
}
