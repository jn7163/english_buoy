import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:easy_alert/easy_alert.dart';
import 'package:provider/provider.dart';
import './models/oauth_info.dart';
import './models/article.dart';
import './models/loading.dart';
import './models/article_titles.dart';
import './models/settings.dart';
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
  OauthInfo oauthInfo;

  @override
  void initState() {
    super.initState();
    youtube = YouTube();
    oauthInfo = OauthInfo();
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
      print("shared to run app");
      receiveShare(value);
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      print("shared to closed app");
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
    oauthInfo.backFromShared();
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Article()),
          ChangeNotifierProvider(create: (_) => youtube),
          ChangeNotifierProvider(create: (_) => Loading()),
          ChangeNotifierProvider(create: (_) => oauthInfo),
          ChangeNotifierProvider(create: (_) => ArticleTitles()),
          ChangeNotifierProvider(create: (_) => Settings()),
        ],
        child: Consumer<Settings>(builder: (context, settings, child) {
          return MaterialApp(
            title: 'English Buoy',
            theme: settings.isDark ? darkTheme : brightTheme,
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
