import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../store/sign.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  GoogleSignInAccount _currentUser;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      if (account != null) {
        account.authentication
            .then((GoogleSignInAuthentication authentication) {
          setState(() {
            _currentUser = account;
          });
          // google 用户注册到服务器后, 记录 token
          putAccount(account, authentication).then((d) {
            _setToShared(authentication.accessToken);
            // render 当前 widget
          });
        });
      }
    });
    _googleSignIn.signInSilently();
  }

  void _setToShared(String accessToken) async {
    // 登录后存储到临时缓存中
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessTokenShare = prefs.getString('accessToken');
    print('accessToken: $accessTokenShare');
    await prefs.setString('accessToken', accessToken);
    accessTokenShare = prefs.getString('accessToken');
    print('accessToken: $accessTokenShare');
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() async {
    _setToShared("");
    _googleSignIn.disconnect();
  }

  Widget _buildBody() {
    if (_currentUser != null) {
      print(_currentUser.photoUrl);
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(_currentUser.photoUrl),
            ),
            title: Text(_currentUser.displayName),
            subtitle: Text(_currentUser.email),
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
