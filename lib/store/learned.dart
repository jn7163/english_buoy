import 'package:dio/dio.dart';
import './store.dart';

Dio dio = getDio();

// 记录学过的单词
putLearned(String word, bool isLearned) async {
  print('putLearned');
  var response = await dio.put(Store.baseURL + "learned",
      data: {"word": word, "learned": isLearned});
  return response.data;
}
