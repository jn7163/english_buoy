import 'package:shared_preferences/shared_preferences.dart';

setIsJumpWord(bool isJump) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool("isJump", isJump);
}

getIsJumpWord() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool("isJump") ?? false;
}
