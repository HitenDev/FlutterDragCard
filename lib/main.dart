import 'dart:convert';

import 'package:drag_card/colors.dart';
import 'package:drag_card/entity.dart';
import 'package:drag_card/eventbus.dart';
import 'package:drag_card/main_card_widget.dart';
import 'package:drag_card/pull_drag_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Darg Card Sample',
      theme: ThemeData(
        backgroundColor: background,
      ),
      home: HomePager(),
    );
  }
}

class HomePager extends StatefulWidget {
  @override
  _HomePagerState createState() => _HomePagerState();
}

class _HomePagerState extends State<HomePager> {
  List<CardEntity> _cardList;

  List<ToolBarEntity> _toolbarList;

  initState() {
    super.initState();
    _loadJson();
  }

  Future<String> _loadAsset() async {
    return await rootBundle.loadString('assets/mock/jk_daily_cards.json');
  }

  void _loadJson() {
    _loadAsset().then((json) {
      JsonDecoder jsonDecoder = new JsonDecoder();
      Map root = jsonDecoder.convert(json);
      Map data = root["data"];
      List cards = data["cards"];
      if (cards == null) {
        return;
      }
      List<CardEntity> cardEntities = List();
      for (Map item in cards) {
        Map originalPost = item["originalPost"];
        if (originalPost != null) {
          String content = originalPost["content"];
          String picUrl;
          List pictures = originalPost["pictures"];
          if (pictures != null && pictures.length > 0) {
            Map pic = pictures[0];
            if (pic != null) {
              picUrl = pic["middlePicUrl"];
            }
          }
          if (content != null && picUrl != null) {
            cardEntities.add(CardEntity(picUrl, content));
          }
        }
      }

      List toolbarList = data["toolbarItems"];
      if (toolbarList == null) {
        return;
      }
      List<ToolBarEntity> toolbarEntities = List();
      for (Map item in toolbarList) {
        String url = item["url"];
        String picUrl = item["picUrl"];
        String title = item["title"];
        if (title != null && picUrl != null) {
          toolbarEntities.add(ToolBarEntity(picUrl, title, url));
        }
      }

      setState(() {
        _cardList = cardEntities;
        _toolbarList = toolbarEntities;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: PullDragWidget(
          dragHeight: 120,
          header: _createHeader(),
          child: _createContent(),
        ));
  }

  _onHeaderItemClick(ToolBarEntity item) {
    print(item.title);
  }

  Widget _createHeader() {
    Widget header;
    if (_toolbarList == null || _toolbarList.length == 0) {
      header = Text("Loading...");
    } else {
      header = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _toolbarList.map<Widget>((item) {
            return Expanded(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _onHeaderItemClick(item);
                  },
                  child: ClipOval(
                    child: Image.network(
                      item.picUrl,
                      width: 66,
                      height: 66,
                    ),
                  ),
                ),
                Container(
                  height: 6,
                ),
                Text(
                  item.title,
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0xff333333),
                      decoration: TextDecoration.none),
                )
              ],
            ));
          }).toList());
    }

    return header;
  }

  Widget _createContent() {
    if (_cardList == null || _cardList.length == 0) {
      return Container(
        child: Text(
          "Loading...",
          style: TextStyle(decoration: TextDecoration.none),
        ),
        alignment: Alignment.center,
      );
    } else {
      return Stack(
        children: <Widget>[
          Positioned(
              bottom: 0,
              height: 100,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(left: 20, right: 20),
                height: 100,
                child: _createOptMenus(),
              )),
          CardStackWidget(cardList: _cardList)
        ],
      );
    }
  }

  Widget _createOptMenus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _createMenu("assets/drawable/ic_discover_next_card_back.png",
            () => bus.emit("openCard", true)),
        _createMenu("assets/drawable/ic_discover_more.png",
            () => bus.emit("openCard", true)),
        _createMenu("assets/drawable/ic_discover_next_card_right.png",
            () => bus.emit("openCard", true)),
      ],
    );
  }

  Widget _createMenu(String picUrl, GestureTapCallback onTap) {
    return Expanded(
        child: GestureDetector(
            onTap: onTap,
            child: Image.asset(
              picUrl,
              width: 48,
              height: 48,
            )));
  }
}
