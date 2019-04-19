import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:itis_cards/app.dart';
import 'package:itis_cards/models/config.dart';
import 'package:itis_cards/routes.dart';
import 'package:itis_cards/services/query.dart';
import 'package:itis_cards/services/utils.dart';
import 'package:itis_cards/styles/style.dart';
import 'package:itis_cards/widgets/itis_scaffold.dart';
import 'package:itis_cards/widgets/masked_text.dart';

class AuthPhoneScreen extends StatefulWidget {
  @override
  _AuthPhoneScreenState createState() => new _AuthPhoneScreenState();
}

class _AuthPhoneScreenState extends State<AuthPhoneScreen> {
  final labelStyle = TextStyle(color: Colors.white, fontSize: 26.0);
  final hintStyle = TextStyle(color: Color(0xffE5E5E5), fontSize: 26.0);

  final GlobalKey<ItisScaffoldState> _itisKey = new GlobalKey<ItisScaffoldState>();

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

  var controller = new MaskedTextController(mask: '(000) 000-00-00');

  String phoneInputValidator() {
    if (controller.unmaskedText.isEmpty) {
      return "Введите номер";
    } else if (controller.unmaskedText.length != 10) {
      return "Номер введён неверно";
    }
    return null;
  }

  submitPhoneButton() async {
    final error = phoneInputValidator();
    if (error != null) {
      Utils.showInSnackBar(_itisKey, error);
    } else {
      Map<String, dynamic> data = await Query.execute(
        "auth/request_sms",
        params: {"phone": "7" + controller.unmaskedText},
        method: "post",
      );
      if (data["error"]) {
        Utils.showInSnackBar(_itisKey, data["response"]);
        return;
      }
      Config.smsToken = data["response"]["sms_token"];
      Config.code = data["response"]["code"];
      Routes.navigateTo(this.context, "/auth/phone/code", replace: false, transition: TransitionType.inFromRight);
    }
  }

  Widget buildAuthPhoneScreen() {
    return Padding(
      padding: const EdgeInsets.only(top: 36.0),
      child: TextField(
        controller: controller,
        maxLength: 15,
        keyboardType: TextInputType.number,
        style: labelStyle,
        decoration: InputDecoration(
          isDense: false,
          counterText: "",
          hintText: "(123) 456-78-90",
          hintStyle: hintStyle,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget buildBottomRow() {
    Size size = MediaQuery.of(context).size;
    return Container(
      constraints: BoxConstraints.expand(height: size.height * .07),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          InkWell(
            onTap: () {
              Routes.navigateTo(context, '/auth');
            },
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(left: size.width * .1),
              child: Text(
                "Назад",
                style: new TextStyle(color: Color(0xff999999), fontSize: 27.0),
              ),
            ),
          ),
          InkWell(
            onTap: submitPhoneButton,
            child: Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(right: size.width * .1),
              child: Text(
                "Далее",
                style: new TextStyle(color: Color(0xff555555), fontSize: 27.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ItisScaffold(
      backgroundColor: StyleColors.primaryDark,
      key: _itisKey,
      body: Stack(
        children: <Widget>[
          ClipPath(
            clipper: _LeftClipper(),
            child: Container(
              width: size.width * .65,
              height: size.height * .75,
              color: StyleColors.secondary,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: _BottomClipper(),
              child: Container(
                width: size.width,
                height: size.height * .2,
                color: StyleColors.white,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.width * .15,
            left: MediaQuery.of(context).size.width * .05,
            child: Text(
              'Введите\nномер\nтелефона',
              style: TextStyle(color: Colors.white, fontSize: 27.0, fontWeight: FontWeight.w300),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: size.width * .1),
              child: Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(child: Text("+7", style: new TextStyle(color: Colors.white, fontSize: 48.0)), flex: 1),
                  Flexible(child: buildAuthPhoneScreen(), flex: 3),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: buildBottomRow(),
          ),
        ],
      ),
    );
  }
}

class _LeftClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = Path();
    p.moveTo(0, 0);
    p.lineTo(size.width, 0);
    p.lineTo(0, size.height);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _BottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = Path();
    p.moveTo(0, 0);
    p.lineTo(size.width, size.height * .4);
    p.lineTo(size.width, size.height);
    p.lineTo(0, size.height);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
