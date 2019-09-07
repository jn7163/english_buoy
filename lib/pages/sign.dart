import 'dart:async';
import 'package:ebuoy/components/config_dark_theme.dart';
import 'package:ebuoy/components/config_jump_to_word.dart';
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
          //var articles = Provider.of<ArticleTitles>(context);
          // google 用户注册到服务器后, 记录 token
          putAccount(account, authentication).then((d) {
            var oauthInfo = Provider.of<OauthInfo>(context);
            bool needJump = oauthInfo.set(
                authentication.accessToken, account.email, account.displayName, account.photoUrl);
            //登录后自动跳转
            if (needJump) Navigator.pushNamed(context, '/Articles');
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
    var oauthInfo = Provider.of<OauthInfo>(context);
    oauthInfo.signOut();
    // 需要清空文章列表
    var articles = Provider.of<ArticleTitles>(context);
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
                backgroundImage: NetworkImage(oauthInfo.avatarURL),
              ),
              title: Text(oauthInfo.name),
              subtitle: Text(oauthInfo.email),
            ),
            ConfigJumpToWord(),
            ConfigDarkTheme(),
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
    return Scaffold(
        appBar: AppBar(
          title: const Text('Google Sign In'),
        ),
        body: ConstrainedBox(
          constraints: const BoxConstraints.expand(),
          child: _buildBody(),
        ));
  }
}
