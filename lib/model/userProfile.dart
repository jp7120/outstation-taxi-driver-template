// To parse this JSON data, do
//
//     final userData = userDataFromJson(jsonString);

import 'dart:convert';

UserData userDataFromJson(String str) => UserData.fromJson(json.decode(str));

String userDataToJson(UserData data) => json.encode(data.toJson());

class UserData {
  UserData({
    this.name,
    this.phoneNum,
    this.uid,
    this.notificationToken,
    this.createdAt,
    this.email,
  });

  String name;
  String phoneNum;
  String uid;
  String notificationToken;

  String createdAt;
  String email;

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        name: json["name"],
        phoneNum: json["phoneNum"],
        uid: json["uid"],
        notificationToken: json["notificationToken"],
        createdAt: json["created_at"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "phoneNum": phoneNum,
        "uid": uid,
        "notificationToken": notificationToken,
        "created_at": createdAt,
        "email": email,
      };
}
