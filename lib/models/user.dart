import 'dart:async';
import 'dart:convert';

import 'package:itis_cards/models/config.dart';

class UserName {
  String first, second;
  UserName({this.first, this.second});
  Map<String, dynamic> toJson() => {
        "first": this.first,
        "second": this.second,
      };
  factory UserName.fromJson(json) => json == null
      ? new UserName()
      : new UserName(
          first: json["first"] ?? null,
          second: json["second"] ?? null,
        );
}

class UserCompany {
  String title, job;
  UserCompany({this.title, this.job});
  Map<String, dynamic> toJson() => {
        "title": this.title,
        "job": this.job,
      };
  factory UserCompany.fromJson(json) => json == null
      ? new UserCompany()
      : new UserCompany(
          title: json["title"] ?? null,
          job: json["job"] ?? null,
        );
}

class UserAccounts {
  Map<String, dynamic> socials, messengers;
  UserAccounts({this.socials, this.messengers});
  Map<String, dynamic> toJson() => {
        "socials": this.socials,
        "messengers": this.messengers,
      };
  factory UserAccounts.fromJson(json) => json == null
      ? new UserAccounts()
      : new UserAccounts(
          socials: json["socials"] ?? {},
          messengers: json["messengers"] ?? {},
        );
}

class User {
  static User local;

  int id;
  String phone;
  UserName name;
  UserCompany company;
  String bio;
  UserAccounts accounts;
  List<String> photos;
  bool policyAccepted = false;

  User({this.id, this.phone, this.name, this.company, this.bio, this.accounts, this.photos, this.policyAccepted});

  factory User.fromJson(Map<String, dynamic> data) {
    List<String> photos = ((data['photos'] ?? []) as List).map<String>((_) => _.toString()).toList();
    return new User(
      id: data['id'] is String ? int.parse(data['id']) : (data['id'] ?? 0),
      phone: data['phone'].toString(),
      name: new UserName.fromJson(data['name']),
      company: new UserCompany.fromJson(data['company']),
      bio: data['bio'] as String,
      accounts: new UserAccounts.fromJson(data['accounts']),
      photos: photos,
      policyAccepted: data['policy_accepted'].toString() == "1",
    );
  }

  static Future<User> fromDataBase() async {
    return new User.fromJson(json.decode(await Config.loadRowFromConfig("user")));
  }

  Future toDataBase() async {
    await Config.saveRowToConfig("user", json.encode(this.toJson()));
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "id": this.id.toString(),
      "phone": this.phone,
      "name": this.name == null ? null : this.name.toJson(),
      "company": this.company == null ? null : this.company.toJson(),
      "bio": this.bio,
      "accounts": this.accounts == null ? null : this.accounts.toJson(),
      "photos": this.photos,
      "policy_accepted": this.policyAccepted,
    };
  }

  static Future<User> getById(int id) async {
    return User.local;
  }
}
