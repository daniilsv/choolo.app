import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:itis_cards/app.dart';
import 'package:itis_cards/models/config.dart';
import 'package:itis_cards/services/database.dart';
import 'package:itis_cards/services/itis_cards.dart';

const bool isInDebugMode = true;
void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    if (isInDebugMode) {
      // In development mode simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone to report to
      // Sentry.
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };
  runZoned<Future<Null>>(() async {
    startHome();
  }, onError: (error, stackTrace) {
    print('Caught error: $error');
    print(stackTrace);
  });
}

void startHome() async {
  var db = new DataBase();
  if (!await db.open()) {
    await db.open();
  }

  Config.dump();

  Config.isNfcAvailable = await ItisCards.nfcAvailable;
  await Config.loadFromDB();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  if (Config.token == null) {
    App.processAuth();
  } else {
    App.processMain();
  }
}
