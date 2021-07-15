// To parse this JSON data, do
//
//     final driverDetails = driverDetailsFromJson(jsonString);

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

DriverDetails driverDetailsFromJson(String str) =>
    DriverDetails.fromJson(json.decode(str));

String driverDetailsToJson(DriverDetails data) => json.encode(data.toJson());

class DriverDetails {
  DriverDetails({
    this.isOnline,
    this.name,
    this.ratings,
    this.amount,
    this.docsUploaded,
    this.profileImage,
    this.carType,
    this.carNumber,
    this.carName,
    this.accountCreatedAt,
    this.disableDriver,
    this.proofs,
    this.isAdminVerified,
    this.phoneNum,
    this.location,
    this.token,
    this.totalMoneyEarned,
    this.totalTrips,
    this.totalDistanceTravelled,
    // this.driverNativeLocation,
    this.uid,
  });

  bool isOnline;
  String name;
  String ratings;
  double amount;
  bool docsUploaded;
  dynamic profileImage;
  String carType;
  String carNumber;
  String carName;
  String accountCreatedAt;
  bool disableDriver;
  Proofs proofs;
  bool isAdminVerified;
  String phoneNum;
  DriverLocation location;
  String token;
  double totalMoneyEarned;
  int totalTrips;
  double totalDistanceTravelled;

  // DriverNativeLocation driverNativeLocation;
  String uid;

  factory DriverDetails.fromJson(Map<String, dynamic> json) => DriverDetails(
        isOnline: json["isOnline"],
        name: json["name"],
        amount: double.parse(json["amount"].toString()),
        ratings: json["ratings"],
        docsUploaded: json["docsUploaded"],
        profileImage: json["profileImage"],
        carType: json["carType"],
        carNumber: json["carNumber"],
        carName: json["carName"],
        accountCreatedAt: json["accountCreatedAt"],
        disableDriver: json["disableDriver"],
        // proofs: Proofs.fromJson(json["proofs"]),
        isAdminVerified: json["isAdminVerified"],
        phoneNum: json["phoneNum"],
        token: json["token"],
        totalMoneyEarned: json["totalMoneyEarned"],
        totalTrips: json["totalTrips"],
        totalDistanceTravelled: json["totalDistanceTravelled"],
        location: DriverLocation.fromJson(
          json,
        ),
        /* driverNativeLocation:
            DriverNativeLocation.fromJson(json["driverNativeLocation"]), */
        uid: json["uid"],
      );
      //         location: json['position']['geopoint'],


  Map<String, dynamic> toJson() => {
        "isOnline": isOnline,
        "name": name,
        "ratings": ratings,
        "amount": amount,
        "docsUploaded": docsUploaded,
        "profileImage": profileImage,
        "carType": carType,
        "carName": carName,
        "accountCreatedAt": accountCreatedAt,
        "disableDriver": disableDriver,
        "proofs": proofs.toJson(),
        "location": location.toJson(),
        "isAdminVerified": isAdminVerified,
        "phoneNum": phoneNum,
        "token": token,
        "totalMoneyEarned": totalMoneyEarned,
        "totalTrips": totalTrips,
        "totalDistanceTravelled": totalDistanceTravelled,

        // "driverNativeLocation": driverNativeLocation.toJson(),
        "uid": uid,
      };
}

class DriverNativeLocation {
  DriverNativeLocation({
    this.district,
    this.country,
    this.state,
  });

  String district;
  String country;
  String state;

  factory DriverNativeLocation.fromJson(Map<String, dynamic> json) =>
      DriverNativeLocation(
        district: json["district"],
        country: json["country"],
        state: json["state"],
      );

  Map<String, dynamic> toJson() => {
        "district": district,
        "country": country,
        "state": state,
      };
}

class DriverLocation {
  DriverLocation({
    this.latitude,
    this.longitude,
  });

  double latitude;
  double longitude;

  factory DriverLocation.fromJson(Map<String, dynamic> json) => DriverLocation(
        latitude: json["location"].latitude,
        longitude: json["location"].longitude,
      );

  Map<String, dynamic> toJson() => {
        "location": GeoPoint(latitude, longitude),
      };
}

class Proofs {
  Proofs({
    this.createdAt,
    this.userPhone,
    this.rcCopy,
    this.aadharCopy,
    this.insuranceCopy,
    this.dlCopy,
  });

  String createdAt;
  String userPhone;
  String rcCopy;
  String aadharCopy;
  String insuranceCopy;
  String dlCopy;

  factory Proofs.fromJson(Map<String, dynamic> json) => Proofs(
        createdAt: json["created_at"],
        userPhone: json["userPhone"],
        rcCopy: json["rcCopy"],
        aadharCopy: json["aadharCopy"],
        insuranceCopy: json["insuranceCopy"],
        dlCopy: json["dlCopy"],
      );

  Map<String, dynamic> toJson() => {
        "created_at": createdAt.toString(),
        "userPhone": userPhone,
        "rcCopy": rcCopy,
        "aadharCopy": aadharCopy,
        "insuranceCopy": insuranceCopy,
        "dlCopy": dlCopy,
      };
}
