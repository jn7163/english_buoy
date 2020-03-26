import './store.dart';

// add new youtube to server
Future newYouTube(String youtube) async {
  return await dio()
      .post(Store.baseURL + "Subtitle", data: {"Youtube": youtube});
}
