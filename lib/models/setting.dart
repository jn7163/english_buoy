import 'package:flutter/material.dart';
import '../store/setting.dart';

class Setting with ChangeNotifier {
  bool isJump = false;
  // 构造函数从缓存获取
  Setting() {
    setFromLocal();
  }
  set(bool v) async {
    await setIsJumpWord(v);
    isJump = v;
    notifyListeners();
  }

  setFromLocal() async {
    bool jump = await getIsJumpWord();
    set(jump);
  }
}
