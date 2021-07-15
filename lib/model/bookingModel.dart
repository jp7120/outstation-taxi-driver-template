// To parse this JSON data, do
//
//     final bookingInfo = bookingInfoFromJson(jsonString);

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

BookingInfo bookingInfoFromJson(String str) =>
    BookingInfo.fromJson(json.decode(str));

String bookingInfoToJson(BookingInfo data) => json.encode(data.toJson());

class BookingInfo {
  BookingInfo({
    this.from,
    this.fromLoc,
    this.driverLoc,
    this.carNumber,
    this.driverRatings,
    this.toLoc,
    this.trip,
    this.days,
    this.docId,
    this.carType,
    this.estimatedDistance,
    this.sendToDriver,
    this.sendToAll,
    this.kmPrice,
    this.to,
    this.isAssigned,
    this.isCompleted,
    this.assignedTo,
    this.bookedTime,
    this.createdAt,
    this.custName,
    this.custPhone,
    this.custUID,
    this.currentLoc,
    this.totalAmount,
    this.totalAmountCalculated,
    this.totalTravelingTime,
    this.totalDistance,
    this.status,
    this.driverName,
    this.driverPhone,
    this.otp,
  });

  final String from;
  final GeoPoint fromLoc;
  final GeoPoint toLoc;
  final String to;
  final String trip;
  final bool isAssigned;
  final bool isCompleted;
  var sendToDriver;
  final bool sendToAll;
  final String docId;
  final String assignedTo;
  final String bookedTime;
  final String createdAt;
  final String custName;
  final String custPhone;
  final String custUID;
  final String currentLoc;
  final String estimatedDistance;
  final String carType;
  final String carNumber;
  final String kmPrice;
  final String days;
  final String totalAmount;
  String totalAmountCalculated;
  final String totalTravelingTime;
  final String totalDistance;
  final String status;
  final String driverName;
  final String driverPhone;
  final String driverRatings;
  final GeoPoint driverLoc;
  final String otp;

  factory BookingInfo.fromJson(Map<String, dynamic> json) => BookingInfo(
        from: json["from"].toString(),
        to: json["to"].toString(),
        isAssigned: json["isAssigned"],
        isCompleted: json["isCompleted"],
        sendToDriver: json["sendToDriver"].toString(),
        sendToAll: json["sendToAll"],
        assignedTo: json["assignedTo"].toString(),
        bookedTime: json["bookedTime"].toString(),
        createdAt: json["createdAt"].toString(),
        fromLoc: json['fromLoc'],
        toLoc: json['toLoc'],
        custName: json["custName"].toString(),
        kmPrice: json['kmPrice'].toString(),
        days: json['days'].toString(),
        estimatedDistance: json['estimatedDistance'].toString(),
        custPhone: json["custPhone"].toString(),
        custUID: json["custUID"].toString(),
        carType: json["carType"].toString(),
        currentLoc: json["currentLoc"].toString(),
        totalAmount: json["totalAmount"].toString(),
        totalAmountCalculated: json["totalAmountCalculated"].toString(),
        totalTravelingTime: json["totalTravelingTime"].toString(),
        totalDistance: json["totalDistance"].toString(),
        carNumber: json["carNumber"].toString(),
        docId: json["docId"].toString(),
        driverRatings: json["driverRatings"].toString(),
        trip: json["trip"].toString(),
        status: json["status"].toString(),
        driverName: json["driverName"].toString(),
        driverPhone: json["driverPhone"].toString(),
        driverLoc: json["driverLoc"],
        otp: json["otp"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "from": from,
        "fromLoc": fromLoc,
        "toLoc": toLoc,
        "to": to,
        "isAssigned": isAssigned,
        "isCompleted": isCompleted,
        "sendToDriver": sendToDriver,
        "sendToAll": sendToAll,
        "assignedTo": assignedTo,
        "bookedTime": bookedTime,
        "createdAt": createdAt,
        "custName": custName,
        "custPhone": custPhone,
        "custUID": custUID,
        "currentLoc": currentLoc,
        "carType": carType,
        "estimatedDistance": estimatedDistance,
        "kmPrice": kmPrice,
        "trip": trip,
        "days": days,
        "carNumber": carNumber,
        "docId": docId,
        "driverRatings": driverRatings,
        "totalAmount": totalAmount,
        "totalAmountCalculated": totalAmountCalculated,
        "totalTravelingTime": totalTravelingTime,
        "totalDistance": totalDistance,
        "status": status,
        "driverName": driverName,
        "driverPhone": driverPhone,
        "driverLoc": driverLoc,
        "otp": otp,
      };
}
