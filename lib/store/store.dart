import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class Store {
  static const baseURL = "https://english.bigzhu.net/api/";
  static const PATH = "assets/db/wordwise.db";
  //static const baseURL = "http://192.168.43.231:3004/api/";
  static SharedPreferences _prefs;
  static String accessToken;

  static Database database;
  static Map wordwiseMap = Map<String, String>();
  static Map noWordwiseMap = Map<String, String>();

  static Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs;
    _prefs = await SharedPreferences.getInstance();
    return _prefs;
  }

  static init() async {
    SharedPreferences prefs = await Store.prefs;
    Store.accessToken = prefs.getString('accessToken');
  }
}

Dio dio() {
  Dio _dio = Dio();
  // 发送请求前加入 token
  _dio.interceptors.add(InterceptorsWrapper(onRequest: (Options options) {
    options.headers["token"] = Store.accessToken;
    return options; //continue
  }, onError: (DioError e) {
    print("dio error: $e");
    return e;
  }));
  return _dio;
}
