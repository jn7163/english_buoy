import 'package:flutter/material.dart';
import '../store/setting.dart';

class Setting with ChangeNotifier {
  bool isJump = false;
  bool isDark = false;
  String isJumpKey = "isJump";
  String isDarkKey = "isDark";

  // 构造函数从缓存获取
  Setting() {
    setFromLocal();
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
  }
}
