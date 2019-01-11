import 'package:dio/dio.dart';
import './store.dart';

Dio dio = new Dio();
getArticleTitles() async {
  print('getArticleTitles');
  var response = await dio.get(Store.baseURL + "article_titles");
  return response.data;
}
