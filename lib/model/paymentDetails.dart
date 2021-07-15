// To parse this JSON data, do
//
//     final payment = paymentFromJson(jsonString);

import 'dart:convert';

Payment paymentFromJson(String str) => Payment.fromJson(json.decode(str));

String paymentToJson(Payment data) => json.encode(data.toJson());

class Payment {
  Payment({
    this.paymentId,
    this.upiTransId,
    this.transactionReference,
    this.paymentThru,
    this.createdAt,
    this.driverUid,
    this.timestamp,
    this.driverName,
    this.driverPhone,
    this.prevBalance,
    this.amountAdded,
    this.totalAmount,
    this.status,
    this.errorMsg,
    this.transactionRefId,
  });

  String paymentId;
  String upiTransId;
  String transactionReference;
  String paymentThru;
  String createdAt;
  String driverUid;
  dynamic timestamp;
  String driverName;
  String driverPhone;
  String prevBalance;
  String amountAdded;
  String totalAmount;
  String status;
  String errorMsg;
  String transactionRefId;

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        paymentId: json["paymentID"],
        upiTransId: json["upiTransId"],
        transactionReference: json["transactionReference"],
        paymentThru: json["paymentThru"],
        createdAt: json["createdAt"],
        driverUid: json["driverUID"],
        timestamp: json["timestamp"],
        driverName: json["driverName"],
        driverPhone: json["driverPhone"],
        prevBalance: json["prevBalance"],
        amountAdded: json["amountAdded"],
        totalAmount: json["totalAmount"],
        status: json["status"],
        errorMsg: json["errorMsg"],
        transactionRefId: json["transactionRefID"],
      );

  Map<String, dynamic> toJson() => {
        "paymentID": paymentId,
        "upiTransId": upiTransId,
        "transactionReference": transactionReference,
        "paymentThru": paymentThru,
        "createdAt": createdAt,
        "driverUID": driverUid,
        "timestamp": timestamp,
        "driverName": driverName,
        "driverPhone": driverPhone,
        "prevBalance": prevBalance,
        "amountAdded": amountAdded,
        "totalAmount": totalAmount,
        "status": status,
        "transactionRefID": transactionRefId,
        "errorMsg": errorMsg,
      };
}
