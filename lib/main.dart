import 'package:flutter/material.dart';
import 'package:easy_alert/easy_alert.dart';
import './bus.dart';
import './models/oauth_info.dart';
import './models/all_loading.dart';
import './models/article_titles.dart';
import './models/article.dart';
import './models/articles.dart';
import './models/setting.dart';
import './models/receive_share.dart';
import 'package:provide/provide.dart';

import './pages/article_titles.dart';
import './pages/article.dart';
import './pages/sign.dart';
import './pages/add_article.dart';

void main() {
  var allLoading = AllLoading();
  // 登录信息
  var oauthInfo = OauthInfo();
  // 文章列表
  var articleTitles = ArticleTitles();
  var article = Article();
  var articles = Articles();
  var providers = Providers();
  var setting = Setting();
  var receiveShare = ReceiveShare();

  providers
    ..provide(Provider<ReceiveShare>.value(receiveShare))
    ..provide(Provider<Setting>.value(setting))
    ..provide(Provider<AllLoading>.value(allLoading))
    ..provide(Provider<OauthInfo>.value(oauthInfo))
    ..provide(Provider<ArticleTitles>.value(articleTitles))
    ..provide(Provider<Articles>.value(articles))
    ..provide(Provider<Article>.value(article));

  runApp(ProviderNode(
      child: AlertProvider(
        child: MyApp(),
        config: AlertConfig(
            ok: "OK text for `ok` button in AlertDialog",
            cancel: "CANCEL text for `cancel` button in AlertDialog"),
      ),
      providers: providers));
  //runApp(MyApp());
}

class MyApp extends StatelessWidget {
  void init(BuildContext context) {
    // 显示 pop 信息
    bus.on("pop_show", (arg) {
      Alert.toast(context, arg.toString(),
          position: ToastPosition.bottom, duration: ToastDuration.long);
    });
    var oauthInfo = Provide.value<OauthInfo>(context);

    oauthInfo.backFromShared();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // MaterialColor colorCustom = MaterialColor(0x1E1E1E, color);
    MaterialColor colorCustom = MaterialColor(0xFF282828, color);
    init(context);
    return MaterialApp(
      title: 'English Buoy',
      theme: ThemeData(
        primarySwatch: colorCustom,
      ),
      home: ArticlesPage(),
      onGenerateRoute: _getRoute,
    );
  }

  Route _getRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/Articles':
        return _buildRoute(settings, ArticlesPage());
      case '/AddArticle':
        return _buildRoute(settings, AddArticlePage());
      case '/Article':
        return _buildRoute(settings, ArticlePage(id: settings.arguments));
      case '/Sign':
        return _buildRoute(settings, SignInPage());
      default:
        return null;
    }
  }

  MaterialPageRoute _buildRoute(RouteSettings settings, Widget builder) {
    return new MaterialPageRoute(
      settings: settings,
      builder: (BuildContext context) => builder,
    );
  }
}

Map<int, Color> color = {
  50: Color.fromRGBO(40, 40, 40, .1),
  100: Color.fromRGBO(40, 40, 40, .2),
  200: Color.fromRGBO(40, 40, 40, .3),
  300: Color.fromRGBO(40, 40, 40, .4),
  400: Color.fromRGBO(40, 40, 40, .5),
  500: Color.fromRGBO(40, 40, 40, .6),
  600: Color.fromRGBO(40, 40, 40, .7),
  700: Color.fromRGBO(40, 40, 40, .8),
  800: Color.fromRGBO(40, 40, 40, .9),
  900: Color.fromRGBO(40, 40, 40, 1),
};
