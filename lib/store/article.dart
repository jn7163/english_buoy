import 'package:dio/dio.dart';
import '../bus.dart';
import './store.dart';

Dio dio = new Dio();
// 提交新的文章进行分析
postArticle(String article) async {
  print("postArticle");
  if (article == "") {
    article = """

    test
    this is test article.
    please give me some money!
    """;
  }
  print('post analysis');
  try {
    var response =
        await dio.post(Store.baseURL + "analysis", data: {"article": article});
    bus.emit('analysis_done', response.data);
    return response.data;
  } on DioError catch (e) {
    bus.emit('pop_show', e.response.data);
  }
}

// 根据标题查询文章内容
getArticleByID(int id) async {
  print('getArticleByTitle');
  var response = await dio.get(Store.baseURL + "article/" + id.toString());
  bus.emit('get_article_done', response.data);
  return response.data;
}

putUnlearnedCount(int articleID, int unlearnedCount) async {
  print('putLearnedCount id=' + articleID.toString());
  print('putLearnedCount unlearnedCount=' + unlearnedCount.toString());
  var response = await dio.put(Store.baseURL + "article/unlearned_count",
      data: {"article_id": articleID, "unlearned_count": unlearnedCount});
  bus.emit('put_unlearned_count_done', response.data);
  return response.data;
}
