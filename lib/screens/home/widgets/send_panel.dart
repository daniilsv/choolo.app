import 'package:flutter/material.dart';
import 'package:itis_cards/models/config.dart';
import 'package:itis_cards/styles/style.dart';
import 'package:itis_cards/widgets/choolo_icons.dart';

typedef void Callback();

class SendPanel extends StatefulWidget {
  final Callback processQR, processNFC, processBeep;
  SendPanel({Key key, this.processQR, this.processNFC, this.processBeep}) : super(key: key);
  SendPanelState createState() => SendPanelState();
}

class SendPanelState extends State<SendPanel> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;

  show() {
    return _controller.forward();
  }

  hide() {
    return _controller.reverse();
  }

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(duration: const Duration(milliseconds: 200), vsync: this);

    _animation = new CurvedAnimation(
      parent: _controller,
      curve: new Interval(0.0, 0.75, curve: Curves.linear),
    );
  }

  buildButtonsFlex() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        InkWell(
          onTap: widget.processBeep,
          child: Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Row(
              children: <Widget>[
                Icon(ChooloIcons.wave, size: 40.0),
                Text("   BEEP",
                    style: (TextStyle(
                      fontSize: 30.0,
                      color: Color.fromARGB(255, 55, 55, 55),
                      fontWeight: FontWeight.bold,
                    ))),
              ],
            ),
          ),
        ),
        Config.isNfcAvailable == 0
            ? InkWell(
                onTap: widget.processNFC,
                child: Padding(
                  padding: const EdgeInsets.only(left: 30.0),
                  child: Row(
                    children: <Widget>[
                      Icon(ChooloIcons.nfc, size: 40.0),
                      Text("   NFC",
                          style: (TextStyle(
                            fontSize: 30.0,
                            color: Color.fromARGB(255, 55, 55, 55),
                            fontWeight: FontWeight.bold,
                          ))),
                    ],
                  ),
                ),
              )
            : null,
        InkWell(
          onTap: widget.processQR,
          child: Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Row(
              children: <Widget>[
                Icon(ChooloIcons.qrcode, size: 40.0),
                Text("   QR",
                    style: (TextStyle(
                      fontSize: 30.0,
                      color: Color.fromARGB(255, 55, 55, 55),
                      fontWeight: FontWeight.bold,
                    ))),
              ],
            ),
          ),
        )
      ].where((w) => w != null).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: SlideTransition(
        position: new Tween<Offset>(
          begin: const Offset(0.1, 1.0),
          end: const Offset(0.1, -0.6),
        ).animate(_animation),
        child: Material(
          type: MaterialType.card,
          elevation: 5.0,
          color: StyleColors.white,
          child: Container(height: 150.0, width: 200.0, child: buildButtonsFlex()),
        ),
      ),
    );
  }
}
