import 'package:ebuoy/models/search.dart';
import 'package:flutter/cupertino.dart';

import 'package:provide/provide.dart';
import 'package:flutter/material.dart';

import 'oauth_info.dart';

// 顶部那个浮动的 appbar
class ArticleListsAppBarState extends State<ArticleListsAppBar> {
  bool isSearching;
  TextEditingController searchController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    isSearching = false;
    searchController.addListener(() {
      if (!isSearching) {
        searchController.text = "";
      }
      var search = Provide.value<Search>(context);
      search.set(searchController.text);
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
            });
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
