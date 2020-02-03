import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../store/sign.dart';

class OauthInfo with ChangeNotifier {
  String accessToken;
  String email;
  String name;
  String avatarURL;
  GoogleSignIn _googleSignIn;
  GoogleSignInAccount _currentUser;
  Function setAccessTokenCallBack;

  OauthInfo() {
    // set callback to _googleSignIn
    _googleSignIn = GoogleSignIn(
      scopes: <String>[
        'profile',
      ],
    );
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      _currentUser = account;
      if (_currentUser != null) {
        _handleGetContact();
      }
    });
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      if (account != null) {
        account.authentication
            .then((GoogleSignInAuthentication authentication) {
          // google 用户注册到服务器后, 记录 token
          putAccount(account, authentication).then((d) {
            this.setAccessToken(authentication.accessToken, account.email,
                account.displayName, account.photoUrl);
          });
        });
      }
    });
  }

  Future _handleGetContact() async {
    _currentUser.authentication
        .then((GoogleSignInAuthentication authentication) {
      // google 用户注册到服务器后, 记录 token
      putAccount(_currentUser, authentication).then((d) {
        this.setAccessToken(authentication.accessToken, _currentUser.email,
            _currentUser.displayName, _currentUser.photoUrl);
      });
    });
  }

  Future switchUser() async {
    try {
      await _googleSignIn.disconnect();
    } catch (error) {
      print(error);
    }
    return signIn();
  }

  Future signIn() async {
    print("signIn");
    return _googleSignIn.signIn();
  }

  setAccessToken(
      String accessToken, String email, String name, String avatarURL) async {
    // 如果从未登录转换到登录, 那么返回需要跳转
    this.accessToken = accessToken;
    this.email = email;
    this.name = name;
    this.avatarURL = avatarURL;
    await _setToShared();
    setAccessTokenCallBack();
    notifyListeners();
  }

  Future backFromShared() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.email = prefs.getString('email');
    if (this.email != null) {
      this.setAccessToken(prefs.getString('accessToken'), this.email,
          prefs.getString('name'), prefs.getString('avatarURL'));
      //已经登录就同步列表
      return setAccessTokenCallBack();
    } else {
      return this.signIn();
    }
  }

  _setToShared() async {
    // 登录后存储到临时缓存中
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs
      ..setString('accessToken', this.accessToken)
      ..setString('email', this.email)
      ..setString('name', this.name)
      ..setString('avatarURL', this.avatarURL);
  }

  _removeShared() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs
      ..remove('accessToken')
      ..remove('email')
      ..remove('name')
      ..remove('avatarURL');
  }

  signOut() async {
    await _googleSignIn.disconnect();
    this.email = null;
    _removeShared();
    notifyListeners();
  }
}
