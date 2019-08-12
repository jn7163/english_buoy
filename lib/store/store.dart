import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bus.dart';

class Store {
  // static const baseURL = "http://10.0.0.11:3004/api/";
  // static const baseURL = "http://123.176.102.187:3004/api/";
  static const baseURL = "https://english.bigzhu.net/api/";
}

Dio getDio(BuildContext context) {
  Dio dio = new Dio();
  // 发送请求前加入 token
  dio.interceptors.add(InterceptorsWrapper(onRequest: (Options options) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessTokenShare = prefs.getString('accessToken');
    options.headers["token"] = accessTokenShare;
    return options; //continue
  }, onError: (DioError e) {
    // Do something with response error
    print("bigzhu:" + e.toString());
    if (e.response != null && e.response.statusCode == 401) {
      bus.emit('pop_show', 'need login');
      Navigator.pushNamed(context, '/Sign');
      return null;
    } else
      return e; //continue
  }));

  return dio;
}
