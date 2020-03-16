import "store.dart";
import 'package:shared_preferences/shared_preferences.dart';

initSharedPreferences() async {
  if (Store.prefs != null) return Store.prefs;
  Store.prefs = await SharedPreferences.getInstance();
}
