import 'package:shared_preferences/shared_preferences.dart';

setLocalString(String key, String v) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, v);
}

setLocalDouble(String key, double v) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setDouble(key, v);
}

setLocalBool(String key, bool v) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(key, v);
}
getLocalString(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key) ?? "";
}
getLocalBool(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key) ?? false;
}

getLocalBoolDefaultTrue(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey(key))
    return prefs.getBool(key);
  else
    return true;
}
