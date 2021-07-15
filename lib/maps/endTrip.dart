import 'package:driver_app/screens/addMoney.dart';
import 'package:driver_app/screens/myRides.dart';
import 'package:driver_app/model/bookingModel.dart';
import 'package:driver_app/model/driverDetail.dart';
import 'package:driver_app/notification/setup.dart';
import 'package:driver_app/routes.dart';
import 'package:driver_app/widgets/customButton.dart';
import 'package:driver_app/widgets/money.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class EndTrip extends StatefulWidget {
  final String finalAmount;
  final double totalDist;
  final String taxAmount;
  final BookingInfo bookInfo;
  final double commisionAmt;
  final int days;
  final double driverBata;

  const EndTrip(
      {Key key,
      this.finalAmount,
      this.bookInfo,
      this.totalDist,
      this.taxAmount,
      this.days,
      this.driverBata,
      this.commisionAmt})
      : super(key: key);
  @override
  _EndTripState createState() => _EndTripState();
}

class _EndTripState extends State<EndTrip> {
  BasicController basicController = Get.put(BasicController());

  showAlert() async {
    DriverDetails dr = basicController.getDriver();

    Size screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    var width = screenSize.width;
    var defaultSize = height * 0.05;
    var defaultPadding = 16;
    var current = dr.amount -
        ((widget.commisionAmt ?? 0.0) - double.parse(widget.taxAmount));
    print(current);
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              height: height * 0.45,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Previous Wallet Balance:\n${formatPrice(dr.amount)}',
                      style: title,
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: defaultSize),
                    Text(
                      'Commision Amount:\n${formatPrice(widget.commisionAmt != null ? widget.commisionAmt : 0.0)} ',
                      style: title,
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: defaultSize),
                    Text(
                      'Current Wallet Balance:\n${formatPrice(current)}',
                      style: title,
                      textAlign: TextAlign.start,
                    ),

                    // Text('Days: $currentDays')
                    SizedBox(height: defaultSize * 1),

                    Center(
                      child: Container(
                        width: 100,
                        child: CustomButton(
                            title: 'OKAY'.toUpperCase(),
                            isIcon: false,
                            color: Colors.redAccent.shade700,
                            context: context,
                            onPressed: () async {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DriverHomeScreen()),
                                  // );
                                  (route) => false);
                            }),
                      ),
                    )
                  ]),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    var width = screenSize.width;
    var defaultSize = height * 0.05;
    var defaultPadding = 16;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: height,
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 120,
                    backgroundImage: AssetImage("assets/images/success.jpg"),
                  ),
                ),
                Center(
                  child: Text(
                    'Your Ride has been Completed!',
                    textAlign: TextAlign.center,
                    style: sub.copyWith(fontSize: 20),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total KM Travelled :',
                      style: sub.copyWith(fontSize: 17),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      ' ${widget.totalDist.toStringAsFixed(2)} Kms',
                      style: title,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Category :',
                      style: sub.copyWith(fontSize: 17),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      ' ${widget.bookInfo.carType}',
                      style: title,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Driver Bata :',
                      style: sub.copyWith(fontSize: 17),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      "${formatPrice(widget.driverBata)}",
                      style: title,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'KM Price :',
                      style: sub.copyWith(fontSize: 17),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      "${formatPrice(double.parse(widget.bookInfo.kmPrice))}",
                      style: title,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'GST 5%',
                      style: sub.copyWith(fontSize: 17),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      "${formatPrice(double.parse(widget.taxAmount == null ? '0' : widget.taxAmount))}",
                      style: title,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Payable Amount :',
                      style: sub.copyWith(fontSize: 17),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      ' ${formatPrice(double.parse(widget.finalAmount))}',
                      style: title,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
                CustomButton(
                  color: Colors.greenAccent.shade700,
                  context: context,
                  title: 'End this ride',
                  onPressed: () {
                    showAlert();
                    // basicController.setCurrentBookingInfo(null);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
