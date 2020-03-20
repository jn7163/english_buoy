import 'dart:async';

import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:easy_alert/easy_alert.dart';
import 'package:provider/provider.dart';

import './models/oauth_info.dart';
import './models/article.dart';
import './models/loading.dart';
import './models/article_titles.dart';
import './models/settings.dart';
import './models/controller.dart';
import './models/global.dart';
import './models/explorer.dart';

import './pages/home.dart';

import './themes/dark.dart';
import './themes/bright.dart';

import './store/wordwise.dart';
import './store/store.dart';

void main() {
  runApp(AlertProvider(
    child: Ebuoy(),
    config: AlertConfig(),
  ));
  // runApp(MyApp());
}

class Ebuoy extends StatefulWidget {
  @override
  _EbuoyState createState() => _EbuoyState();
}

class _EbuoyState extends State<Ebuoy> {
  StreamSubscription _intentDataStreamSubscription;
  Controller _controller;
  ArticleTitles _articleTitles;
  Settings _settings;
  OauthInfo _oauthInfo;
  @override
  void initState() {
    super.initState();
    Store.prefs;
    openDB();
    _controller = Controller();
    _oauthInfo = OauthInfo();
    _articleTitles = ArticleTitles();
    _settings = Settings();
    //bind
    _oauthInfo.controller = _controller;
    _articleTitles.controller = _controller;
    _articleTitles.settings = _settings;
    initReceiveShare();
  }

  receiveShare(String sharedText) {
    if (sharedText == null) return;
    _controller.setMainSelectedIndex(0);
    _articleTitles.newYouTube(sharedText);
  }

  void initReceiveShare() {
    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      print("shared to run app value=$value");
      receiveShare(value);
    }, onError: (e) {
      print("getLinkStream error: $e");
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
          ChangeNotifierProvider(create: (_) => Explorer()),
          Provider<Global>(create: (_) => Global()),
          ChangeNotifierProvider.value(value: _controller),
          ChangeNotifierProvider(create: (_) => Article()),
          ChangeNotifierProvider(create: (_) => Loading()),
          ChangeNotifierProvider.value(value: _oauthInfo),
          ChangeNotifierProvider.value(value: _articleTitles),
          ChangeNotifierProvider.value(value: _settings),
        ],
        child: Selector<Settings, bool>(
            selector: (context, settings) => settings.isDark,
            builder: (context, isDark, child) {
              return MaterialApp(
                title: 'English Buoy',
                theme: brightTheme,
                darkTheme: darkTheme,
                themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                home: HomePage(),
              );
            }));
  }
}
