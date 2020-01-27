import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/article_title.dart';
import '../models/article_titles.dart';
import './article_youtube_avatar.dart';

class ArticleTitlesInk extends StatelessWidget {
  const ArticleTitlesInk({Key key, @required this.articleTitle})
      : super(key: key);
  final ArticleTitle articleTitle;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Consumer<ArticleTitles>(builder: (context, articleTitles, child) {
      return Ink(
          color: articleTitles.selectedArticleID == articleTitle.id
              ? Theme.of(context).highlightColor
              : Colors.transparent,
          child: ListTile(
            trailing: ArticleYoutubeAvatar(
                youtubeURL: articleTitle.youtube,
                avatar: articleTitle.avatar,
                loading: articleTitle.deleting),
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
          ));
    });
  }
}
