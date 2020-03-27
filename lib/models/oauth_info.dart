import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../store/sign.dart';
import '../store/store.dart';
import './controller.dart';

class OauthInfo with ChangeNotifier {
  Controller controller; // use to show info
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
    GoogleSignInAuthentication authentication = await _currentUser.authentication;
    //put user info to server
    await putAccount(_currentUser, authentication);
    await this.setToShared(authentication.accessToken, _currentUser.email, _currentUser.displayName, _currentUser.photoUrl);
    Store.init();
    this.signoDone();
  }

  switchUser() async {
    await this.disconnect();
    signIn();
  }

  Future disconnect() async {
    return _googleSignIn.disconnect().catchError((e) {
      String info = "sign out Error: $e";
      debugPrint(info);
      if (this.controller != null) this.controller.showSnackBar(info);
    });
  }

  signIn() async {
    this.loading = true;
    notifyListeners();
    _googleSignIn.signIn().catchError((e) {
      String info = "Please check your network!\nError: $e \nTry again...";
      debugPrint(info);
      if (this.controller != null) this.controller.showSnackBar(info);
      Future.delayed(Duration(seconds: 4), () => this.signIn());
    });
  }

  // set login info to shared
  setToShared(String accessToken, String email, String name, String avatarURL) async {
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
