import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/article_title.dart';
import '../models/article_titles.dart';
import './article_youtube_avatar.dart';
import '../models/controller.dart';

class ArticleTitlesSlidable extends StatefulWidget {
  ArticleTitlesSlidable({
    Key key,
    @required this.articleTitle,
  }) : super(key: key);
  final ArticleTitle articleTitle;

  @override
  ArticleTitlesSlidableState createState() => ArticleTitlesSlidableState();
}

class ArticleTitlesSlidableState extends State<ArticleTitlesSlidable> {
  ArticleTitles articleTitles;
  bool deleting = false; // is deleting
  bool selected = false; // is selected
  Controller _controller;

  @override
  initState() {
    super.initState();
    articleTitles = Provider.of<ArticleTitles>(context, listen: false);
    _controller = Provider.of<Controller>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    //print("build $this");
    ArticleTitle articleTitle = widget.articleTitle;
    String percent = articleTitle.percent.toStringAsFixed(
        articleTitle.percent.truncateToDouble() == articleTitle.percent
            ? 0
            : 1);
    return Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Consumer<Controller>(
          builder: (context, controller, child) {
            return Ink(
                color: controller.selectedArticleID == articleTitle.id
                    ? Theme.of(context).highlightColor
                    : Colors.transparent,
                child: child);
          },
          child: ListTile(
            trailing: ArticleYoutubeAvatar(
                avatar: articleTitle.avatar,
                loading: this.deleting ||
                    articleTitle
                        .loading), // data loading to create loading item when add new article
            dense: false,
            onTap: () {
              setState(() {
                _controller.setSelectedArticleID(articleTitle.id);
              });
              _controller.setMainSelectedIndex(1);
              int i = articleTitles.findIndexByArticleID(articleTitle.id);
              print("findIndexByArticleID=$i");
              if (i == -1) {
                //use shared flow
                _controller.setMainSelectedIndex(0);
                articleTitles.newYouTube(articleTitle.youtube);
              }
              print("onTap open i=" + i.toString());
              _controller.setPageSelectedIndex(i);
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
              articleTitles.removeFromList(articleTitle);
              //更新本地缓存
              articleTitles.syncArticleTitles(justSetToLocal: true);
            },
          ),
        ]);
  }
}
