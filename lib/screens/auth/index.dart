import 'package:flutter/material.dart';
import 'package:itis_cards/app.dart';
import 'package:itis_cards/routes.dart';
import 'package:itis_cards/styles/style.dart';
import 'package:itis_cards/widgets/itis_scaffold.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => new _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ItisScaffold(
        key: _itisKey,
        backgroundColor: StyleColors.primaryDark,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              color: Colors.white,
              alignment: Alignment.bottomCenter,
              child: Stack(
                overflow: Overflow.visible,
                children: <Widget>[
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ClipPath(
                      clipper: _BottomCenterClipper(),
                      child: InkWell(
                        onTap: () {
                          Routes.navigateTo(context, '/auth/phone');
                        },
                        child: Container(
                          width: size.width,
                          height: size.height * .4,
                          color: StyleColors.secondary,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ClipPath(
                      clipper: _BottomRightClipper(),
                      child: InkWell(
                        onTap: () {
                          Routes.navigateTo(context, '/auth/phone');
                        },
                        child: Container(
                          width: size.width * .45,
                          height: size.height * .4,
                          color: StyleColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: MediaQuery.of(context).size.width * .1,
                      child: InkWell(
                          onTap: () {
                            Routes.navigateTo(context, '/auth/phone');
                          },
                          child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                  child: Text(
                                'Вход',
                                style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * .1),
                              )))))
                ],
              ),
            ),
            Positioned(
                top: MediaQuery.of(context).size.height * .3,
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                        child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Choo',
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * .25, fontWeight: FontWeight.w100)),
                        Text('Lo',
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * .25, fontWeight: FontWeight.w300))
                      ],
                    )))),
          ],
        ));
  }
}

class _BottomCenterClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = Path();
    p.moveTo(0, size.height);
    p.lineTo(size.width * .55, size.height * .25);
    p.lineTo(size.width, size.height * .25);
    p.lineTo(size.width, size.height);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _BottomRightClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = Path();
    p.moveTo(size.width, size.height);
    p.lineTo(0, size.height * .25);
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
