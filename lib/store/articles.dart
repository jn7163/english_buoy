import 'package:dio/dio.dart';
import '../bus.dart';
import './store.dart';

Dio dio = new Dio();
getArticleTitles() async {
  print('getArticleTitles');
  var response = await dio.get(Store.baseURL + "article_titles");
  bus.emit('get_article_titles_done', response.data);

  return response.data;
}
