// 文章列表
import 'dart:async';

import 'package:ebuoy/components/article_titles_app_bar.dart';

import '../models/loading.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article_titles.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class WaitingPage extends StatefulWidget {
  WaitingPage({Key key}) : super(key: key);

  @override
  WaitingPageState createState() => WaitingPageState();
}

class WaitingPageState extends State<WaitingPage> {
  StreamSubscription _receiveShareLiveSubscription;
  ArticleTitles articleTitles;
  String youtubeURL;

  @override
  initState() {
    super.initState();
    //注册分享监听
    initReceiveShare();
    youtubeURL = null; //avoid repeating synchronization
    Future.delayed(Duration.zero, () {
      articleTitles = Provider.of<ArticleTitles>(context, listen: false);
      syncArticleTitles()
          .then((d) => Navigator.pushNamed(context, '/ArticleTitles', arguments: null));
      /*
      // if don't have data, get from server
      if (articleTitles.titles.length == 0) {
        syncArticleTitles()
            .then((d) => Navigator.pushNamed(context, '/ArticleTitles', arguments: youtubeURL));
      } else {
        Navigator.pushNamed(context, '/ArticleTitles', arguments: youtubeURL);
      }
       */
    });
  }

  @override
  void dispose() {
    _receiveShareLiveSubscription.cancel();
    super.dispose();
  }

  void initReceiveShare() {
    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _receiveShareLiveSubscription = ReceiveSharingIntent.getTextStream().listen((String value) {
      receiveShare(value);
      debugPrint("share from app in memory text=" + value);
    }, onError: (err) {
      print("getLinkStream error: $err");
    });
    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      receiveShare(value);
    });
  }

  void receiveShare(String sharedText) {
    if (sharedText == null) return;
    // 收到分享, 先跳转到 list 页面
    youtubeURL = sharedText;
    Navigator.pushNamed(context, '/ArticleTitles', arguments: youtubeURL);
  }

  Future syncArticleTitles() async {
    return articleTitles.syncServer(context).then((d) {}).catchError((e) {
      if (e.response.statusCode == 401) {
        print("must login");
        Navigator.pushNamed(context, '/Sign');
      }
    });
  }

  Widget getDescription() {
    return Center(
        child: Container(
            margin: EdgeInsets.only(top: 5.0, left: 5.0, bottom: 5, right: 5),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image.asset(
                'assets/images/logo.png',
                width: 96.0,
                height: 96.0,
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      style: Theme.of(context).textTheme.body1,
                      text: "You can share YouTube ",
                    ),
                    WidgetSpan(
                      child: Icon(
                        FontAwesomeIcons.youtube,
                        color: Colors.red,
                      ),
                    ),
                    TextSpan(
                      style: Theme.of(context).textTheme.body1,
                      text: "  video to here",
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
              ),
              /*
              RichText(
                  text: TextSpan(
                      style: Theme.of(context).textTheme.body1,
                      text: "Or click Add button to add English article"))
               */
            ])));
  }

  @override
  Widget build(BuildContext context) {
    print("build description titles");
    Scaffold scaffold = Scaffold(
      appBar: ArticleListsAppBar(),
      body: Consumer<Loading>(builder: (context, allLoading, _) {
        return ModalProgressHUD(child: getDescription(), inAsyncCall: allLoading.loading);
      }),
    );
    return scaffold;
  }
}
