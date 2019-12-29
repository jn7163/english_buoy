import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:easy_alert/easy_alert.dart';
import 'package:provider/provider.dart';
import './models/oauth_info.dart';
import './models/loading.dart';
import './models/article_titles.dart';
import './models/articles.dart';
import './models/setting.dart';
import './models/article_status.dart';
import './models/youtube.dart';

import './pages/waiting.dart';
import './pages/article_titles.dart';
import './pages/article.dart';
import './pages/sign.dart';
import './pages/add_article.dart';
import './pages/guid.dart';

import './themes/dark.dart';
import './themes/bright.dart';
import 'dart:async';

void main() {
  runApp(AlertProvider(
    child: MyApp(),
    config: new AlertConfig(ok: "OK", cancel: "CANCEL"),
  ));
  // runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription _intentDataStreamSubscription;
  YouTube youtube;

  @override
  void initState() {
    super.initState();
    youtube = YouTube();
    initReceiveShare();
  }

  void receiveShare(String sharedText) {
    if (sharedText == null) return;
    // 收到分享, 设置
    youtube.set(sharedText);
  }

  void initReceiveShare() {
    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getTextStream().listen((String value) {
      receiveShare(value);
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      receiveShare(value);
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => youtube),
          ChangeNotifierProvider(create: (_) => ArticleStatus()),
          ChangeNotifierProvider(create: (_) => Loading()),
          ChangeNotifierProvider(create: (_) => OauthInfo()),
          ChangeNotifierProvider(create: (_) => ArticleTitles()),
          ChangeNotifierProvider(create: (_) => Articles()),
          ChangeNotifierProvider(create: (_) => Setting()),
        ],
        child: Consumer<Setting>(builder: (context, setting, child) {
          var oauthInfo = Provider.of<OauthInfo>(context, listen: false);
          oauthInfo.backFromShared();
          return MaterialApp(
            title: 'English Buoy',
            theme: setting.isDark ? darkTheme : brightTheme,
            home: ArticleTitlesPage(),
            onGenerateRoute: getRoute,
          );
        }));
  }

  Route getRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/Guid':
        return _buildRoute(settings, GuidPage());
      case '/Waiting':
        return _buildRoute(settings, WaitingPage());
      case '/ArticleTitles':
        return _buildRoute(settings, ArticleTitlesPage());
      case '/AddArticle':
        return _buildRoute(settings, AddArticlePage());
      case '/Article':
        return _buildRoute(settings, ArticlePage(initID: settings.arguments));
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
/*
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
          ChangeNotifierProvider(create: (_) => ArticleStatus()),
          ChangeNotifierProvider(create: (_) => Loading()),
          ChangeNotifierProvider(create: (_) => Search()),
          ChangeNotifierProvider(create: (_) => OauthInfo()),
          ChangeNotifierProvider(create: (_) => ArticleTitles()),
          ChangeNotifierProvider(create: (_) => Articles()),
          ChangeNotifierProvider(create: (_) => Setting()),
        ],
        child: Consumer<Setting>(builder: (context, setting, child) {
          init(context);
          return MaterialApp(
            title: 'English Buoy',
            theme: setting.isDark ? darkTheme : brightTheme,
            home: WaitingPage(),
            //home: GuidPage(),
            onGenerateRoute: _getRoute,
          );
        }));
  }

  Route _getRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/Guid':
        return _buildRoute(settings, GuidPage());
      case '/Waiting':
        return _buildRoute(settings, WaitingPage());
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
 */
