import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itis_cards/app.dart';
import 'package:itis_cards/screens/home/widgets/receive_panel.dart';
import 'package:itis_cards/screens/home/widgets/send_panel.dart';
import 'package:itis_cards/services/connection.dart';
import 'package:itis_cards/services/itis_cards.dart';
import 'package:itis_cards/services/utils.dart';
import 'package:itis_cards/widgets/contact_card.dart';
import 'package:itis_cards/widgets/itis_scaffold.dart';
import 'package:itis_cards/widgets/number.dart';
import 'package:itis_cards/widgets/uni_header.dart';

class ProcessReceiveScreen extends StatefulWidget {
  final String source;

  ProcessReceiveScreen({this.source});

  @override
  _ProcessReceiveScreenState createState() => new _ProcessReceiveScreenState();
}

class _ProcessReceiveScreenState extends State<ProcessReceiveScreen> {
  final GlobalKey<ItisScaffoldState> _itisKey = new GlobalKey<ItisScaffoldState>();
  final GlobalKey<SendPanelState> sendPanelKey = new GlobalKey<SendPanelState>();
  final GlobalKey<ReceivePanelState> receivePanelKey = new GlobalKey<ReceivePanelState>();

  int state = 0;
  List<String> codes;

  String id;

  bool waiting = false;
  Map<String, dynamic> request;
  @override
  void initState() {
    App.pushItisScaffoldKey(_itisKey);
    super.initState();
    Connection.listen("contact.receive_back", (_) {
      setState(() {});
      return false;
    });
    preProcess();
  }

  @override
  void dispose() {
    App.popItisScaffoldKey();
    Connection.unListen("contact.receive_back");
    super.dispose();
  }

  Widget buildNumbers() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        NumberWidget(codes[0], 60.0, onTap: () => onNumberTap(codes[0])),
        NumberWidget(codes[1], 60.0, onTap: () => onNumberTap(codes[1])),
        NumberWidget(codes[2], 60.0, onTap: () => onNumberTap(codes[2])),
      ],
    );
  }

  Widget buildBody() {
    Size size = MediaQuery.of(context).size;
    if (!waiting && request == null)
      return Align(
        alignment: Alignment.center,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              "Какой номер сказал ваш\nсобеседник?",
              style: TextStyle(fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.w400),
            ),
          ),
          codes == null ? Container() : buildNumbers(),
        ]),
      );
    if (waiting)
      return Align(
        alignment: Alignment.center,
        child: Text(
          "Ожидайте...",
          style: TextStyle(fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.w400),
        ),
      );
    if (request != null) {
      return Positioned.fill(
        top: size.height * .22,
        child: SingleChildScrollView(child: ContactCard(userMap: request)),
      );
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return ItisScaffold(
      key: _itisKey,
      backgroundColor: Colors.white,
      body: Stack(fit: StackFit.expand, children: <Widget>[
        UniHeaderWidget(
          needBack: true,
          titleLabel: "Добавление контакта",
        ),
        buildBody(),
      ]),
    );
  }

  onNumberTap(String code) {
    Connection.send("contact.receive", {
      "id": id,
      "source": widget.source,
      "code": code,
    });
    setState(() {
      waiting = true;
    });
    Connection.listen("contact.accept", (_) {
      setState(() {
        waiting = false;
        request = _;
      });
      return true;
    });
  }

  preProcess() {
    switch (widget.source) {
      case "qr":
        qr();
        break;
      case "nfc":
        nfc();
        break;
      case "beep":
        beep();
        break;
    }
  }

  postProcess(String id) {
    this.id = id;
    Connection.listen("contact.get_codes", (_) {
      codes = (_["codes"] as List).map<String>((__) => __.toString()).toList();
      setState(() {});
      return true;
    });
    Connection.send("contact.get_codes", {"id": id});
  }

  qr() async {
    String barcode = await Utils.scanQR();
    if (checkId(barcode)) postProcess(barcode);
  }

  nfc() async {}

  beep() async {
    await ItisCards.restartBeepSdk();
    ItisCards.receiveData.where((_) => _[0] == "brvd").listen((_) {
      if (checkId(_[1])) postProcess(_[1]);
      ItisCards.stopBeepSdk();
    });
  }

  checkId(String id) =>
      id.length >= 2 && int.tryParse(id.substring(0, 1)) == null && int.tryParse(id.substring(1)) != null;
}

class _TopLeftClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = Path();
    p.moveTo(0, 0);
    p.lineTo(size.width * .75, 0);
    p.lineTo(size.width * .57, size.height);
    p.lineTo(0, size.height * .6);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _TopRightClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = Path();
    p.moveTo(size.width * .73, 0);
    p.lineTo(size.width * .57, size.height);
    p.lineTo(size.width, size.height * .4);
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
