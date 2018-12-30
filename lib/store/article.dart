import 'package:dio/dio.dart';
import '../bus.dart';
import './store.dart';

postArticle(String title, String article) async {
  if (article == "") {
    article = """
Photo by Matthieu Paley @paleyphoto | Pure Joy! Wuluk Bu can’t help but kiss this young calf, just a few days old. For survival at high altitude in the Pamir Mountains, the Afghan Kyrgyz community depends on their herds of yaks, horses, sheep, goats, and camels. On this plateau at about 14,000 feet (4,100 meters), only grass can grow during the brief summer. Here the animals are used for transportation, some for milk and meat, others for wool, which will be turned into felt to make carpets or to build yurts, the quintessential home of the nomadic world. Nothing goes to waste. For more interesting cultural encounters, please visit @paleyphoto. Shot on assignment for @natgeo on a story about the Evolution of Diet. #nomadicdiet #pamirmountains #organic #calf #yak #evolutionofdiet #centralasia
    """;
  }
  Dio dio = new Dio();
  print('post analysis');
  var response = await dio.post(Store.baseURL + "api/analysis",
      data: {"title": title, "article": article});
  bus.emit('analysis_done', response.data);
  return response.data;
}
