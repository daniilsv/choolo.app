import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:itis_cards/models/config.dart';
import 'package:path/path.dart';

class Query {
  static Uri hrefTo(String path, {String protocol, String baseUrl, int port, String file, Map<String, dynamic> query}) {
    return new Uri(
      scheme: protocol ?? Config.httpProtocol,
      host: baseUrl ?? Config.httpBaseUrl,
      path: join(path, file),
      port: port ?? Config.httpPort,
      queryParameters: query,
    );
  }

  static Future<Map<String, dynamic>> sendFile(String action, String field, File file,
      {Map<String, String> params}) async {
    if (Config.token == null || file == null) return {"error": true, "response": "Не верный токен авторизации"};
    var request = new http.MultipartRequest("POST", hrefTo(action));
    request.headers.addAll({"Accept": "application/json", "auth_token": Config.token});
    if (params != null) request.fields.addAll(params);
    request.files
        .add(new http.MultipartFile(field, file.openRead(), await file.length(), filename: basename(file.path)));
    Response response;
    try {
      var streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);
    } on Exception {
      return {"error": true, "response": "Нет интернет соединения"};
    }
    try {
      var ret = json.decode(response.body) as Map<String, dynamic>;
      print(ret);
      return ret;
    } on Exception {
      return {"error": true, "response": "Что-то пошло не так"};
    }
  }

  static Future<Map<String, dynamic>> execute(String action,
      {Map<String, dynamic> params, String method = "post"}) async {
    if (params == null) params = {};
    Map<String, String> _headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };
    if (Config.token != null) _headers["auth_token"] = Config.token;
    print(hrefTo(action));
    print(params);
    print(_headers);
    print(method);
    http.Response response;
    try {
      if (method == "post") {
        response = await http.post(hrefTo(action), body: json.encode(params), headers: _headers);
      } else if (method == "get") {
        response = await http.get(hrefTo(action, query: params), headers: _headers);
      }
    } on Exception {
      return {"error": true, "response": "Нет интернет соединения"};
    }

    try {
      var ret = json.decode(response.body) as Map<String, dynamic>;
      print(ret);
      return ret;
    } on Exception {
      return {"error": true, "response": "Что-то пошло не так"};
    }
  }
}
