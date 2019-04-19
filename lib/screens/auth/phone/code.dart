import 'package:flutter/material.dart';
import 'package:itis_cards/app.dart';
import 'package:itis_cards/models/config.dart';
import 'package:itis_cards/models/user.dart';
import 'package:itis_cards/routes.dart';
import 'package:itis_cards/services/query.dart';
import 'package:itis_cards/services/utils.dart';
import 'package:itis_cards/styles/style.dart';
import 'package:itis_cards/widgets/itis_scaffold.dart';
import 'package:itis_cards/widgets/masked_text.dart';

class AuthPhoneCodeScreen extends StatefulWidget {
  @override
  _AuthPhoneCodeScreenState createState() => new _AuthPhoneCodeScreenState();
}

class _AuthPhoneCodeScreenState extends State<AuthPhoneCodeScreen> {
  final labelStyle = TextStyle(color: StyleColors.white, fontSize: 16.0, fontWeight: FontWeight.w200);
  final hintStyle = TextStyle(color: Color(0xffE5E5E5));

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

  var controller = new MaskedTextController(mask: '000-000');

  String smsInputValidator() {
    if (controller.unmaskedText.isEmpty) {
      return "Введите код";
    } else if (controller.unmaskedText.length != 6) {
      return "Код введён неверно";
    }
    return null;
  }

  submitSmsAction() async {
    final error = smsInputValidator();
    if (error != null) {
      Utils.showInSnackBar(_itisKey, error);
    }
    Map<String, dynamic> data = await Query.execute(
      "auth/verify_sms_code",
      params: {"sms_token": Config.smsToken, "code": controller.unmaskedText},
      method: "post",
    );
    if (data["error"]) {
      Utils.showInSnackBar(_itisKey, data["response"]);
      return;
    }
    Config.token = data['response']['token'];
    Config.saveToDB();
    await new User.fromJson(data['response']).toDataBase();
    App.processMain();
    Routes.backTo(context, "/");
  }

  Widget buildAuthPhoneCodeScreen() {
    return TextField(
      controller: controller,
      maxLength: 11,
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: MediaQuery.of(context).size.width / 8, color: StyleColors.white),
      decoration: InputDecoration(
        isDense: false,
        counterText: "",
        hintText: "XXX-XXX",
        hintStyle: hintStyle,
        border: InputBorder.none,
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
            onTap: submitSmsAction,
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
              'Введите\nкод из\nСМС',
              style: TextStyle(color: Colors.white, fontSize: 27.0, fontWeight: FontWeight.w300),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * .3,
              ),
              child: buildAuthPhoneCodeScreen(),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: buildBottomRow(),
          )
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
    p.lineTo(size.width, size.height * .3);
    p.lineTo(size.width, size.height);
    p.lineTo(0, size.height);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
