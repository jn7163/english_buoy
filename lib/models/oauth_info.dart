import 'package:flutter/material.dart';

class OauthInfo with ChangeNotifier {
  String accessToken;
  String email;
  String name;
  String avatarURL;

  set(accessToken, email, name, avatarURL) {
    this.accessToken = accessToken;
    this.email = email;
    this.name = name;
    this.avatarURL = avatarURL;
    notifyListeners();
  }

  signOut() {
    this.email = null;
    notifyListeners();
  }
}
