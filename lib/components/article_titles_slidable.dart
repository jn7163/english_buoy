import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/article_title.dart';
import '../models/article_titles.dart';
import './article_youtube_avatar.dart';
import '../models/controller.dart';
import './increase_percent_number.dart';
import './youtube_thumbnail.dart';

class ArticleTitlesSlidable extends StatefulWidget {
  ArticleTitlesSlidable({Key key, @required this.articleTitle, this.isExplorer = false}) : super(key: key);
  final ArticleTitle articleTitle;
  final isExplorer;

  @override
  ArticleTitlesSlidableState createState() => ArticleTitlesSlidableState();
}

class ArticleTitlesSlidableState extends State<ArticleTitlesSlidable> {
  bool deleting = false; // is deleting
  ArticleTitle _articleTitle;
  Widget _child;
  @override
  initState() {
    super.initState();
    _articleTitle = widget.articleTitle;
  }

  Widget getCardItem(ArticleTitle articleTitle) {
    return GestureDetector(
      onTap: () => this.enter(articleTitle),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: <Widget>[
          YouTubeThumbnail(
            thumbnailURL: articleTitle.thumbnailURL,
            height: MediaQuery.of(context).size.width * 9 / 16,
            width: MediaQuery.of(context).size.width,
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
            //padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                getListItem(articleTitle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  enter(ArticleTitle articleTitle) {
    Controller _controller = Provider.of<Controller>(context, listen: false);
    ArticleTitles _articleTitles = Provider.of<ArticleTitles>(context, listen: false);
    //use shared flow
    if (widget.isExplorer) {
      _controller.jumpToHome(ArticleTitlesPageIndex);
      _articleTitles.newYouTube(articleTitle.youtube);
      return;
    }
    _controller.setSelectedArticleID(articleTitle.id);
    int i = _articleTitles.findIndexByArticleID(articleTitle.id);
    if (i == -1) {
      _controller.showSnackBar("can't find article:" + articleTitle.title + " in current article list! relaoding...");
      _articleTitles.getFromLocal();
      return;
    }
    // first open article page view
    if (_controller.articlePageViewController == null) {
      _controller.articleIndex = i;
      _controller.jumpToHome(ArticlePageViewPageIndex);
      // no need run jumpToArticle when first open
    } else {
      _controller.jumpToHome(ArticlePageViewPageIndex);
      _controller.jumpToArticle(i);
    }
  }

  Widget getListItem(ArticleTitle articleTitle, {Color textColor = Colors.white}) {
    return ListTile(
      trailing: ArticleYoutubeAvatar(
        avatar: articleTitle.avatar,
        loading: this.deleting || articleTitle.loading,
      ), // data loading to create loading item when add new article
      dense: false,
      onTap: () => this.enter(articleTitle),
      leading: articleTitle.percent != 0 ? IncreasePercentNumber(number: articleTitle.percent) : null,
      //leading: Text(articleTitle.percent.toString(), style: TextStyle(color: textColor)),
      title: Selector<Controller, int>(
        selector: (context, controller) => controller.selectedArticleID,
        builder: (context, selectedArticleID, child) {
          return Text(articleTitle.title,
              style: TextStyle(
                color: textColor,
                fontWeight: selectedArticleID == articleTitle.id ? FontWeight.bold : null,
                //fontWeight: controller.selectedArticleID == articleTitle.id ? FontWeight.bold : null)), // 用的 TextTheme.subhead
              ));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _child = _articleTitle.thumbnailURL == null || _articleTitle.thumbnailURL == ""
        ? getListItem(_articleTitle)
        : getCardItem(_articleTitle);

    return Slidable(actionPane: SlidableDrawerActionPane(), actionExtentRatio: 0.25, child: _child, secondaryActions: [
      IconSlideAction(
        caption: 'Delete',
        color: Theme.of(context).primaryColor,
        icon: Icons.delete,
        onTap: () async {
          setState(() {
            this.deleting = true;
          });
          await _articleTitle.deleteArticle();
          ArticleTitles _articleTitles = Provider.of<ArticleTitles>(context, listen: false);
          _articleTitles.removeFromList(_articleTitle);
          //更新本地缓存
          _articleTitles.syncArticleTitles(justSetToLocal: true);
        },
      ),
    ]);
  }
}
