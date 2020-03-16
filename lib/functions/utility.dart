import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
//import 'package:device_info/device_info.dart';

Widget getSpinkitProgressIndicator(BuildContext context) {
  return SpinKitRipple(
    color: Theme.of(context).primaryColorLight,
    size: 340.0,
  );
}

/*
Future<String> getDeviceID() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  print('Running on ${androidInfo.model}'); // e.g. "Moto G (4)"

  IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  print('Running on ${iosInfo.utsname.machine}'); // e.g. "iPod7,1"
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
  }
  //print(e.response.headers);
  //print(e.response.request);
  else {
    // Something happened in setting up or sending the request that triggered an Error
    print(e.request);
    print(e.message);
  }
  return false;
}
