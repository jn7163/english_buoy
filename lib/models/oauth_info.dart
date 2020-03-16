import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../store/sign.dart';
import '../store/store.dart';
import '../store/shared_preferences.dart';

class OauthInfo with ChangeNotifier {
  String accessToken;
  String email;
  String name;
  String avatarURL;
  bool loading;
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
    setAccessTokenCallBack();
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
    await _googleSignIn.disconnect();
    signIn();
  }

  Future signIn() async {
    print("signIn");
    this.loading = true;
    notifyListeners();
    return _googleSignIn.signIn();
  }

  // set login info to shared
  setToShared(String accessToken, String email, String name, String avatarURL) {
    // 如果从未登录转换到登录, 那么返回需要跳转
    this.accessToken = accessToken;
    this.email = email;
    this.name = name;
    this.avatarURL = avatarURL;
    Store.prefs
      ..setString('accessToken', this.accessToken)
      ..setString('email', this.email)
      ..setString('name', this.name)
      ..setString('avatarURL', this.avatarURL);
    // make sure dio use new access token
    Store.recreateDio();
  }

  backFromShared() async {
    if (Store.prefs == null) await initSharedPreferences();
    this.email = Store.prefs.getString('email');
    this.accessToken = Store.prefs.getString('accessToken');
    this.name = Store.prefs.getString('name');
    this.avatarURL = Store.prefs.getString('avatarURL');
    // if is logined, run callback to get articlelist
    if (this.accessToken != null)
      this.signoDone();
    else
      this.signIn();
  }

  removeFromShared() async {
    Store.prefs
      ..remove('accessToken')
      ..remove('email')
      ..remove('name')
      ..remove('avatarURL');
  }

  signOut() async {
    await _googleSignIn.disconnect();
    this.email = null;
    removeFromShared();
  }
}
