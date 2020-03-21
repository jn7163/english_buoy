import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article_titles.dart';
import './article.dart';
import '../models/controller.dart';
import '../models/article_title.dart';

class ArticlePageViewPage extends StatefulWidget {
  @override
  _ArticlePageViewPage createState() => _ArticlePageViewPage();
}

class _ArticlePageViewPage extends State<ArticlePageViewPage> {
  //with AutomaticKeepAliveClientMixin {
  //@override
  //bool get wantKeepAlive => false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //super.build(context);
    return WillPopScope(
      onWillPop: () async {
        Controller _controller = Provider.of<Controller>(context, listen: false);
        if (_controller.homeIndex != ArticleTitlesPageIndex) {
          _controller.jumpToHome(ArticleTitlesPageIndex);
          return false;
        } else
          return true;
      },
      child: Selector<ArticleTitles, List<ArticleTitle>>(
          selector: (context, articleTitles) => articleTitles.filterTitles,
          builder: (context, filterTitles, child) {
            print("Selector $this init _controller.articlePageViewController!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
            Controller _controller = Provider.of<Controller>(context, listen: false);
            _controller.articlePageViewController = PageController(initialPage: _controller.articleIndex);
            return PageView(
                reverse: true,
                onPageChanged: (i) => _controller.setSelectedArticleID(filterTitles[i].id), // used to highlight aritcleTitlePage item
                controller: _controller.articlePageViewController,
                children: filterTitles.map((d) => ArticlePage(d.id)).toList());
          }),
    );
  }
}
