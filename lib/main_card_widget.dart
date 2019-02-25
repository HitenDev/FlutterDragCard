
import 'package:drag_card/crad_widget.dart';
import 'package:flutter/widgets.dart';

class MainCardWidget extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _MainCardWidgetState();
  }

}

class _MainCardWidgetState extends State<MainCardWidget>{
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
  @override
  Widget build(BuildContext context) {
    return Stack(
        children: <Widget>[CardWidget(index: 1),CardWidget(index: 0)],
        alignment: Alignment(0,0)
      ,
    );
  }
}
