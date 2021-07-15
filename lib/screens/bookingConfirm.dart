import 'package:driver_app/constants.dart';
import 'package:driver_app/maps/movement.dart';
import 'package:driver_app/model/bookingModel.dart';
import 'package:driver_app/model/driverDetail.dart';
import 'package:driver_app/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gradients/flutter_gradients.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:driver_app/maps/openGmapDrirection.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

class AcceptedScreen extends StatefulWidget {
  final BookingInfo bookingInfo;

  const AcceptedScreen({Key key, this.bookingInfo}) : super(key: key);

  @override
  _AcceptedScreenState createState() => _AcceptedScreenState();
}

class _AcceptedScreenState extends State<AcceptedScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLoc();
    getMinAmount();
  }

  LatLng currentLoc;

  DriverDetails driver;

  BasicController basicController = Get.put(BasicController());

  getCurrentLoc() async {
    await Location.instance.getLocation().then((value) {
      if (mounted)
        setState(() {
          currentLoc = LatLng(value.latitude, value.longitude);
          driver = basicController.getDriver();
        });
    });
    print(driver.name);
  }

  sendSms(BookingInfo book, DriverDetails drivers) async {
    ///* change bulkV2 to bulk
    ///* send id FSTSMS
    ///
    ///V2 Custom Message
    ///

    var authorization = Constants.SMS_API_KEY;

    // var finalAmount = formatPrice(double.parse(amount));

    var rs = '%E2%82%B9';

    // var msg = "Your OTP is ${otp.toString()}. Thank you for registering! ";
    var msg =
        "Your Trip From\n${book.from} has been Confirmed.\nDrivers details\nName: ${driver.name}\nPhone: ${driver.phoneNum}\nCar: ${driver.carName} - ${driver.carNumber}";

    var numb = book.custPhone;
    var customMsgUrl =
        "https://www.fast2sms.com/dev/bulk?authorization=$authorization&sender_id=FSTSMS&message=$msg&language=english&route=p&numbers=$numb";

    var res = await get(customMsgUrl);
    print(res.body);
  }

  @override
  Widget build(BuildContext context) {
    String customerName = '${widget.bookingInfo.custName}';
    // getCurrentLoc();
    String customerPhone = '${widget.bookingInfo.custPhone}';
    String custLocation = "${widget.bookingInfo.from}";

    LatLng custLatLng = LatLng(widget.bookingInfo.fromLoc.latitude,
        widget.bookingInfo.fromLoc.longitude);

    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text(
            // "Booking Confirmation",
            'Status',
            style: title.copyWith(color: Colors.white),
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => DriverHomeScreen()));
                })
          ],
          centerTitle: true,
          backgroundColor: Constants.primaryDark,
        ),
        body: SingleChildScrollView(
          child: Container(
            height: size.height,
            width: size.width,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.checkCircle,
                      size: size.height * 0.15, color: Colors.greenAccent),
                  SizedBox(
                    height: size.height * 0.04,
                  ),
                  Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: size.height * 0.07,
                      width: size.width * 0.9,
                      decoration: BoxDecoration(
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.circular(5)),
                      child: Center(
                        child: Text(
                          "Booking Confirmed".toUpperCase(),
                          style: title.copyWith(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.04,
                  ),
                  Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: size.height * 0.45,
                      width: size.width * 0.9,
                      decoration: BoxDecoration(
                          // gradient: FlutterGradients.aquaGuidance(),
                          color: Colors.greenAccent,
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "User Name :  ",
                                    style: title.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: size.height * 0.025,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    "${customerName}",
                                    style: title.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: size.height * 0.025,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: size.height * 0.015,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "User Phone :",
                                    style: title.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: size.height * 0.025,
                                        color: Colors.white),
                                  ),
                                  Text(
                                    "$customerPhone",
                                    style: title.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: size.height * 0.025,
                                        color: Colors.white),
                                  ),
                                  IconButton(
                                      icon: Icon(Icons.call),
                                      onPressed: () async {
                                        if (customerPhone != null &&
                                            customerPhone.length >= 10)
                                          launch("tel://$customerPhone");
                                      })
                                ],
                              ),
                              SizedBox(
                                height: size.height * 0.055,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                // crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    // padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                        // color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: Text(
                                      "Pick up location : ",
                                      style: title.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: size.height * 0.025,
                                          color: Colors.black),
                                    ),
                                  ),
                                  SizedBox(
                                    height: size.height * 0.025,
                                  ),
                                  Text(
                                    "$custLocation",
                                    maxLines: 4,
                                    textAlign: TextAlign.center,
                                    style: title.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: size.height * 0.025,
                                        color: Colors.white),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: size.height * 0.03,
                              ),
                              Center(
                                child: InkWell(
                                  onTap: () {
                                    // openGoogleMapDirection(
                                    //     currentLoc, custLatLng);
                                    launch(
                                        "google.navigation:q=${custLatLng.latitude},${custLatLng.longitude}");
                                  },
                                  child: Container(
                                    height: size.height * 0.06,
                                    width: size.width * 0.6,
                                    decoration: BoxDecoration(
                                        gradient:
                                            FlutterGradients.coldEvening(),
                                        borderRadius:
                                            BorderRadius.circular(25)),
                                    child: Center(
                                        child: Text(
                                      "Go to customer location",
                                      textAlign: TextAlign.center,
                                      style: title.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.white),
                                    )),
                                  ),
                                ),
                              )
                            ],
                          )),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  Center(
                    child: InkWell(
                      onTap: () {
                        // sendSms(widget.bookingInfo, driver);
                        showAcceptDialog(size);
                      },
                      child: Container(
                        height: size.height * 0.06,
                        width: size.width * 0.6,
                        decoration: BoxDecoration(
                            gradient: FlutterGradients.loveKiss(),
                            borderRadius: BorderRadius.circular(25)),
                        child: Center(
                            child: Text(
                          "Start Ride",
                          style: title.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: size.height * 0.023,
                              color: Colors.white),
                        )),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ));
  }

  double minAmount;

  getMinAmount() async {
    await Firestore.instance
        .collection("carPrices")
        .document('allPrice')
        .get()
        .then((value) {
      setState(() {
        minAmount = double.parse(value['miniBal'].toString());
      });

      print('as' + minAmount.toString());
    });
  }

  showAcceptDialog(Size size) {
    return showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            // backgroundColor: Colors.redAccent,
            title: Text(
              'Accept this current ride?',
              style: title.copyWith(color: Colors.black),
              textAlign: TextAlign.center,
            ),
            content: Container(
              height: size.height * 0.3,
              width: size.width * 0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    '1. Are you in the customer location?',
                    style: sub.copyWith(color: Colors.black),
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    '2. Once you click Accept, the ride will start.',
                    style: sub.copyWith(
                      color: Colors.black,
                      wordSpacing: 2,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    '3. After accepting the ride, you cannot go back!',
                    style: sub.copyWith(color: Colors.black),
                    textAlign: TextAlign.start,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                        onPressed: () async {
                          print(" min $minAmount dr amt ${driver.amount}");

                          if (Navigator.canPop(c)) {
                            Navigator.of(c).pop();
                          }

                          if (driver.amount < minAmount) {
                            print(driver.amount > minAmount);
                            await showDialog(
                                context: context,
                                builder: (c) {
                                  return AlertDialog(
                                    title: Text(
                                      'You have low balance in your wallet.',
                                      style: title,
                                      textAlign: TextAlign.center,
                                    ),
                                    content: Container(
                                      height: Get.height * 0.2,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            'Kindly recharge your wallet to atleast ${formatPrice(minAmount)} for accepting new rides.',
                                            style: sub,
                                            textAlign: TextAlign.center,
                                          ),
                                          RaisedButton.icon(
                                            icon:
                                                Icon(Icons.add_circle_outline),
                                            onPressed: () {
                                              if (Navigator.canPop(c)) {
                                                Navigator.of(c).pop();
                                              }
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          AddMoneyScreen()));
                                            },
                                            label: Text(
                                              'Recharge',
                                              style: title,
                                            ),
                                            color: Colors.greenAccent,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          } else {
                            await Firestore.instance
                                .collection("BookingDetails")
                                .document(widget.bookingInfo.docId)
                                .updateData({
                              'isAssigned': true,
                              'status': 'Started'
                            }).then((value) {
                              print(
                                  'updatd success' + widget.bookingInfo.docId);
                            });
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RidingMode(
                                          info: widget.bookingInfo,
                                        )));
                          }
                        },
                        child: Text(
                          'Accept',
                          style: title,
                        ),
                        color: Colors.greenAccent,
                      ),
                      RaisedButton(
                        onPressed: () {
                          Navigator.of(c).pop();
                        },
                        child: Text(
                          'Decline',
                          style: title.copyWith(color: Colors.white),
                        ),
                        color: Colors.redAccent,
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
