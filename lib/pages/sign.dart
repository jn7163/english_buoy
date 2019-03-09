import 'dart:async';
import 'package:provide/provide.dart';

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
        account.authentication
            .then((GoogleSignInAuthentication authentication) {
          var oauthInfo = Provide.value<OauthInfo>(context);
          var articles = Provide.value<ArticleTitles>(context);
          // google 用户注册到服务器后, 记录 token
          putAccount(account, authentication).then((d) {
            oauthInfo.set(authentication.accessToken, account.email,
                account.displayName, account.photoUrl);
            //登录后从服务器获取
            articles.syncServer();
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
    var oauthInfo = Provide.value<OauthInfo>(context);
    oauthInfo.signOut();
    // 需要清空文章列表
    var articles = Provide.value<ArticleTitles>(context);
    articles.clear();
    _googleSignIn.disconnect();
  }

  Widget _buildBody() {
    return Provide<OauthInfo>(builder: (context, child, oauthInfo) {
      if (oauthInfo.email != null) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(oauthInfo.avatarURL),
              ),
              title: Text(oauthInfo.name),
              subtitle: Text(oauthInfo.email),
            ),
            RaisedButton(
              child: const Text('退出'),
              onPressed: _handleSignOut,
            ),
          ],
        );
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          RaisedButton(
            child: const Text('登录'),
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
