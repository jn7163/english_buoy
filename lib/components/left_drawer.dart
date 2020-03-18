import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/oauth_info.dart';

// 左边抽屉
class LeftDrawer extends StatelessWidget {
  const LeftDrawer({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    OauthInfo _oauthInfo = Provider.of<OauthInfo>(context, listen: false);
    Consumer consumerAvatar =
        Consumer<OauthInfo>(builder: (context, oauthInfo, _) {
      return CircleAvatar(
          backgroundImage: oauthInfo.avatarURL != null
              ? NetworkImage(oauthInfo.avatarURL)
              : AssetImage('assets/images/logo.png'));
    });

    Consumer consumerName =
        Consumer<OauthInfo>(builder: (context, oauthInfo, _) {
      return Text(oauthInfo.name);
    });
    Consumer consumerEmail =
        Consumer<OauthInfo>(builder: (context, oauthInfo, _) {
      return Text(oauthInfo.email);
    });

    return Drawer(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppBar(
            backgroundColor: Theme.of(context).primaryColorDark,
            //automaticallyImplyLeading: false,
            leading: Padding(
                padding: const EdgeInsets.all(8.0), child: consumerAvatar),
            actions: <Widget>[Container()],
            centerTitle: true,
            title: Text(
              "User Profile",
            )),
        ListTile(
          title: Center(child: consumerName),
          subtitle: Center(child: consumerEmail),
        ),
        RaisedButton(
          child: const Text('switch user'),
          onPressed: () {
            _oauthInfo.switchUser();
            Navigator.of(context).pop();
          },
        ),
        Text(""),
        Text("version: 1.4.08")
      ],
    ));
  }
}
