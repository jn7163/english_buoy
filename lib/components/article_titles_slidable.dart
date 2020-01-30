import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/article_title.dart';
import '../models/article_titles.dart';
import './article_youtube_avatar.dart';

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

  @override
  initState() {
    super.initState();
    articleTitles = Provider.of<ArticleTitles>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    ArticleTitle articleTitle = widget.articleTitle;
    return Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Ink(
            color: articleTitles.selectedArticleID == articleTitle.id
                ? Theme.of(context).highlightColor
                : Colors.transparent,
            child: ListTile(
              trailing: ArticleYoutubeAvatar(
                  youtubeURL: articleTitle.youtube,
                  avatar: articleTitle.avatar,
                  loading: this.deleting ||
                      articleTitle
                          .loading), // data loading to create loading item when add new article
              dense: false,
              onTap: () {
                articleTitles.setSelectedArticleID(articleTitle.id);
                Navigator.pushNamed(context, '/Article',
                    arguments: articleTitle.id);
              },
              leading: Text(
                  articleTitle.percent.toStringAsFixed(
                          articleTitle.percent.truncateToDouble() ==
                                  articleTitle.percent
                              ? 0
                              : 1) +
                      "%",
                  style: TextStyle(
                    color: Colors.blueGrey,
                  )),
              title: Text(articleTitle.title), // 用的 TextTheme.subhead
            )),
        secondaryActions: [
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
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
