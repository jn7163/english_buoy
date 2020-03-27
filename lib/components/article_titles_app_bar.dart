import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:flutter/material.dart';

import 'oauth_info.dart';
import '../models/article_titles.dart';
import 'package:decoding_text_effect/decoding_text_effect.dart';

// 顶部那个浮动的 appbar
class ArticleListsAppBarState extends State<ArticleListsAppBar> {
  bool _isSearching = false;
  TextEditingController searchController = TextEditingController();
  int _searchCount = 0;

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
      backgroundColor: Colors.black,
      leading: GestureDetector(onTap: () => widget.scaffoldKey.currentState.openDrawer(), child: OauthInfoWidget()),
      automaticallyImplyLeading: false,
      title: _isSearching
          ? TextField(
              // 自动对焦
              autofocus: true,
              // 不要有下划线
              decoration: null,
              cursorColor: Theme.of(context).primaryTextTheme.headline6.color,
              controller: searchController,
              style: Theme.of(context).primaryTextTheme.headline6,
            )
          : GestureDetector(
              onTap: () {
                setState(() {
                  _searchCount++;
                  _isSearching = true;
                });
              },
              child: DecodingTextEffect(
                _searchCount > 4 && _searchCount % 2 == 0 ? "BigZhu Very Big" : "English Buoy",
                decodeEffect: DecodeEffect.fromStart,
              )),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            _isSearching ? Icons.close : Icons.search,
          ),
          tooltip: 'go to articles',
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                searchController.text = "";
                articleTitles.setSearchKey(searchController.text);
              } else
                _searchCount++;
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.sort),
          onPressed: () => articleTitles.changeSort(),
        ),
        IconButton(
          icon: Icon(Icons.settings),
          tooltip: 'go to settings',
          onPressed: () => widget.scaffoldKey.currentState.openEndDrawer(),
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
