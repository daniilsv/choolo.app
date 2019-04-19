import 'dart:async';
import 'dart:convert';

import 'package:itis_cards/app.dart';
import 'package:itis_cards/models/config.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

typedef bool ListenCallback(dynamic params);
typedef bool ListenDownCallback(dynamic params);
typedef bool ListenUpCallback();

class Connection {
  static IOWebSocketChannel _channel;

  static Map<String, ListenCallback> _handlers = {};
  static Map<String, ListenDownCallback> _downHandlers = {};
  static Map<String, ListenUpCallback> _upHandlers = {};

  static bool _isClose = false;
  static dynamic _error;

  static connect() {
    print("connect");
    close();
    _open();
  }

  static reconnect() async {
    print("reconnect");
    await new Future.delayed(new Duration(seconds: 2));
    close();
    _isClose = false;
    _open();
  }

  static _open() {
    if (_channel != null) return;
    if (Config.token == null) return;
    print("open");
    _channel = IOWebSocketChannel.connect("${Config.wsUrl}");
    _channel.stream.listen(onMessage, onDone: onDone, onError: onError);
  }

  static close() {
    if (_channel == null) return;
    _isClose = true;
    _channel.sink.close(ws_status.goingAway);
    _channel = null;
  }

  static send(String type, dynamic data) {
    if (_channel == null) return;
    data = json.encode({"type": type, "params": data});
    print(">> " + data);
    _channel.sink.add(data);
  }

  static onMessage(dynamic message) {
    print("<< " + message);
    try {
      message = json.decode(message) as Map<String, dynamic>;
    } on Exception {
      return;
    }
    if (!(message is Map) || !message.containsKey("type")) return;
    switch (message['type']) {
      case "token":
        send("token", Config.token);
        break;
      case "ping":
        onUp();
        break;
      case "close":
        onError(message["params"]);
        break;
      default:
        ListenCallback cb = _handlers[message["type"]];
        if (cb != null) if (cb(message["params"])) _handlers.remove(message["type"]);
    }
  }

  static void onError(err) {
    _error = err;
  }

  static void onDone([err]) async {
    if (_error != null) err = _error;
    _error = null;
    print("done: " + err.toString());
    if (Config.isOnline) {
      List deleteHandlers = [];
      _downHandlers.forEach((k, c) => deleteHandlers.add(c(err) ? k : null));
      deleteHandlers.forEach((n) {
        if (n != null) _downHandlers.remove(n);
      });
    }
    Config.isOnline = false;
    switch (err.toString()) {
      case "Token invalid":
        _isClose = true;
        Config.token = null;
        Config.saveToDB();
        App.processAuth();
        break;
      default:
        if (!_isClose) {
          reconnect();
        }
        _isClose = false;
        break;
    }
  }

  static void onUp() async {
    print("up");
    if (!Config.isOnline) {
      List deleteHandlers = [];
      _upHandlers.forEach((k, c) => deleteHandlers.add(c() ? k : null));
      deleteHandlers.forEach((n) {
        if (n != null) _upHandlers.remove(n);
      });
    }
    Config.isOnline = true;
  }

  static listen(String type, ListenCallback callback) {
    _handlers[type] = callback;
  }

  static unListen(String type) {
    _handlers.remove(type);
  }

  static listenDown(String type, ListenDownCallback callback) {
    _downHandlers[type] = callback;
  }

  static unListenDown(String type) {
    _downHandlers.remove(type);
  }

  static listenUp(String type, ListenUpCallback callback) {
    _upHandlers[type] = callback;
  }

  static unListenUp(String type) {
    _upHandlers.remove(type);
  }
}
