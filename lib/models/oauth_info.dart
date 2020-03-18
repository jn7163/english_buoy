import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../store/sign.dart';
import '../store/store.dart';

class OauthInfo with ChangeNotifier {
  String accessToken;
  String email;
  String name;
  String avatarURL;
  bool loading = false;
  GoogleSignIn _googleSignIn;
  GoogleSignInAccount _currentUser;
  Future Function() setAccessTokenCallBack;

  OauthInfo() {
    _googleSignIn = GoogleSignIn(
      scopes: <String>[
        'profile',
      ],
    );
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      _currentUser = account;
      if (_currentUser != null) handleGetContact();
    });
  }

  signoDone() {
    if (setAccessTokenCallBack != null) setAccessTokenCallBack();
    this.loading = false;
    notifyListeners();
  }

  handleGetContact() async {
    GoogleSignInAuthentication authentication =
        await _currentUser.authentication;
    //put user info to server
    await putAccount(_currentUser, authentication);
    this.setToShared(authentication.accessToken, _currentUser.email,
        _currentUser.displayName, _currentUser.photoUrl);
    this.signoDone();
  }

  switchUser() async {
    await this.disconnect();
    signIn();
  }

  disconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (e) {
      print(e.toString());
    }
  }

  signIn() async {
    print("signIn");
    this.loading = true;
    notifyListeners();
    try {
      _googleSignIn.signIn();
    } catch (e) {
      print("something wrong: $e");
      this.signIn();
    }
  }

  // set login info to shared
  setToShared(
      String accessToken, String email, String name, String avatarURL) async {
    // 如果从未登录转换到登录, 那么返回需要跳转
    this.accessToken = accessToken;
    this.email = email;
    this.name = name;
    this.avatarURL = avatarURL;
    await Store.prefs
      ..setString('accessToken', this.accessToken)
      ..setString('email', this.email)
      ..setString('name', this.name)
      ..setString('avatarURL', this.avatarURL);
  }

  backFromShared() async {
    var prefs = await Store.prefs;
    this.email = prefs.getString('email');
    this.accessToken = prefs.getString('accessToken');
    this.name = prefs.getString('name');
    this.avatarURL = prefs.getString('avatarURL');
    // if is logined, run callback to get articlelist
    if (this.accessToken != null)
      this.signoDone();
    else
      this.signIn();
  }

  removeFromShared() async {
    await Store.prefs
      ..remove('accessToken')
      ..remove('email')
      ..remove('name')
      ..remove('avatarURL');
  }

  signOut() async {
    this.loading = true;
    await this.disconnect();
    this.email = null;
    removeFromShared();
  }
}
