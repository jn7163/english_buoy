import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Store {
  static const baseURL = "https://english.bigzhu.net/api/";
  //static const baseURL = "http://192.168.43.231:3004/api/";
}

Dio getDio() {
  Dio dio = Dio();
  // 发送请求前加入 token
  dio.interceptors.add(InterceptorsWrapper(onRequest: (Options options) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String accessTokenShare = prefs.getString('accessToken');
    options.headers["token"] = accessTokenShare;
    return options; //continue
  }, onError: (DioError e) {
    // Do something with response error
    print(e.toString());
    return e;
  }));

  return dio;
}
