import 'package:dio/dio.dart';
// import '../bus.dart';
import './store.dart';

Dio dio = new Dio();
// 记录学过的单词
putLearn(String word) async {
  // Dio dio = new Dio();
  print('putLearn');
  var response = await dio.put(Store.baseURL + "learn", data: {"word": word});
  return response.data;
}

// 记录学过的单词
putLearned(String word, bool isLearned) async {
  // print('putLearned');
  var response = await dio.put(Store.baseURL + "learned",
      data: {"word": word, "learned": isLearned});
  return response.data;
}
