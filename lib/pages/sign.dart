import 'package:ebuoy/components/config_autoplay.dart';
import 'package:ebuoy/components/config_dark_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import '../models/oauth_info.dart';

class SignInPage extends StatefulWidget {
  @override
  State createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  @override
  void initState() {
    super.initState();
  }

  Widget _buildBody() {
    return Consumer<OauthInfo>(builder: (context, oauthInfo, _) {
      if (oauthInfo.email != null) {
        return Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(oauthInfo.avatarURL == null
                    ? "https://www.bigzhu.net/images/gou.jpg"
                    : oauthInfo.avatarURL),
              ),
              title: Text(oauthInfo.name),
              subtitle: Text(oauthInfo.email),
            ),
            //ConfigJumpToWord(),
            ConfigDarkTheme(),
            ConfigAutoPlay(),
            Text("version: 1.2.12"),
            RaisedButton(
              child: const Text('switch user'),
              onPressed: () => oauthInfo.switchUser(),
            ),
          ],
        );
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          RaisedButton.icon(
            label: Text('Login with Google'),
            icon: Icon(FontAwesomeIcons.google, color: Colors.red),
            onPressed: () => oauthInfo.signIn(),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    print("build sign");
    return Scaffold(
        appBar: AppBar(
          title: const Text('Config'),
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ));
  }
}
