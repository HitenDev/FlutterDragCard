import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CardWidget extends StatefulWidget {
  final int index;

  const CardWidget({Key key, this.index}) : super(key: key);

  @override
  _CardWidgetState createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> with TickerProviderStateMixin{

  double _totalDx;
  double _totalDy;

  Animation<Offset>  _animation;
  AnimationController _animationController;

  @override
  void initState() {
    _totalDx = _totalDy = 0;
    super.initState();
  }

  _onPointDown(PointerEvent event) {
    double width = context.size.width;
    double height = context.size.height;
  }

  _onPointMove(PointerEvent event) {
    setState(() {
      _totalDx += event.delta.dx;
      _totalDy += event.delta.dy;
    });
  }

  _onPointUpOrCancel(PointerEvent event) {
    setState(() {
      _totalDx += event.delta.dx;
      _totalDy += event.delta.dy;
    });
    _startAnimator();
  }

  _startAnimator(){
    _animationController = AnimationController(duration: Duration(milliseconds: 300),vsync: this);
    _animation = Tween(begin: Offset(_totalDx,_totalDy),end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve:  Curves.linear));
    _animationController.addListener((){
      setState(() {
        _totalDx = _animation.value.dx;
        _totalDy = _animation.value.dy;
      });
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    if(_animationController!=null){
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(left: 24, right: 24),
        child: AspectRatio(
            aspectRatio: 0.75,
            child: Transform(
              transform: Matrix4.translationValues(
                  (widget.index==0?_totalDx:0)+(12 * widget.index.toDouble()),
                  (widget.index==0?_totalDy:0)+(-12 * widget.index.toDouble()),
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
