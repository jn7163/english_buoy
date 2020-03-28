import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
//import 'package:device_info/device_info.dart';

Widget getSpinkitProgressIndicator(BuildContext context, {color}) {
  return SpinKitRipple(
    color: color ?? Theme.of(context).primaryColorLight,
    size: 340.0,
  );
}

/*
Future<String> getDeviceID() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

  IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  return androidInfo.androidId;
}
*/

Duration toDuration(String time) {
  return Duration(
    milliseconds: (double.parse(time) * 1000).round(),
  );
}

bool isAccessTokenError(dynamic e) {
  if (e.response != null) {
    if (e.response.statusCode == 401) return true;
  } else {
    // Something happened in setting up or sending the request that triggered an Error
    debugPrint("${e.request}");
    debugPrint("${e.message}");
  }
  return false;
}
