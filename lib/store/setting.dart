import 'package:shared_preferences/shared_preferences.dart';

setLocalBool(String key, bool v) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(key, v);
}

getLocalBool(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key) ?? false;
}
