import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:itis_cards/screens/auth/index.dart';
import 'package:itis_cards/screens/auth/phone/code.dart';
import 'package:itis_cards/screens/auth/phone/index.dart';
import 'package:itis_cards/screens/contacts/index.dart';
import 'package:itis_cards/screens/home/index.dart';
import 'package:itis_cards/screens/process/receive/index.dart';
import 'package:itis_cards/screens/process/send/index.dart';
import 'package:itis_cards/screens/user/contact.dart';
import 'package:itis_cards/screens/user/self.dart';

class Routes {
  static Router _router = new Router();

  static void initAuthRoutes() {
    _router = Router();
    _router.define("/auth", handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return new AuthScreen();
    }));
    _router.define("/auth/phone",
        handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return new AuthPhoneScreen();
    }));
    _router.define("/auth/phone/code",
        handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return new AuthPhoneCodeScreen();
    }));
  }

  static void initRoutes() {
    _router = Router();
    _router.define("/", handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return new HomeScreen();
    }));
    _router.define("/user/edit", handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      // return new UserEditScreen();
    }));
    _router.define("/user/policy",
        handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      // return new UserPolicyScreen();
    }));
    _router.define("/user", handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return new UserScreen();
    }));
    _router.define("/contacts", handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return new ContactsScreen();
    }));
    _router.define("/user/:id", handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return new ContactScreen(id: int.parse(params['id'][0]) ?? 0);
    }));
    _router.define("/send/:source",
        handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return new ProcessSendScreen(source: params['source'][0]);
    }));
    _router.define("/receive/:source",
        handler: new Handler(handlerFunc: (BuildContext context, Map<String, dynamic> params) {
      return new ProcessReceiveScreen(source: params['source'][0]);
    }));
  }

  static Future<dynamic> navigateTo(BuildContext context, String route,
      {TransitionType transition = TransitionType.fadeIn, bool replace = false}) {
    return _router.navigateTo(context, route, replace: replace, transition: transition);
  }

  static void backTo(BuildContext context, String path) {
    Navigator.of(context).popUntil((Route<dynamic> route) {
      return route == null || route is ModalRoute && route.settings.name == path;
    });
  }
}
