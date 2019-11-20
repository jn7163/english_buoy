import 'dart:async';
import 'package:ebuoy/components/config_autoplay.dart';
import 'package:ebuoy/components/config_dark_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../store/sign.dart';
import '../models/oauth_info.dart';
import '../models/article_titles.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'profile',
  ],
);

class SignInPage extends StatefulWidget {
  @override
  State createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      if (account != null) {
        account.authentication.then((GoogleSignInAuthentication authentication) {
          // google 用户注册到服务器后, 记录 token
          putAccount(account, authentication).then((d) {
            var oauthInfo = Provider.of<OauthInfo>(context, listen: false);
            bool needJump = oauthInfo.set(
                authentication.accessToken, account.email, account.displayName, account.photoUrl);
            //登录后自动跳转
            if (needJump) Navigator.pushNamed(context, '/ArticleTitles');
          });
        });
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() async {
    var oauthInfo = Provider.of<OauthInfo>(context, listen: false);
    oauthInfo.signOut();
    // 需要清空文章列表
    var articles = Provider.of<ArticleTitles>(context, listen: false);
    articles.clear();
    _googleSignIn.disconnect();
  }

  Widget _buildBody() {
    return Consumer<OauthInfo>(builder: (context, oauthInfo, _) {
      if (oauthInfo.email != null) {
        return Column(
          //mainAxisAlignment: MainAxisAlignment.spaceAround,
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
            RaisedButton(
              child: const Text('Logout'),
              onPressed: _handleSignOut,
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
            onPressed: _handleSignIn,
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
          title: const Text('Google Sign In And Config'),
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ));
  }
}
