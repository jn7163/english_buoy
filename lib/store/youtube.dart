import 'package:dio/dio.dart';
import './store.dart';

// add new youtube to server
Future newYouTube(String youtube) async {
  Dio dio = getDio();
  return await dio.post(Store.baseURL + "Subtitle", data: {"Youtube": youtube});
}
