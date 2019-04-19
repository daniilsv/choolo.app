import 'package:flutter/material.dart';

class ItisScaffold extends StatefulWidget {
  final Widget body;
  final Color backgroundColor;
  ItisScaffold({
    Key key,
    this.body,
    this.backgroundColor,
  }) : super(key: key);
  ItisScaffoldState createState() => ItisScaffoldState();
}

class ItisScaffoldState extends State<ItisScaffold> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  AnimationController _controller;
  Animation<double> _animation;
  String _message;
  showMessage(String message) async {
    setState(() {
      _message = message;
    });
    await _controller.forward(from: 0.0);
    await Future.delayed(Duration(seconds: 2));
    if (_message == message) _controller.reverse();
    return;
  }

  @override
  void initState() {
    _controller = new AnimationController(duration: const Duration(milliseconds: 500), vsync: this);

    _animation = new CurvedAnimation(
      parent: _controller,
      curve: new Interval(0.0, 1.0),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      primary: true,
      appBar: EmptyAppBar(),
      backgroundColor: widget.backgroundColor,
      body: Stack(children: <Widget>[
        Positioned.fill(child: widget.body),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            alignment: Alignment.topCenter,
            constraints: BoxConstraints.expand(height: 16.0),
            child: SlideTransition(
              position: new Tween<Offset>(
                begin: const Offset(0.0, -1.0),
                end: const Offset(0.0, 0.0),
              ).animate(_animation),
              child: Text(
                _message ?? "",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.0, color: Colors.white),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) => Container(color: Colors.black);
  @override
  Size get preferredSize => Size(0.0, 0.0);
}
