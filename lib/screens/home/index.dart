import 'dart:async';

import 'package:flutter/material.dart';
import 'package:itis_cards/app.dart';
import 'package:itis_cards/routes.dart';
import 'package:itis_cards/screens/home/widgets/receive_panel.dart';
import 'package:itis_cards/screens/home/widgets/send_panel.dart';
import 'package:itis_cards/widgets/itis_scaffold.dart';
import 'package:itis_cards/widgets/uni_header.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ItisScaffoldState> _itisKey = new GlobalKey<ItisScaffoldState>();
  final GlobalKey<SendPanelState> sendPanelKey = new GlobalKey<SendPanelState>();
  final GlobalKey<ReceivePanelState> receivePanelKey = new GlobalKey<ReceivePanelState>();

  int state = 0;

  @override
  void initState() {
    App.pushItisScaffoldKey(_itisKey);
    super.initState();
  }

  @override
  void dispose() {
    App.popItisScaffoldKey();
    super.dispose();
  }

  bottomTabView() {
    Size size = MediaQuery.of(context).size;
    return Container(
      constraints: BoxConstraints.expand(height: size.height * .09),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          InkWell(
            onTap: processSend,
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: size.width * .1),
              child: Text(
                "Отправить",
                style: new TextStyle(color: Color(0xff999999), fontSize: 27.0),
              ),
            ),
          ),
          InkWell(
            onTap: processReceive,
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: size.width * .1),
              child: Text(
                "Принять",
                style: new TextStyle(color: Color(0xff555555), fontSize: 27.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  processSend() async {
    if (state == 0) {
      await receivePanelKey.currentState.hide();
      sendPanelKey.currentState.show();
      setState(() {
        state = 1;
      });
    } else {
      sendPanelKey.currentState.hide();
      setState(() {
        state = 0;
      });
    }
  }

  processReceive() async {
    if (state == 0) {
      await sendPanelKey.currentState.hide();
      receivePanelKey.currentState.show();
      setState(() {
        state = 2;
      });
    } else {
      receivePanelKey.currentState.hide();
      setState(() {
        state = 0;
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (state != 0) {
      sendPanelKey.currentState.hide();
      receivePanelKey.currentState.hide();
      setState(() {
        state = 0;
      });
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    var body = <Widget>[];

    body.add(UniHeaderWidget(needContacts: true));

//    body.add(Align(alignment: Alignment.center, child: friendsView()));
    body.add(Positioned(
        top: MediaQuery.of(context).size.height * .4,
        child: Container(
            width: MediaQuery.of(context).size.width,
            child: Center(
                child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('Choo',
                    style: TextStyle(fontSize: MediaQuery.of(context).size.width * .27, fontWeight: FontWeight.w100)),
                Text('Lo',
                    style: TextStyle(fontSize: MediaQuery.of(context).size.width * .27, fontWeight: FontWeight.w300))
              ],
            )))));
    body.add(Align(alignment: Alignment.bottomCenter, child: bottomTabView()));
    if (state > 0)
      body.add(Positioned.fill(
        child: InkWell(
            onTap: () {
              sendPanelKey.currentState.hide();
              receivePanelKey.currentState.hide();
              setState(() {
                state = 0;
              });
            },
            child: Container(constraints: BoxConstraints.expand(), color: Colors.black54)),
      ));
    body.add(ReceivePanel(
      key: receivePanelKey,
      processBeep: () => Routes.navigateTo(context, '/receive/beep'),
      processNFC: () => Routes.navigateTo(context, '/receive/nfc'),
      processQR: () => Routes.navigateTo(context, '/receive/qr'),
    ));
    body.add(SendPanel(
      key: sendPanelKey,
      processBeep: () => Routes.navigateTo(context, '/send/beep'),
      processNFC: () => Routes.navigateTo(context, '/send/nfc'),
      processQR: () => Routes.navigateTo(context, '/send/qr'),
    ));

    return new WillPopScope(
      onWillPop: _onWillPop,
      child: ItisScaffold(
        key: _itisKey,
        backgroundColor: Colors.white,
        body: Stack(fit: StackFit.expand, children: body),
      ),
    );
  }
}
