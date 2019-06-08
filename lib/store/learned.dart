import 'package:dio/dio.dart';
import '../bus.dart';
import './store.dart';

Dio dio = getDio();
// 记录学过的单词
putLearn(String word) async {
  // Dio dio = new Dio();
  print('putLearn');
  try {
    var response = await dio.put(Store.baseURL + "learn", data: {"word": word});
    return response.data;
  } on DioError catch (e) {
    bus.emit('pop_show', e.message);
  }
}

// 记录学过的单词
putLearned(String word, bool isLearned) async {
  print('putLearned');
  var response = await dio.put(Store.baseURL + "learned",
      data: {"word": word, "learned": isLearned});
  return response.data;
}
