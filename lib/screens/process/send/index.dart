import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:itis_cards/app.dart';
import 'package:itis_cards/models/user.dart';
import 'package:itis_cards/screens/home/widgets/send_panel.dart';
import 'package:itis_cards/services/connection.dart';
import 'package:itis_cards/services/itis_cards.dart';
import 'package:itis_cards/styles/style.dart';
import 'package:itis_cards/widgets/contact_card.dart';
import 'package:itis_cards/widgets/itis_scaffold.dart';
import 'package:itis_cards/widgets/choolo_icons.dart';
import 'package:itis_cards/widgets/number.dart';
import 'package:itis_cards/widgets/uni_header.dart';
import 'package:qr/qr.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProcessSendScreen extends StatefulWidget {
  final String source;

  ProcessSendScreen({this.source});

  @override
  _ProcessSendScreenState createState() => new _ProcessSendScreenState();
}

class _ProcessSendScreenState extends State<ProcessSendScreen> {
  final GlobalKey<ItisScaffoldState> _itisKey = new GlobalKey<ItisScaffoldState>();
  final GlobalKey<SendPanelState> sendPanelKey = new GlobalKey<SendPanelState>();
  final GlobalKey<SendPanelState> receivePanelKey = new GlobalKey<SendPanelState>();

  List<String> codes;
  Map<String, dynamic> requests = {};
  @override
  void initState() {
    App.pushItisScaffoldKey(_itisKey);
    Connection.listen("contact.request", (_) {
      requests[_["user"]["id"]] = _;
      print(_);
      setState(() {});
      return false;
    });
    super.initState();
    process(true);
  }

  @override
  void dispose() {
    App.popItisScaffoldKey();
    Connection.unListen("contact.request");
    super.dispose();
  }

  IconData repeatIcon() {
    switch (widget.source) {
      case "qr":
        return ChooloIcons.qrcode;
      case "nfc":
        return ChooloIcons.nfc;
      case "beep":
        return ChooloIcons.wave;
    }
    return null;
  }

  Widget buildBody() {
    Size size = MediaQuery.of(context).size;
    if (requests.length == 0)
      return Align(
        alignment: Alignment.center,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Text(
              "Сообщите этот номер\nвашему собеседнику",
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          NumberWidget((App.code ?? 0).toString(), 100.0),
        ]),
      );
    else
      return Positioned.fill(
        top: size.height * .22,
        child: ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> request = requests[requests.keys.toList()[index]] as Map<String, dynamic>;
              return ContactCard(userMap: request);
            }),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ItisScaffold(
      key: _itisKey,
      backgroundColor: Colors.white,
      body: Stack(children: <Widget>[
        UniHeaderWidget(
          needBack: true,
          number: App.code, //(requests.length > 0) ? App.code : null,
          repeatIcon: repeatIcon(),
          repeatCallback: () => process(false),
        ),
        buildBody(),
      ]),
    );
  }

  generateCodeAndSend() async {
    App.code = DateTime.now().millisecondsSinceEpoch;
    Connection.send("contact.code", {"code": App.code.toString()});
    App.code = 10 + App.code % 17212 % 90;
  }

  process(bool send) async {
    if (send) await generateCodeAndSend();
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

  qr() async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
            title: Center(child: Text("QR")),
            content: Container(
              constraints: BoxConstraints.expand(width: 300.0, height: 300.0),
              child: QrImage(
                data: "u${User.local.id}",
                size: 300.0,
                foregroundColor: StyleColors.primaryDark,
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
            ),
          ),
    );
  }

  nfc() async {}

  beep() async {
    await ItisCards.sendBeepData("u${User.local.id}");
    ItisCards.receiveData.where((_) => _[0] == "bsnt").listen((_) {
      // Routes.navigateTo(context, '/send/beep');
    });
  }
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
