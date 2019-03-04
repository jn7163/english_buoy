import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OauthInfo with ChangeNotifier {
  String accessToken;
  String email;
  String name;
  String avatarURL;
  set(String accessToken, String email, String name, String avatarURL) {
    this.accessToken = accessToken;
    this.email = email;
    this.name = name;
    this.avatarURL = avatarURL;
    _setToShared();
    notifyListeners();
  }

  backFromShared() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.email = prefs.getString('email');
    if (this.email != null) {
      this.set(prefs.getString('accessToken'), this.email,
          prefs.getString('name'), prefs.getString('avatarURL'));
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

  signOut() {
    this.email = null;
    _removeShared();
    notifyListeners();
  }
}
