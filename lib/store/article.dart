import 'package:dio/dio.dart';

postArticle() async {
  Dio dio = new Dio();
  var response = await dio
      .post("http://localhost:3004/api/analysis", data: {"content": "big zhu"});
  print(response.data);
}
