import 'package:flutter/material.dart';
import 'package:easy_alert/easy_alert.dart';
import './pages/articles.dart';
import './bus.dart';
import './models/oauth_info.dart';
import 'package:provide/provide.dart';

void main() {
  var oauthInfo = OauthInfo();
  var providers = Providers();

  providers.provide(Provider<OauthInfo>.value(oauthInfo));

  runApp(ProviderNode(
      child: AlertProvider(
        child: MyApp(),
        config: AlertConfig(
            ok: "OK text for `ok` button in AlertDialog",
            cancel: "CANCEL text for `cancel` button in AlertDialog"),
      ),
      providers: providers));
}

class MyApp extends StatelessWidget {
  void init(BuildContext context) {
    // 显示 pop 信息
    bus.on("pop_show", (arg) {
      Alert.toast(context, arg.toString(),
          position: ToastPosition.bottom, duration: ToastDuration.long);
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    init(context);
    return MaterialApp(
        title: 'English Buoy',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        // home: ArticlePage(title: 'Learn The Word'),
        home: ArticlesPage());
  }
}
