import 'package:flutter/material.dart';
import 'package:easy_alert/easy_alert.dart';
import './bus.dart';
import './models/oauth_info.dart';
import './models/article_titles.dart';
import './models/article.dart';
import './models/articles.dart';
import 'package:provide/provide.dart';

import './pages/articles.dart';
import './pages/article.dart';
import './pages/sign.dart';
import './pages/add_article.dart';

void main() {
  // 登录信息
  var oauthInfo = OauthInfo();
  // 文章列表
  var articleTitles = ArticleTitles();
  var article = Article();
  var articles = Articles();
  var providers = Providers();

  providers
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
    init(context);
    return MaterialApp(
      /*
      showPerformanceOverlay: true,
      checkerboardOffscreenLayers: true, // 使用了saveLayer的图形会显示为棋盘格式并随着页面刷新而闪烁
      checkerboardRasterCacheImages:
          true, // 做了缓存的静态图片在刷新页面时不会改变棋盘格的颜色；如果棋盘格颜色变了说明被重新缓存了，这是我们要避免的
          */

      title: 'English Buoy',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: ArticlesPage(),
      onGenerateRoute: _getRoute,
      //initialRoute: '/ArticlesPage',
      //routes: {
      //  '/': (context) => ArticlesPage(),
      //  '/Articles': (context) => ArticlesPage(),
      //  '/AddArticle': (context) => AddArticlePage(),
      //  '/Article': (context) => ArticlePage(),
      //  '/Sign': (context) => SignInPage(),
      //},
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
