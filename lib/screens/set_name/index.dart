import 'package:flutter/material.dart';
import 'package:itis_cards/app.dart';
import 'package:itis_cards/models/user.dart';
import 'package:itis_cards/services/query.dart';
import 'package:itis_cards/services/utils.dart';
import 'package:itis_cards/styles/style.dart';
import 'package:itis_cards/widgets/itis_scaffold.dart';

class SetNameScreen extends StatefulWidget {
  @override
  _SetNameScreenState createState() => new _SetNameScreenState();
}

class _SetNameScreenState extends State<SetNameScreen> {
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

  final _formKey = GlobalKey<FormState>();
  bool isAutovalidate = false;
  Widget buildSetNameScreen() {
    return Form(
      key: _formKey,
      autovalidate: isAutovalidate,
      child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
        TextFormField(
          keyboardType: TextInputType.text,
          style: TextStyle(fontSize: MediaQuery.of(context).size.width / 12, color: StyleColors.white),
          decoration: InputDecoration(
            isDense: false,
            labelStyle: TextStyle(color: StyleColors.white, fontSize: 16.0, fontWeight: FontWeight.w200),
            labelText: "Введите имя",
            border: InputBorder.none,
          ),
          onSaved: (text) {
            User.local.name.first = text;
          },
          validator: (value) {
            if (value.isEmpty) {
              return 'Пожалуйста введите своё имя';
            }
          },
        ),
        TextFormField(
          keyboardType: TextInputType.text,
          style: TextStyle(fontSize: MediaQuery.of(context).size.width / 12, color: StyleColors.white),
          decoration: InputDecoration(
            isDense: false,
            labelStyle: TextStyle(color: StyleColors.white, fontSize: 16.0, fontWeight: FontWeight.w200),
            labelText: "Введите фамилию",
            border: InputBorder.none,
          ),
          onSaved: (text) {
            User.local.name.second = text;
          },
        ),
      ]),
    );
  }

  submitName() async {
    FormState form = _formKey.currentState;
    if (!form.validate()) {
      isAutovalidate = true;
      Utils.showInSnackBar(_itisKey, 'Please fix the errors in red before submitting.');
    } else {
      form.save();
      var res = await Query.execute("/user/edit", params: {"name": User.local.name.toJson()});
      if (!res['error']) {
        await User.local.toDataBase();
        App.processMain();
      } else {
        Utils.showInSnackBar(_itisKey, res['response']);
      }
    }
  }

  Widget buildBottomRow() {
    Size size = MediaQuery.of(context).size;
    return Container(
      constraints: BoxConstraints.expand(height: size.height * .07),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          InkWell(
            onTap: submitName,
            child: Text(
              "Далее",
              style: new TextStyle(color: Color(0xff555555), fontSize: 27.0),
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
                'Введите\nИмя',
                style: TextStyle(color: Colors.white, fontSize: 27.0, fontWeight: FontWeight.w300),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * .3,
                ),
                child: buildSetNameScreen(),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: buildBottomRow(),
            ),
          ],
        ));
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
    p.lineTo(size.width, size.height * .2);
    p.lineTo(size.width, size.height);
    p.lineTo(0, size.height);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
