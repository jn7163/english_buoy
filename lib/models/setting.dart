import 'package:flutter/material.dart';
import '../store/setting.dart';

class Setting with ChangeNotifier {
  bool isJump = false;
  bool isDark = false;
  bool isAutoplay = true;
  String isJumpKey = "isJump";
  String isDarkKey = "isDark";
  String isAutoplayKey = "isAutoplay";

  // 构造函数从缓存获取
  Setting() {
    setFromLocal();
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

  setFromLocal() async {
    bool jump = await getLocalBool(isJumpKey);
    setIsJump(jump);
    bool dark = await getLocalBool(isDarkKey);
    setIsDark(dark);
    bool autoplay = await getLocalBool(isAutoplayKey);
    // default is true, so when local not set or false, make it is true
    setIsAutoplay(!autoplay);
  }
}
