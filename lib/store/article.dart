import 'package:dio/dio.dart';
import '../bus.dart';
import './store.dart';
import './articles.dart';

Dio dio = getDio();
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
  try {
    var response =
        await dio.post(Store.baseURL + "analysis", data: {"article": article});
    bus.emit('analysis_done', response.data);
    return response.data;
  } on DioError catch (e) {
    // 如果是已经存在, 那么应该会把 article id 传过来
    bus.emit('pop_show', e.response.data);
    if (e.response.data['error'] == "already exists") {
      return e.response.data;
    }
  }
}

// 根据标题查询文章内容
getArticleByID(int id) async {
  print('getArticleByID: ' + id.toString());
  var response = await dio.get(Store.baseURL + "article/" + id.toString());
  // bus.emit('get_article_done', response.data);
  return response.data;
}

putUnlearnedCount(int articleID, int unlearnedCount) async {
  if (articleID == 0) {
    return null;
  }
  print('putLearnedCount id=' + articleID.toString());
  print('putLearnedCount unlearnedCount=' + unlearnedCount.toString());
  var response = await dio.put(Store.baseURL + "article/unlearned_count",
      data: {"article_id": articleID, "unlearned_count": unlearnedCount});
  // 设置了掌握数以后, 列表也要重新获取的
  getArticleTitles();
  bus.emit('put_unlearned_count_done', response.data);
  return response.data;
}
