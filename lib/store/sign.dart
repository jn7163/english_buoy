import './store.dart';
import 'package:google_sign_in/google_sign_in.dart';

// 记录登录的用户信息
Future putAccount(GoogleSignInAccount account, GoogleSignInAuthentication authentication) async {
  var response = await dio().put(Store.baseURL + "account", data: {"type": "google", "out_id": account.id, "email": account.email, "avatar_url": account.photoUrl, "name": account.displayName, "access_token": authentication.accessToken});
  return response.data;
}
