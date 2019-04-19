import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:itis_cards/models/user.dart';
import 'package:itis_cards/routes.dart';
import 'package:itis_cards/screens/auth/index.dart';
import 'package:itis_cards/screens/home/index.dart';
import 'package:itis_cards/screens/set_name/index.dart';
import 'package:itis_cards/services/connection.dart';
import 'package:itis_cards/services/utils.dart';
import 'package:itis_cards/styles/style.dart';
import 'package:itis_cards/widgets/itis_scaffold.dart';

class App {
  static var _itisScaffoldKeys = new Queue<GlobalKey<ItisScaffoldState>>();

  static GlobalKey<ItisScaffoldState> get lastItisScaffoldKey {
    return _itisScaffoldKeys.last;
  }

  static pushItisScaffoldKey(GlobalKey<ItisScaffoldState> key) {
    _itisScaffoldKeys.addLast(key);
  }

  static GlobalKey<ItisScaffoldState> popItisScaffoldKey() {
    return _itisScaffoldKeys.removeLast();
  }

  static int code;
  static String receiveIdSource;
  static String receivedId;

  static processAuth() async {
    Routes.initAuthRoutes();
    runApp(new MaterialApp(
      title: "Itis.cards",
      home: new AuthScreen(),
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: StyleColors.primary,
        accentColor: StyleColors.accent,
        backgroundColor: StyleColors.secondary,
      ),
    ));
  }

  static processMain() async {
    User.local = await User.fromDataBase();
    if (User.local.name.first == null) {
      runApp(new MaterialApp(
        title: "Itis.cards",
        home: new SetNameScreen(),
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: StyleColors.primary,
          accentColor: StyleColors.accent,
          canvasColor: Colors.transparent,
        ),
      ));
      return;
    }
    // if (!user.policyAccepted) {
    //   runApp(new MaterialApp(
    //     title: "Itis.cards",
    //     home: new PolicyScreen(),
    //     theme: ThemeData(
    //       brightness: Brightness.light,
    //       primaryColor: StyleColors.primary,
    //       accentColor: StyleColors.accent,
    //       canvasColor: Colors.transparent,
    //     ),
    //   ));
    //   return;
    // }
    Routes.initRoutes();

    Connection.listenDown("app", down);
    Connection.listenUp("app", up);
    Connection.connect();

    runApp(new MaterialApp(
      title: "Itis.cards",
      home: new HomeScreen(),
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: StyleColors.primary,
        accentColor: StyleColors.accent,
        canvasColor: Colors.transparent,
      ),
    ));
  }

  static bool down(err) {
    Utils.showInSnackBar(App.lastItisScaffoldKey, "Нет связи с сервером");
    return false;
  }

  static bool up() {
    Utils.showInSnackBar(App.lastItisScaffoldKey, "Связь с сервером восстановлена");
    return false;
  }
}
