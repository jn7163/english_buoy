import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

import 'oauth_info.dart';
import '../models/article_titles.dart';

// 顶部那个浮动的 appbar
class ArticleListsAppBarState extends State<ArticleListsAppBar> {
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  //Search search;
  ArticleTitles articleTitles;

  @override
  void initState() {
    super.initState();
    articleTitles = Provider.of<ArticleTitles>(context, listen: false);
    searchController.addListener(() {
      articleTitles.setSearchKey(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).primaryColorDark,
      leading: GestureDetector(
          onTap: () {
            widget.scaffoldKey.currentState.openDrawer();
          },
          child: OauthInfoWidget()),
      automaticallyImplyLeading: false,
      title: isSearching
          ? TextField(
              // 自动对焦
              autofocus: true,
              // 不要有下划线
              decoration: null,
              cursorColor: Theme.of(context).primaryTextTheme.headline6.color,
              controller: searchController,
              style: Theme.of(context).primaryTextTheme.headline6,
            )
          : Text(
              "English Buoy",
            ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            isSearching ? Icons.close : Icons.search,
          ),
          tooltip: 'go to articles',
          onPressed: () {
            setState(() {
              isSearching = !isSearching;
              if (!isSearching) {
                searchController.text = "";
                articleTitles.setSearchKey(searchController.text);
              }
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.sort),
          onPressed: () {
            articleTitles.changeSort();
          },
        ),
        IconButton(
          icon: Icon(Icons.settings),
          tooltip: 'go to settings',
          onPressed: () {
            widget.scaffoldKey.currentState.openEndDrawer();
          },
        ),
      ],
    );
  }
}

class ArticleListsAppBar extends StatefulWidget implements PreferredSizeWidget {
  ArticleListsAppBar({Key key, this.scaffoldKey}) : super(key: key);

  @override
  ArticleListsAppBarState createState() => ArticleListsAppBarState();

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);

  final GlobalKey<ScaffoldState> scaffoldKey;
}
