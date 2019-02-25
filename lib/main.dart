import 'package:drag_card/colors.dart';
import 'package:drag_card/main_card_widget.dart';
import 'package:flutter/material.dart';

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
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: MainCardWidget()
    );
  }

}

