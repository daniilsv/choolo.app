import 'dart:async';

import 'package:flutter/services.dart';

class ItisCards {
  static const MethodChannel _channel = const MethodChannel('itis.cards');
  static const EventChannel _streamChannel = const EventChannel('itis.cards/stream');

  static get nfcAvailable async {
    return 3; //await _channel.invokeMethod('getNfcAvailable');
  }

  static get nfcIntentData async {
    return await _channel.invokeMethod('readNfcIntent');
  }

  static startBeepSdk() async {
    return await _channel.invokeMethod('startBeepSdk');
  }

  static restartBeepSdk() async {
    return await _channel.invokeMethod('restartBeepSdk');
  }

  static stopBeepSdk() async {
    return await _channel.invokeMethod('stopBeepSdk');
  }

  static sendBeepData(String data) async {
    return await _channel.invokeMethod('sendBeepData', data);
  }

  static Stream<List<String>> get receiveData {
    return _streamChannel.receiveBroadcastStream().map((_) {
      String type = (_ as String).substring(0, 4);
      String data = (_ as String).substring(4);
      print([type, data]);
      return [type, data];
    });
  }
}
