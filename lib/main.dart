import 'package:drag_card/colors.dart';
import 'package:drag_card/main_card_widget.dart';
import 'package:drag_card/orntdrag.dart';
import 'package:drag_card/pull_drag_widget.dart';
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
      home: PullDragWidget(
        maxHeight: 160,
        headerWidget: Container(
          color: Colors.white,
          child: Text("Header"),
        ),
        child: Container(
          color: Colors.red,
          alignment: Alignment.center,
          child: MainCardWidget(),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: null, body: MainCardWidget());
  }
}

class TouchParent extends StatelessWidget {
  Map<Type, GestureRecognizerFactory> gestures() {
    Map<Type, GestureRecognizerFactory> map = Map();
    map[OrientationGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<OrientationGestureRecognizer>(
            () => OrientationGestureRecognizer(
                OrientationGestureRecognizer.left |
                    OrientationGestureRecognizer.right,null),
            (OrientationGestureRecognizer instance) {
      instance.onStart = (details) {
        print("TouchParent onStart");
      };
      instance.onUpdate = (details) {
        print("TouchParent onUpdate" + details.delta.toString());
      };
      instance.onDown = (details) {
        print("TouchParent onDown");
      };

      instance.onCancel = () {
        print("TouchParent onCancel");
      };

      instance.onEnd = (details) {
        print("TouchParent onEnd");
      };
    });
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: gestures(),
      child: Container(
        color: Colors.blue,
        alignment: Alignment.center,
        child: TouchChild(),
      ),
    );
  }
}

class TouchChild extends StatelessWidget {
  Map<Type, GestureRecognizerFactory> gestures() {
    Map<Type, GestureRecognizerFactory> map = Map();
    map[OrientationGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<OrientationGestureRecognizer>(
            () => OrientationGestureRecognizer(
                OrientationGestureRecognizer.up |
                    OrientationGestureRecognizer.down,null),
            (OrientationGestureRecognizer instance) {
      instance.onStart = (details) {
        print("TouchChild onStart");
      };
      instance.onUpdate = (details) {
        print("TouchChild onUpdate" + details.delta.toString());
      };
      instance.onDown = (details) {
        print("TouchChild onDown");
      };

      instance.onCancel = () {
        print("TouchChild onCancel");
      };

      instance.onEnd = (details) {
        print("TouchChild onEnd");
      };
    });
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
        gestures: gestures(),
        child: Container(
          color: Colors.red,
          width: 200,
          height: 200,
        ));
  }
}
