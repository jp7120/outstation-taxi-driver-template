import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/screens/bookingConfirm.dart';
import 'package:driver_app/screens/viewAllDetails.dart';
import 'package:driver_app/maps/movement.dart';
import 'package:driver_app/model/driverDetail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gradients/flutter_gradients.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:driver_app/routes.dart';
import 'package:share/share.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class ConfirmBookingScreen extends StatefulWidget {
  final String estimatedPrice;
  final String estimatedTime;
  final String estimatedDistance;
  final String kmPrice;
  final String type;
  final String trip;
  final String from;
  final String to;
  final String bookedDate;
  final String docId;
  final String noOfDays;
  final BookingInfo bookingInfo;

  const ConfirmBookingScreen({
    Key key,
    this.estimatedPrice,
    this.kmPrice,
    this.type,
    this.trip,
    this.estimatedDistance,
    this.estimatedTime,
    this.from,
    this.to,
    this.bookedDate,
    this.noOfDays,
    this.docId,
    this.bookingInfo,
  }) : super(key: key);

  @override
  _ConfirmBookingScreenState createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  bool loading = false;
  bool isCompleted = false;

  // BasicController basicController;

  String from, to, days;

  DateFormat dateFormat;

  FirebaseUser user;

  TimeOfDay time;

  double minAmount = 200.0;

  getMinAmount() {
    Firestore.instance
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getMinAmount();
    // basicController = Get.put(BasicController());
    // databaseService = DatabaseService();
    if (widget.from != null && widget.to != null) {
      from = widget.from;
      to = widget.to;
    }
    if (widget.bookedDate != null && widget.noOfDays != null) {
      formattedDate = widget.bookedDate;
      days = widget.noOfDays;
    }
  }

  var date;

  var formattedDate = '';

  //? Experimemt this after release

  /* setCurrentInPrefs(BookingInfo bookingInfo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String json = bookingInfoToJson(bookingInfo);
    print(json);

    // prefs.setString(key, value)
  } */

  bool _decideWhichDayToEnable(DateTime day) {
    if ((day.isAfter(DateTime.now().subtract(Duration(days: 1))) &&
        day.isBefore(DateTime.now().add(Duration(days: 30))))) {
      return true;
    }
    return false;
  }

  changeDate() async {
    final localizations = MaterialLocalizations.of(context);
    var formatedTime = '';
    var dates = await showDatePicker(
      selectableDayPredicate: _decideWhichDayToEnable,
      context: context,
      helpText: 'Select date for traveling'.toUpperCase(),
      confirmText: 'Next'.toUpperCase(),
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (dates != null) {
      TimeOfDay selectedTime = await showTimePicker(
        context: context,
        initialTime: _currentTime,
      );
      if (selectedTime != null) {
        setState(() {
          date = dates;
          time = selectedTime;
          formatedTime = localizations.formatTimeOfDay(time);
          formattedDate = DateFormat.yMMMEd().format(date) + " " + formatedTime;
        });
      }
    }
  }

  TimeOfDay _currentTime = new TimeOfDay.now();

  TextEditingController name = new TextEditingController(text: '');
  TextEditingController numberOfDays = new TextEditingController(text: '');

  // String currentDay;
  String currentDay = '1';
  bool isChecked = false;

  BookingInfo currentBooking;
  GlobalKey previewContainer = new GlobalKey();

  SharedPreferences sharedPreferences;

  Firestore _firestore = Firestore.instance;

  BookingInfo updatedData;

  updateBookingInfo(BookingInfo bookingInfo, BuildContext context) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    DriverDetails dr = basicController.getDriver();
    Size screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    var width = screenSize.width;
    var defaultSize = height * 0.05;
    var defaultPadding = 16;

    if (dr.amount < minAmount) {
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
                height: height * 0.2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Kindly recharge your wallet to atleast ${formatPrice(minAmount)} for accepting new rides.',
                      style: sub,
                      textAlign: TextAlign.center,
                    ),
                    RaisedButton.icon(
                      icon: Icon(Icons.add_circle_outline),
                      onPressed: () {
                        if (Navigator.canPop(c)) {
                          Navigator.of(c).pop();
                        }
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddMoneyScreen()));
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
      print(dr.name);
      await _firestore.runTransaction((transaction) async {
        DocumentReference userDocRef = _firestore
            .collection('UserDetails')
            .document(bookingInfo.custUID)
            .collection("bookings")
            .document(bookingInfo.docId);
        DocumentReference bookingDocRef =
            _firestore.collection('BookingDetails').document(bookingInfo.docId);

        await transaction.update(
          userDocRef,
          {
            'driverName': dr.name,
            'driverPhone': dr.phoneNum,
            'carNumber': dr.carNumber,
            'isAssigned': true,
            'driverRatings': dr.ratings,
            'status': 'Not Started',
            'driverUid': dr.uid
            /* 'driverLocation':
              GeoPoint(dr.location.latitude, dr.location.longitude), */
          },
        );
        await transaction.update(
          bookingDocRef,
          {
            'driverName': dr.name,
            'status': 'Not Started',
            'driverPhone': dr.phoneNum,
            'carNumber': dr.carNumber,
            'isAssigned': true,
            'driverRatings': dr.ratings,
            // 'status': 'Driver Accepted',
            'driverUid': dr.uid

            /*  'driverLocation':
              GeoPoint(dr.location.latitude, dr.location.longitude), */
          },
        );

        pref.setString('bookingId', bookingInfo.docId);
        sendSms(bookingInfo, dr);

        basicController.setCurrentBookingInfo(bookingInfo);

        /* Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => RideDetailsPage(
                  bookingInfo: bookingInfo,
                )),
      ); */
        // (route) => false);

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => AcceptedScreen(
                      bookingInfo: bookingInfo,
                    )),
            (route) => false);

        Fluttertoast.showToast(
            msg: 'Successfully Assigned to this Ride',
            backgroundColor: Colors.green,
            textColor: Colors.white);
      });

      print("booking id${bookingInfo.custUID}");
    }
  }

  showAcceptDialog(BuildContext context, BookingInfo bookingInfo) {
    if (bookingInfo.isAssigned == false) {
      showDialog(
          context: context,
          builder: (c) {
            return StreamBuilder<DocumentSnapshot>(
                stream: Firestore.instance
                    .collection('BookingDetails')
                    .document(widget.bookingInfo.docId)
                    .snapshots(),
                builder: (context, snapshot) {
                  // print("status 1" + snapshot.data['isAssigned'].toString());
                  if (snapshot.hasData) {
                    BookingInfo historyList;

                    historyList = BookingInfo.fromJson(snapshot.data.data);
                    print(historyList.custName);

                    var isAssigned = historyList.isAssigned;
                    var status = historyList.status;

                    return StatefulBuilder(builder: (context, snapshot) {
                      return historyList.isAssigned == false
                          ? AlertDialog(
                              backgroundColor: Color(0XFF222222),
                              content: Container(
                                height: Get.height * 0.15,
                                width: Get.width * 0.9,
                                child: Column(
                                  children: [
                                    Text(
                                      'Are you sure to take this order?',
                                      style:
                                          title.copyWith(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    )
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                RaisedButton(
                                  color: Colors.green.shade300,
                                  child: Text(
                                    'ACCEPT',
                                    style: sub.copyWith(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    if (isAssigned == false &&
                                        status.toLowerCase() != 'cancel') {
                                      updateBookingInfo(bookingInfo, context);
                                    } else {
                                      Fluttertoast.showToast(
                                          msg:
                                              "This order is already taken by other driver or Cancelled by the user",
                                          backgroundColor: Colors.redAccent,
                                          textColor: Colors.white,
                                          toastLength: Toast.LENGTH_LONG);
                                      if (Navigator.canPop(context)) {
                                        Navigator.of(context).pop();
                                      }
                                    }
                                  },
                                ),
                                ElevatedButton(
                                  child: Text(
                                    'DECLINE',
                                    style: sub.copyWith(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            )
                          : buildAlertAlreadyTaken(context);
                    });
                  } else {
                    return CircularProgressIndicator();
                  }
                });
          });
    } else {
      showDialog(
          context: context,
          builder: (c) {
            return AlertDialog(
              content: Container(
                height: Get.height * 0.4,
                child: Column(
                  children: [
                    Text(
                      'This booking is already taken by some other driver!',
                      style: title,
                    ),
                    Text(
                      'you cannot take this order',
                      style: sub,
                    ),
                    ElevatedButton(
                      child: Text(
                        'DECLINE',
                        style: sub.copyWith(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            );
          });
    }
  }

  AlertDialog buildAlertAlreadyTaken(var c) {
    return AlertDialog(
      content: Container(
        height: Get.height * 0.2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'This booking is already taken by some other driver!',
              style: title,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'you cannot take this order',
              style: sub,
            ),
            ElevatedButton(
              child: Text(
                'Close',
                style: sub.copyWith(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(c).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  sendSms(BookingInfo book, DriverDetails driver) async {
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
        "Your Trip From\n${book.from} has been Confirmed.\nDRIVER DETAILS\nName: ${driver.name}\nPhone: ${driver.phoneNum}\nCar: ${driver.carName} - ${driver.carNumber}";

    var numb = book.custPhone;
    var customMsgUrl =
        "https://www.fast2sms.com/dev/bulk?authorization=$authorization&sender_id=FSTSMS&message=$msg&language=english&route=p&numbers=$numb";

    var res = await http.get(customMsgUrl);
    print(res.body);
  }

  BasicController basicController = Get.put(BasicController());

  @override
  Widget build(BuildContext context) {
    // print(widget.fromLoc.lat);
    // setCurrentInPrefs(widget.bookingInfo);

    Size screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    var width = screenSize.width;
    var defaultSize = height * 0.05;
    var defaultPadding = 16;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      /*  floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton.extended(
            heroTag: 'fire',
            onPressed: () {
              /* Firestore.instance
                  .collection("BookingDetails")
                  .document(widget.docId)
                  .updateData({'sendToDriver': true}).then((value) {
                Fluttertoast.showToast(
                    msg: "Details sent to driver app via Notification");
                Navigator.of(context).pop();
              }); */
              updateBookingInfo(widget.bookingInfo, screenSize);
            },
            backgroundColor: Constants.primaryColor,
            label: Text(
              'Accept Ride',
              style: title.copyWith(color: Colors.white),
            ),
            icon: Icon(
              Icons.check_circle_outline,
              color: Colors.white,
            ),
          ),
        ],
      ), */
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance
              .collection('BookingDetails')
              .document(widget.bookingInfo.docId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              BookingInfo bookingInfo =
                  BookingInfo.fromJson(snapshot.data.data);

              print(bookingInfo.isAssigned);

              var isAssigned = bookingInfo.isAssigned;
              var status = bookingInfo.status;

              return isAssigned == false && status.toLowerCase() != 'cancel'
                  ? SingleChildScrollView(
                      child: Container(
                        decoration: BoxDecoration(
                            // gradient: FlutterGradients.northMiracle(tileMode: TileMode.clamp),
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.all(8),
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: defaultSize * 0.5),
                            RepaintBoundary(
                              key: previewContainer,
                              child: Container(
                                child: Card(
                                  elevation: 5,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        /*  gradient: FlutterGradients.itmeoBranding(
                                  tileMode: TileMode.clamp), */
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    padding: EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'From',
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.clip,
                                          style: sub.copyWith(
                                              color: Colors.black54),
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Image.asset(
                                              'assets/images/locPin.png',
                                              height: 30,
                                              width: 30,
                                            ),
                                            Expanded(
                                              child: Text(
                                                '$from',
                                                style: title.copyWith(
                                                    fontSize: 16),
                                                // maxLines: 5,
                                                textAlign: TextAlign.start,
                                                overflow: TextOverflow.clip,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'To',
                                          textAlign: TextAlign.start,
                                          style: sub.copyWith(
                                              color: Colors.black54),
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Image.asset(
                                              'assets/images/locPinTO.png',
                                              height: 30,
                                              width: 30,
                                            ),
                                            Expanded(
                                              child: Text(
                                                '$to',
                                                style: title.copyWith(
                                                    fontSize: 16),
                                                // maxLines: 2,
                                                textAlign: TextAlign.start,
                                                overflow: TextOverflow.clip,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: defaultSize * 0.7),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Column(
                                              children: <Widget>[
                                                Image.asset(
                                                  'assets/images/${widget.type.trim().toLowerCase()}.png',
                                                  height: 100,
                                                  width: 100,
                                                ),
                                                Text(
                                                  '${widget.type}',
                                                  style: sub,
                                                ),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                SizedBox(
                                                    height: defaultSize * 0.7),
                                                Image.asset(
                                                  widget.trip == 'One Way Trip'
                                                      ? 'assets/images/oneway.png'
                                                      : 'assets/images/twoway.png',
                                                  height: 50,
                                                  width: 50,
                                                ),
                                                SizedBox(
                                                    height: defaultSize * 0.5),
                                                Text(
                                                  '${widget.trip}',
                                                  style: sub,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: defaultSize * 0.5),
                                        // Text('')
                                        Material(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          elevation: 10,
                                          child: Container(
                                            width: width,
                                            decoration: BoxDecoration(
                                                gradient: FlutterGradients
                                                    .temptingAzure(),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            height: height * 0.1,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  'Total Distance : \n${widget.estimatedDistance} Kms.',
                                                  style: title.copyWith(
                                                      fontSize: 11),
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                SizedBox(width: defaultSize),
                                                Text(
                                                  'Traveling Time(min) : \n${widget.estimatedTime}',
                                                  style: title.copyWith(
                                                      fontSize: 11),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: defaultSize * 0.5),
                                        Center(
                                          child: RaisedButton.icon(
                                            onPressed: () {
                                              /* Firestore.instance
                  .collection("BookingDetails")
                  .document(widget.docId)
                  .updateData({'sendToDriver': true}).then((value) {
                Fluttertoast.showToast(
                    msg: "Details sent to driver app via Notification");
                Navigator.of(context).pop();
              }); */
                                              /*   updateBookingInfo(
                                                  widget.bookingInfo,
                                                  screenSize); */

                                              showAcceptDialog(
                                                  context, bookingInfo);
                                            },
                                            color: Constants.primaryColor,
                                            label: Text(
                                              'Accept Ride',
                                              style: title.copyWith(
                                                  color: Colors.white),
                                            ),
                                            icon: Icon(
                                              Icons.check_circle_outline,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),

                                        SizedBox(height: defaultSize * 0.5),
                                        Card(
                                          color: Colors.yellow,
                                          elevation: 10,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30)),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                gradient: FlutterGradients
                                                    .northMiracle(),
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            padding: EdgeInsets.all(20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  'Estimation Fare : ',
                                                  style: title.copyWith(
                                                      color: Colors.white,
                                                      fontSize: 15),
                                                ),
                                                Text(
                                                  '${formatPrice(double.parse(widget.estimatedPrice))}',
                                                  style: title.copyWith(
                                                      color: Colors.white,
                                                      fontSize: 15),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        //₹400
                                        SizedBox(height: defaultSize),
                                        Center(
                                          child: Container(
                                            height: height * 0.07,
                                            child: Text(
                                              formattedDate,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  title.copyWith(fontSize: 20),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),

                                        SizedBox(height: defaultSize * 0.0),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            widget.trip == 'One Way Trip'
                                                ? Container()
                                                : Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                        height: height * 0.1,
                                                        child: Column(
                                                          children: <Widget>[
                                                            Text(
                                                              'Number of days : $days',
                                                              style: sub,
                                                            )
                                                          ],
                                                        )),
                                                  )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: defaultSize * 0.7),
                            SizedBox(height: defaultSize * 1.2),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'This booking have taken by someother driver or Cancelled by the user.',
                            style: title,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Please check if there\'s any new booking',
                            style: sub,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
