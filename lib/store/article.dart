import 'package:dio/dio.dart';
import '../bus.dart';
import './store.dart';

Dio dio = new Dio();
// 提交新的文章进行分析
postArticle(String article) async {
  if (article == "") {
    article = """

    test
    this is test article.
    please give me some money!
    """;
  }
  print('post analysis');
  var response = await dio
      .post(Store.baseURL + "api/analysis", data: {"article": article});
  bus.emit('analysis_done', response.data);
  return response.data;
}

// 根据标题查询文章内容
getArticleByTitle(String title) async {
  print('get articles');
  var response = await dio
      .get(Store.baseURL + "api/article/" + Uri.encodeComponent(title));
  bus.emit('get_article_done', response.data);
  return response.data;
}
