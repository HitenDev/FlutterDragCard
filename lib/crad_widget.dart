import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef OnDragUpdateListener = void Function(double dx, double dy);

class CardWidget extends StatefulWidget {
  final int index;

  final OnDragUpdateListener onDragUpdateListener;

  const CardWidget({Key key, this.index, this.onDragUpdateListener})
      : super(key: key);

  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> with TickerProviderStateMixin {
  double _totalDx;
  double _totalDy;

  Animation<Offset> _animation;
  AnimationController _animationController;

  Set<int> _pointerSet = Set();

  Size _widgetSize;

  @override
  void initState() {
    _totalDx = _totalDy = 0;
    super.initState();
  }

  _onPointDown(PointerEvent event) {
    _pointerSet.add(event.pointer);
    if (_widgetSize == null) {
      setState(() {
        _widgetSize = Size(context.size.width, context.size.height);
      });
    }
  }

  _onPointMove(PointerEvent event) {
    _totalDx += event.delta.dx;
    _totalDy += event.delta.dy;
    if (widget.onDragUpdateListener != null) {
      widget.onDragUpdateListener(_totalDx, _totalDy);
    }
    setState(() {
    });
  }

  _onPointUpOrCancel(PointerEvent event) {
    var pointer = event.pointer;
    _pointerSet.remove(pointer);
    if (_pointerSet.isNotEmpty) {
      return;
    }
    setState(() {
      _totalDx += event.delta.dx;
      _totalDy += event.delta.dy;
    });
    if (_totalDx.abs() >= context.size.width * 0.2 ||
        _totalDy.abs() >= context.size.height * 0.2) {
      double endX, endY;
      if (_totalDx.abs() > _totalDy.abs()) {
        endX = context.size.width * _totalDx.sign;
        endY = _totalDy.sign *
            context.size.width *
            _totalDy.abs() /
            _totalDx.abs();
      } else {
        endY = context.size.height * _totalDy.sign;
        endX = _totalDx.sign *
            context.size.height *
            _totalDx.abs() /
            _totalDy.abs();
      }
      _startAnimator(Offset(_totalDx, _totalDy), Offset(endX, endY));
    } else {
      _startAnimator(Offset(_totalDx, _totalDy), Offset.zero);
    }
  }

  _startAnimator(Offset begin, Offset end) {
    _animationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _animation = Tween(begin: begin, end: end).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.linear));
    _animationController.addListener(() {
      setState(() {
        _totalDx = _animation.value.dx;
        _totalDy = _animation.value.dy;
      });
    });
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _totalDx = 0;
          _totalDy = 0;
        });
      }
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    if (_animationController != null) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double ratio = 0;
    if (_widgetSize != null) {
      ratio = sqrt(_totalDx * _totalDx + _totalDy * _totalDy) /
          (sqrt(_widgetSize.width * _widgetSize.width +
                  _widgetSize.height * _widgetSize.height) *
              0.2);
    }
    if (ratio > 1) {
      ratio = 1;
    }
    if (ratio < 0) {
      ratio = 0;
    }
    double dx = (widget.index == 0 ? _totalDx : ratio * -12);
    double dy = (widget.index == 0 ? _totalDy : ratio * 12);
    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 24, right: 24),
        child: AspectRatio(
            aspectRatio: 0.75,
            child: Transform(
              transform: Matrix4.translationValues(
                  dx + (12 * widget.index.toDouble()),
                  dy + (-12 * widget.index.toDouble()),
                  0),
              child: Listener(
                  onPointerDown: _onPointDown,
                  onPointerMove: _onPointMove,
                  onPointerUp: _onPointUpOrCancel,
                  onPointerCancel: _onPointUpOrCancel,
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    constraints: BoxConstraints.expand(),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Image.network(
                            widget.index == 1
                                ? "http://img.bimg.126.net/photo/V6nNeq8YN2xPBRxTz8w4VA==/5776429472056759812.jpg"
                                : "http://pic1.nipic.com/2008-12-30/200812308231244_2.jpg",
                            fit: BoxFit.cover,
                          ),
                          Container(color: const Color(0x5a000000)),
                          Container(
                            margin: EdgeInsets.all(20),
                            alignment: Alignment.center,
                            child: Text(
                              "离家的路由千万条，而回家的路，只有一条。",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  letterSpacing: 2,
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                              maxLines: 4,
                            ),
                          )
                        ],
                      ),
                    ),
                  )),
            )));
  }
}
