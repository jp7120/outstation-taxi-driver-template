import 'dart:convert';

PriceDetails priceDetailsFromJson(String str) =>
    PriceDetails.fromJson(json.decode(str));

String priceDetailsToJson(PriceDetails data) => json.encode(data.toJson());

class PriceDetails {
  PriceDetails(
      {this.oneWayHatch,
      this.oneWaySedan,
      this.oneWaySuv,
      this.roundHatch,
      this.roundSedan,
      this.roundSuv,
      this.isTaxable,
      this.driverComission,
      this.driverBataOneWay,
      this.driverBataSUVOne,
      this.driverBataSUVRound,
      this.driverBataRound,
      this.miniBal,
      this.driverBataAddtional});

  String oneWayHatch;
  String oneWaySedan;
  String oneWaySuv;
  String roundHatch;
  String roundSedan;
  String driverComission;
  String roundSuv;
  bool isTaxable;
  String driverBataOneWay;
  String driverBataSUVOne;
  String driverBataRound;
  String driverBataSUVRound;
  String driverBataAddtional;
  String miniBal;

  factory PriceDetails.fromJson(Map<String, dynamic> json) => PriceDetails(
        oneWayHatch: json["oneWayHatch"],
        oneWaySedan: json["oneWaySedan"],
        oneWaySuv: json["oneWaySUV"],
        roundHatch: json["roundHatch"],
        roundSedan: json["roundSedan"],
        roundSuv: json["roundSUV"],
        isTaxable: json["isTaxable"],
        driverComission: json["driverComission"],
        driverBataOneWay: json["driverBataOneWay"],
        driverBataSUVOne: json["driverBataSUVOneWay"],
        driverBataSUVRound: json["driverBataSUVRound"],
        driverBataRound: json["driverBataRound"],
        driverBataAddtional: json["driverBataMax"],
        miniBal: json["miniBal"],
      );

  Map<String, dynamic> toJson() => {
        "oneWayHatch": oneWayHatch,
        "oneWaySedan": oneWaySedan,
        "oneWaySUV": oneWaySuv,
        "roundHatch": roundHatch,
        "roundSedan": roundSedan,
        "roundSUV": roundSuv,
        "isTaxable": isTaxable,
        "driverComission": driverComission,
        "driverBataOneWay": driverBataOneWay,
        "driverBataSUVOneWay": driverBataSUVOne,
        "driverBataRound": driverBataRound,
        "driverBataSUVRound": driverBataSUVRound,
        "miniBal": miniBal,
        "driverBataMax": driverBataAddtional
      };
}
