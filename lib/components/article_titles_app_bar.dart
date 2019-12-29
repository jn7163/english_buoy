// import 'package:ebuoy/models/search.dart';
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
    Future.delayed(Duration.zero, () {
      // search = Provider.of<Search>(context, listen: false);
      articleTitles = Provider.of<ArticleTitles>(context, listen: false);
    });
    searchController.addListener(() {
      articleTitles.setSearchKey(searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: OauthInfoWidget(),
      automaticallyImplyLeading: false,
      title: isSearching
          ? TextField(
              autofocus: true,
              // 自动对焦
              decoration: null,
              // 不要有下划线
              cursorColor: Colors.white,
              controller: searchController,
              style: Theme.of(context).primaryTextTheme.title,
            )
          : Text(
              "English Buoy",
            ),
      actions: <Widget>[
        IconButton(
          icon: Icon(isSearching ? Icons.close : Icons.search,
              color: Theme.of(context).primaryTextTheme.title.color),
          tooltip: 'go to articles',
          onPressed: () {
            setState(() {
              isSearching = !isSearching;
              if (!isSearching) {
                searchController.text = "";
                articleTitles.setSearchKey(searchController.text);
                //search.set(searchController.text);
              }
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.sort, color: Theme.of(context).primaryTextTheme.title.color),
          onPressed: () {
            ArticleTitles articleTitles = Provider.of<ArticleTitles>(context, listen: false);
            articleTitles.changeSort();
          },
        ),
        IconButton(
          icon: Icon(Icons.settings, color: Theme.of(context).primaryTextTheme.title.color),
          tooltip: 'go to settings',
          onPressed: () {
            Navigator.pushNamed(context, '/Sign');
          },
        ),
      ],
    );
  }
}

class ArticleListsAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  ArticleListsAppBarState createState() => ArticleListsAppBarState();

  @override
  Size get preferredSize => new Size.fromHeight(kToolbarHeight);
}
