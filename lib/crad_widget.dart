import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CardWidget extends StatefulWidget {
  final int index;

  const CardWidget({Key key, this.index}) : super(key: key);

  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: widget.index * 10.toDouble()),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child:  Image.network(widget.index == 1
              ? "http://img.bimg.126.net/photo/V6nNeq8YN2xPBRxTz8w4VA==/5776429472056759812.jpg"
              : "http://pic1.nipic.com/2008-12-30/200812308231244_2.jpg"))
    );
  }
}
