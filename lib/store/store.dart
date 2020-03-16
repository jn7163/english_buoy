import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class Store {
  static const baseURL = "https://english.bigzhu.net/api/";
  static const PATH = "assets/db/wordwise.db";
  //static const baseURL = "http://192.168.43.231:3004/api/";
  static SharedPreferences prefs;
  static Dio _dio;

  static Database database;
  static Map wordwiseMap = Map<String, String>();
  static Map noWordwiseMap = Map<String, String>();

  static Dio get dio {
    if (_dio != null) return _dio;
    _dio = Dio();
    // 发送请求前加入 token
    _dio.interceptors
        .add(InterceptorsWrapper(onRequest: (Options options) async {
      String accessTokenShare = prefs.getString('accessToken');
      options.headers["token"] = accessTokenShare;
      return options; //continue
    }, onError: (DioError e) {
      // Do something with response error
      print(e.toString());
      return e;
    }));
    return _dio;
  }

  static recreateDio() {
    _dio = null;
    print(dio.toString());
  }
}
