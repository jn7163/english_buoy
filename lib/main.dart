import 'package:flutter/material.dart';

import 'package:easy_alert/easy_alert.dart';
import 'package:provider/provider.dart';
import './models/oauth_info.dart';
import './models/loading.dart';
import './models/article_titles.dart';
import './models/articles.dart';
import './models/setting.dart';
import './models/receive_share.dart';
import './models/article_status.dart';

import './pages/article_titles.dart';
import './pages/article.dart';
import './pages/sign.dart';
import './pages/add_article.dart';

import './themes/dark.dart';
import './themes/bright.dart';
import 'models/search.dart';

void main() {
  runApp(AlertProvider(
    child: MyApp(),
    config: new AlertConfig(ok: "OK", cancel: "CANCEL"),
  ));
  // runApp(MyApp());
}

class MyApp extends StatelessWidget {
  void init(BuildContext context) {
    var oauthInfo = Provider.of<OauthInfo>(context, listen: false);
    oauthInfo.backFromShared();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(builder: (_) => ArticleStatus()),
          ChangeNotifierProvider(builder: (_) => Loading()),
          ChangeNotifierProvider(builder: (_) => Search()),
          ChangeNotifierProvider(builder: (_) => OauthInfo()),
          ChangeNotifierProvider(builder: (_) => ArticleTitles()),
          ChangeNotifierProvider(builder: (_) => Articles()),
          ChangeNotifierProvider(builder: (_) => Setting()),
          ChangeNotifierProvider(builder: (_) => ReceiveShare()),
        ],
        child: Consumer<Setting>(builder: (context, setting, child) {
          init(context);
          return MaterialApp(
            title: 'English Buoy',
            theme: setting.isDark ? darkTheme : brightTheme,
            home: ArticleTitlesPage(),
            onGenerateRoute: _getRoute,
          );
        }));
  }

  Route _getRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/ArticleTitles':
        return _buildRoute(settings, ArticleTitlesPage());
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
