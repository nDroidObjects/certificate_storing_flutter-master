import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';

class User {
  String id;
  String name;
  String role;
  String uid;

  User({this.id, this.name, this.role, this.uid});

  factory User.fromJson(String responseBody) {
    final parsedJson= json.decode(responseBody);
    return new User(
        id	 :parsedJson['id'],
        name	 :parsedJson['name'],
        role	 :parsedJson['role'],
        uid	 :parsedJson['uid']);
    }

  Map toJson() => {
  'id': id,
    "id": id,
    "name": name,
    "role": role,
    "uid": uid,
  };
  static List<User> parseList(String responseBody) {
    responseBody = responseBody.toString().substring(1, responseBody
        .toString()
        .length - 1);
    List<String> stringObjList = responseBody.toString().split("},");
    List<User> objList = new List();
    for (int i = 0; i < stringObjList.length; i++) {
      if (i == stringObjList.length - 1) {
        objList.add(User.fromJson(stringObjList[i]));
      }
      else {
        objList.add(User.fromJson(stringObjList[i] + "}"));
      }
      return objList;
    }
  }
}