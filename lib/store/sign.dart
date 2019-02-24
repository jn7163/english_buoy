import 'package:dio/dio.dart';
import './store.dart';
import 'package:google_sign_in/google_sign_in.dart';

Dio dio = new Dio();
// 记录登录的用户信息
putAccount(GoogleSignInAccount account) async {
  print('putAccount');
  var response = await dio.put(Store.baseURL + "account",
      data: {"email": account.email, "": account.id});
  return response.data;
}
