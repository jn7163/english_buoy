import 'package:flutter/material.dart';
import '../store/setting.dart';

class Setting with ChangeNotifier {
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

  // 构造函数从缓存获取
  Setting() {
    getFromLocal();
  }

  setIsAutoplay(bool v) async {
    await setLocalBool(isAutoplayKey, v);
    isAutoplay = v;
    notifyListeners();
  }

  setIsJump(bool v) async {
    await setLocalBool(isJumpKey, v);
    isJump = v;
    notifyListeners();
  }

  setIsDark(bool v) async {
    await setLocalBool(isDarkKey, v);
    isDark = v;
    notifyListeners();
  }

  setFromPercent(String v) async {
    await setLocalString(fromPercentKey, v);
    fromPercent = v;
  }

  setToPercent(String v) async {
    await setLocalString(toPercentKey, v);
    toPercent = v;
  }

  getFromLocal() async {
    bool jump = await getLocalBool(isJumpKey);
    setIsJump(jump);
    bool dark = await getLocalBool(isDarkKey);
    setIsDark(dark);
    bool autoplay = await getLocalBoolDefaultTrue(isAutoplayKey);
    setIsAutoplay(autoplay);
    String from = await getLocalString(fromPercentKey);
    setFromPercent(from);
    String to = await getLocalString(toPercentKey);
    setToPercent(to);
  }
}
