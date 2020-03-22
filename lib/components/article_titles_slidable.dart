import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/article_title.dart';
import '../models/article_titles.dart';
import '../models/explorer.dart';
import './article_youtube_avatar.dart';
import '../models/controller.dart';

class ArticleTitlesSlidable extends StatefulWidget {
  ArticleTitlesSlidable({Key key, @required this.articleTitle, this.isExplorer = false}) : super(key: key);
  final ArticleTitle articleTitle;
  final isExplorer;

  @override
  ArticleTitlesSlidableState createState() => ArticleTitlesSlidableState();
}

class ArticleTitlesSlidableState extends State<ArticleTitlesSlidable> {
  bool deleting = false; // is deleting
  bool selected = false; // is selected

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ArticleTitle articleTitle = widget.articleTitle;
    String percent =
        articleTitle.percent.toStringAsFixed(articleTitle.percent.truncateToDouble() == articleTitle.percent ? 0 : 1);
    return Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Selector<Controller, int>(
          selector: (context, controller) => controller.selectedArticleID,
          builder: (context, selectedArticleID, child) {
            return Ink(
                color: selectedArticleID == articleTitle.id ? Theme.of(context).highlightColor : Colors.transparent,
                child: child);
          },
          child: ListTile(
            trailing: ArticleYoutubeAvatar(
                avatar: articleTitle.avatar,
                loading: this.deleting || articleTitle.loading), // data loading to create loading item when add new article
            dense: false,
            onTap: () {
              Controller _controller = Provider.of<Controller>(context, listen: false);
              ArticleTitles _articleTitles = Provider.of<ArticleTitles>(context, listen: false);
              //use shared flow
              if (widget.isExplorer) {
                _controller.jumpToHome(ArticleTitlesPageIndex);
                _articleTitles.newYouTube(articleTitle.youtube).then((sucess) {
                  if (sucess)
                    //remove from explorer list
                    Provider.of<Explorer>(context, listen: false).removeFromList(articleTitle);
                });
              }
              _controller.setSelectedArticleID(articleTitle.id);
              int i = _articleTitles.findIndexByArticleID(articleTitle.id);
              if (i == -1) {
                _controller.showSnackBar("can't find article:" + articleTitle.title + " in current article list! relaoding...");
                _articleTitles.getFromLocal();
                return;
              } else {
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
            },
            // percent in explorer is 0, no need show
            leading: percent == "0"
                ? null
                : Text(
                    percent + "%",
                  ),
            title: Text(articleTitle.title), // 用的 TextTheme.subhead
          ),
        ),
        secondaryActions: [
          IconSlideAction(
            caption: 'Delete',
            color: Theme.of(context).primaryColor,
            icon: Icons.delete,
            onTap: () async {
              setState(() {
                this.deleting = true;
              });
              await articleTitle.deleteArticle();
              // widget 会被上层复用,状态也会保留,loading状态得改回来
              this.deleting = false;
              ArticleTitles _articleTitles = Provider.of<ArticleTitles>(context, listen: false);
              _articleTitles.removeFromList(articleTitle);
              //更新本地缓存
              _articleTitles.syncArticleTitles(justSetToLocal: true);
            },
          ),
        ]);
  }
}
