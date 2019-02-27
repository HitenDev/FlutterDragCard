import 'package:drag_card/crad_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MainCardWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainCardWidgetState();
  }
}

class _MainCardWidgetState extends State<MainCardWidget> {
  @override
  Widget build(BuildContext context) {
    return CardStackWidget();
  }
}

class CardStackWidget extends StatefulWidget {
  @override
  _CardStackWidgetState createState() => _CardStackWidgetState();
}

class _CardStackWidgetState extends State<CardStackWidget> {

  double _dx = 0;
  double _dy = 0;


  @override
  void initState() {

    super.initState();
  }

  _onDragUpdateListener(double dx, double dy) {
    print(dx.toString() + ':' + dy.toString());
    _dx = dx;
    _dy = dy;
    setState(() {

    });
  }



  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
        child: Container(
        color: Colors.blue,
        child: Stack(
          children: <Widget>[
            Transform(
              transform: Matrix4.translationValues(_dx, _dy, 0),
              child: CardWidget(index: 1),
            ),
            CardWidget(
              index: 0,
              onDragUpdateListener: _onDragUpdateListener,
            )
          ],
          alignment: Alignment.center,
        )));
  }
}
