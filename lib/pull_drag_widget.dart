import 'dart:math';

import 'package:drag_card/orntdrag.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class PullDragWidget extends StatefulWidget {
  final Widget headerWidget;
  final Widget child;
  final double maxHeight;
  final double dragRatio;
  const PullDragWidget(
      {Key key,
      this.headerWidget,
      this.child,
      this.maxHeight,
      this.dragRatio = 0.4})
      : super(key: key);

  @override
  _PullDragWidgetState createState() => _PullDragWidgetState();
}

class _PullDragWidgetState extends State<PullDragWidget>
    with SingleTickerProviderStateMixin {
  double _offsetY = 0;

  AnimationController _animationController;

  bool _opened = false;

  @override
  void initState() {
    _offsetY = 0;
    _animationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _animationController.addListener(() {
      var value = _animationController.value * widget.maxHeight;
      print(value);
      _offsetY = value;
      _offsetY = max(0, min(widget.maxHeight, _offsetY));
      setState(() {});
    });
    _animationController.addStatusListener((AnimationStatus status) {
      if (_offsetY == 0) {
        _opened = false;
      } else if (_offsetY == widget.maxHeight) {
        _opened = true;
      }
      setState(() {});
    });
    _contentGestures = {
        OrientationGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<OrientationGestureRecognizer>(
                () => OrientationGestureRecognizer(
                    OrientationGestureRecognizer.down,changeGestureOrientation), (instance) {
          instance.onDown = _onDragDown;
          instance.onStart = _onDragStart;
          instance.onUpdate = _onDragUpdate;
          instance.onCancel = _onDragCancel;
          instance.onEnd = _onDragEnd;
        })
      };
       super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _animationController?.dispose();
  }

  int changeGestureOrientation(){
      if (_opened) {
        return OrientationGestureRecognizer.all;
      }
      return OrientationGestureRecognizer.down;
  }

  Widget _headerWidget() {
    return Transform.translate(
      offset: Offset(0, -widget.maxHeight),
      child: Container(
        child: widget.headerWidget,
        height: widget.maxHeight,
      ),
    );
  }

  _onDragStart(DragStartDetails details) {}

   _onDragDown(DragDownDetails details) {
      setState(() {});
   }

  _onDragUpdate(DragUpdateDetails details) {
    _offsetY += widget.dragRatio * details.delta.dy;
    _offsetY = max(0, min(widget.maxHeight, _offsetY));
    setState(() {});
  }

  _onDragEnd(DragEndDetails details) {
    _onTouchRelease();
  }

  _onDragCancel() {
    // _onTouchRelease();
  }

  _onTouchRelease() {
    if (_offsetY == 0) {
      if (_opened) {
        _opened = false;
      }
      setState(() {});
      return;
    }
    if (_offsetY == widget.maxHeight) {
      if (!_opened) {
        _opened = true;
      }
      setState(() {});
      return;
    }

    if (!_opened) {
      if (_offsetY.abs() > widget.maxHeight * 0.3) {
        _smoothOpen();
      } else {
        _smoothClose();
      }
    } else {
      if (_offsetY.abs() < widget.maxHeight - kTouchSlop) {
        _smoothClose();
      } else {
        _smoothOpen();
      }
    }
  }

  _smoothOpen() {
    _animationController.value = _offsetY / widget.maxHeight;
    _animationController?.forward();
  }

  _smoothClose() {
    _animationController.value = _offsetY / widget.maxHeight;
    _animationController?.reverse();
  }

  Map<Type, GestureRecognizerFactory> _contentGestures;


  @override
  Widget build(BuildContext context) {
    return Transform.translate(
        offset: Offset(0, _offsetY),
        child: Stack(
          children: <Widget>[
            RawGestureDetector(
              behavior: HitTestBehavior.opaque,
              gestures: _contentGestures,
              child: widget.child,
            ),
            _headerWidget()
          ],
        ));
  }
}
