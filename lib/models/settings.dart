import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings with ChangeNotifier {
  bool isJump = false;
  bool isDark = false;
  bool isAutoplay = true;
  String fromPercent = "";
  String toPercent = "";
  String fromPercentKey = "fromPercent";
  String toPercentKey = "toPercent";
  String isJumpKey = "isJump";
  String isDarkKey = "isDark";
  String isAutoplayKey = "isAutoplay";
  SharedPreferences prefs;

  // 构造函数从缓存获取
  Settings() {
    SharedPreferences.getInstance().then((d) {
      prefs = d;
      getFromLocal();
    });
  }

  setIsAutoplay(bool v) async {
    await prefs.setBool(isAutoplayKey, v);
    isAutoplay = v;
    notifyListeners();
  }

  setIsJump(bool v) async {
    await prefs.setBool(isJumpKey, v);
    isJump = v;
    notifyListeners();
  }

  setIsDark(bool v) async {
    await prefs.setBool(isDarkKey, v);
    isDark = v;
    notifyListeners();
  }

  setFromPercent(String v) async {
    await prefs.setString(fromPercentKey, v) ?? "";
    fromPercent = v;
  }

  setToPercent(String v) async {
    await prefs.setString(toPercentKey, v) ?? "";
    toPercent = v;
  }

  getFromLocal() async {
    bool jump = prefs.getBool(isJumpKey) ?? false;
    setIsJump(jump);
    bool dark = prefs.getBool(isDarkKey) ?? false;
    setIsDark(dark);

    //if not set, default is true
    bool autoplay;
    if (prefs.containsKey(isAutoplayKey))
      autoplay = prefs.getBool(isAutoplayKey) ?? true;
    else
      autoplay = true;
    setIsAutoplay(autoplay);

    String from = prefs.getString(fromPercentKey);
    setFromPercent(from);
    String to = prefs.getString(toPercentKey);
    setToPercent(to);
  }
}
