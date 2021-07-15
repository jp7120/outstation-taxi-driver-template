import 'dart:async';
import 'dart:math' show acos, asin, cos, pi, sin, sqrt;
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/model/driverDetail.dart';
import 'package:driver_app/model/priceDetails.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

import '../routes.dart';
import 'endTrip.dart';
import 'timer.dart';

class RidingMode extends StatefulWidget {
  final BookingInfo info;

  RidingMode({
    Key key,
    this.info,
  }) : super(key: key);

  @override
  _RidingModeState createState() => _RidingModeState();
}

class _RidingModeState extends State<RidingMode> {
  StreamSubscription _locationSubscription;
  // Location _locationTracker = Location();

  Timer _timer;

  Set<Marker> _markers = {};
  LatLng myLocation;

  Completer<GoogleMapController> _controllerC = Completer();
  GoogleMapController moveCameraController;
  bool isMapCreated = false;
  final Key _mapKey = UniqueKey();
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  BitmapDescriptor _mylocation;

  LatLng checkLoc;

  double driverBata = 0.0;

  setDriverBata() {
    if (priceDetails != null) {
      if (widget.info.trip == 'One Way Trip') {
        miniKM = 130;
        // print('one way');
        if (widget.info.carType == 'Hatchback' ||
            widget.info.carType == 'Sedan') {
          setState(() {
            driverBata = double.parse(priceDetails.driverBataOneWay) *
                double.parse(widget.info.days);
            onlyDriverBata = double.parse(priceDetails.driverBataOneWay);
          });
        } else if (widget.info.carType == 'SUV') {
          setState(() {
            driverBata = double.parse(priceDetails.driverBataSUVOne) *
                double.parse(widget.info.days);
            onlyDriverBata = double.parse(priceDetails.driverBataSUVOne);
          });
        }
      } else {
        miniKM = 300;
        // print('Round');
        if (widget.info.carType == 'Hatchback' ||
            widget.info.carType == 'Sedan') {
          setState(() {
            driverBata = double.parse(priceDetails.driverBataRound) *
                double.parse(widget.info.days);
            onlyDriverBata = double.parse(priceDetails.driverBataRound);
          });
        } else if (widget.info.carType == 'SUV') {
          setState(() {
            driverBata = double.parse(priceDetails.driverBataSUVRound) *
                double.parse(widget.info.days);
            onlyDriverBata = double.parse(priceDetails.driverBataSUVRound);
          });
        }
      }
    }
  }

  int taxPercent = 5;
  int commissionPercent = 10;
  PriceDetails priceDetails;

  int minimumKM;

  getTaxPercent() async {
    await Firestore.instance
        .collection("carPrices")
        .document('allPrice')
        .get()
        .then((value) {
      if (value['isTaxable'] == true) {
        setState(() {
          taxPercent = 5;
          priceDetails = PriceDetails.fromJson(value.data);
        });
      } else {
        setState(() {
          priceDetails = PriceDetails.fromJson(value.data);
          taxPercent = 0;
        });
      }

      commissionPercent = int.parse(priceDetails.driverComission);
      print("Commision : $commissionPercent");

      setDriverBata();

      print('as' + taxPercent.toString());
    });
  }

  @override
  void initState() {
    super.initState();
    // getMyLocationBest();
    getTaxPercent();
    currentDays = widget.info.days;

    startTime.stopwatch.start();

    getCurrStreamLoc();
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(
              devicePixelRatio: 1.5,
              size: Size(5, 5),
            ),
            'assets/images/car_icon.png')
        .then((onValue) {
      _mylocation = onValue;
    });

    myLocation =
        LatLng(widget.info.fromLoc.latitude, widget.info.fromLoc.longitude);
    checkLoc = LatLng(widget.info.toLoc.latitude, widget.info.toLoc.longitude);
    _moveCamera(myLocation, checkLoc);
    // getPrevLoc();
  }

  Future<bool> _willPopCallback() async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'You cannot go back until you finish this ride!',
              style: title,
            ),
            actions: [
              Container(
                width: 100,
                child: CustomButton(
                  title: 'Okay'.toUpperCase(),
                  isIcon: false,
                  color: Colors.greenAccent.shade700,
                  context: context,
                  onPressed: () {
                    Navigator.of(context).pop();
                    return false;
                  },
                ),
              )
            ],
          );
        });

    return false;

    // return true if the route to be popped
  }

  Marker marker;

  Circle circle;
  GoogleMapController _controller;

  var currentAddressNew = '';

  Position _position;
  Position position;

  double latitude, long;

  String _currentAddress = "";

  String _googleMapLink = '';
  String shortAddress = 'loading...';

  double onlyDriverBata = 1.0;

  static var initPos = LatLng(15.2602, 79.1461);
  static var fromSNS = LatLng(11.100, 77.0266);

  static final CameraPosition initialLocation = CameraPosition(
    target: initPos,
    zoom: 5.5,
  );

  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/images/car_icon.png");
    return byteData.buffer.asUint8List();
  }

  void updateMarkerAndCircle(Position newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);

    // check whether the state object is in tree

    //print('IN UPDATE $latlng');

    _controller.animateCamera(CameraUpdate.newCameraPosition(new CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(newLocalData.latitude, newLocalData.longitude),
        tilt: 0,
        zoom: 13)));

    _markers.add(Marker(
        markerId: MarkerId("home"),
        position: latlng,
        rotation: newLocalData.heading,
        draggable: false,
        zIndex: 2,
        infoWindow: InfoWindow(
            snippet: 'Driver', title: widget.info.driverName, onTap: () {}),
        visible: true,
        flat: true,
        anchor: Offset(0.5, 0.5),
        icon: _mylocation));
    circle = Circle(
        circleId: CircleId("car"),
        radius: newLocalData.accuracy,
        zIndex: 1,
        strokeColor: Colors.blue,
        center: latlng,
        fillColor: Colors.blue.withAlpha(70));
  }

  // var distance;
  /* 
    calculateDistance(var from, var to) async {
      //Calculate distance between two places for now
      /******IMPLEMENT THE VALIDATION FOR ONLY SELECTED LOCATIONS */
      double distanceL = await Geolocator().distanceBetween(
          from.latitude, from.longitude, to.latitude, to.longitude);
      if(mounted) setState(() {
        distance = (distanceL / 1000).toStringAsFixed(3);
      });
      Fluttertoast.showToast(
          msg:
              "Distance Between From College To Current Location is $distance Kms.",
          toastLength: Toast.LENGTH_LONG);
    } */
  double distance(
      double lat1, double lon1, double lat2, double lon2, String unit) {
    double theta = lon1 - lon2;
    double dist = sin(deg2rad(lat1)) * sin(deg2rad(lat2)) +
        cos(deg2rad(lat1)) * cos(deg2rad(lat2)) * cos(deg2rad(theta));

    print("LAFA" + lat1.toString());
    print("LAFAas" + lat2.toString());
    dist = acos(dist);
    dist = rad2deg(dist);
    dist = dist * 60 * 1.1515;
    if (unit == 'K') {
      dist = dist * 1.609344;
    } else if (unit == 'N') {
      dist = dist * 0.8684;
    }
    print("aasda" + dist.toString());
    return dist;
  }

  double deg2rad(double deg) {
    return (deg * pi / 180.0);
  }

  double rad2deg(double rad) {
    return (rad * 180.0 / pi);
  }

  setCurrentLocationDatabase(Position locationData) async {
    var lat = locationData.latitude;
    var long = locationData.longitude;
    var speed = locationData.speed;
    var alti = locationData.altitude;
    //var times = locationData.time;
    var time = DateTime.now();
    var ref = FirebaseDatabase.instance.reference();

    print('total dis' + _totalDistance.toString());

    await ref.child('Rajesh').update({
      'lat': lat,
      'long': long,
      // 'newTotal':
      //'altitude': alti,
      //'speed': speed,
      // 'updated_at': time.toString()
    });
  }

  Uint8List imageData;
  var toAddr;

  /*   Future<void> getMyLocationBest() async {
      imageData = await getMarker();
      try {
        position = await Geolocator()
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        myLocation = LatLng(position.latitude, position.longitude);

        List<Placemark> p = await Geolocator()
            .placemarkFromCoordinates(position.latitude, position.longitude);

        Placemark place = p[0];

        final coordinates =
            new Coordinates(position.latitude, position.longitude);
        var addresses =
            await Geocoder.local.findAddressesFromCoordinates(coordinates);
        var first = addresses.first;

        var mapUrl;

        if (mounted)
          setState(() {
            _currentAddress =
                "${place.subThoroughfare} ${place.thoroughfare}, ${place.subAdministrativeArea}, ${place.locality}, ${place.administrativeArea}, ${place.country}, ${place.postalCode}.";

            shortAddress =
                " ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.country}.";

            currentAddressNew = "${first.addressLine}";

            _position = position;

            mapUrl =
                //'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
                "https://maps.google.com?q=${position.latitude},${position.longitude}";
          });
        // LatLng currLatLng = new LatLng(11.0803562, 76.9938492);
        // LatLng org = new LatLng(11.033263, 76.967240);

        print(mapUrl);
        _controller.animateCamera(CameraUpdate.newCameraPosition(
            new CameraPosition(
                bearing: 192.8334901395799,
                target: LatLng(position.latitude, position.longitude),
                tilt: 0,
                zoom: 18.00)));

        print(position);
        var currentPlace = "${first.locality}";

        print(_currentAddress);
        //print(mapUrl);

      } catch (e) {
        print(
            'there is a problem retriving your location,Make sure you have enabled your location service!');
      }
    }
  */

  checkValidNumber(var curr) {
    if (curr.isNaN || curr.isNegative || curr.isInfinite) {
      return false;
    } else {
      return true;
    }
  }

  void _moveCamera(LatLng _fromplaceDetail, LatLng _toPlaceDetail) async {
    print('before polyline');

    if (_markers.length > 0) {
      setState(() {
        _markers.clear();
      });
    }
  }

  void check(CameraUpdate u, GoogleMapController c) async {
    c.animateCamera(u);
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();
    print(l1.toString());
    print(l2.toString());
    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90)
      check(u, c);
  }

  double totalAmountFinal = 0.0;

  @override
  void dispose() {
    // updateTotalKMDriven();

    // _timer.cancel();
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  loc.Location location = loc.Location();

  loc.LocationData currentLoc;

  getCurrStreamLoc() async {
    imageData = await getMarker();
    location.changeSettings(
      accuracy: loc.LocationAccuracy.high,
      distanceFilter: 0,
      interval: 10,
    );
    location.enableBackgroundMode(enable: true);

    _locationSubscription =
        location.onLocationChanged.listen((LocationData locationData) {
      // Use current location
      if (mounted) {
        setState(() {
          currentLoc = locationData;
          print(currentLoc);
          // if (currentLoc.speed <= 1) {
          //   print('its not moving');
          // } else {
          //   print('ITS MOVING');
          // }
          /*  if (locationData != null) {
              print(locationData.speed * 3.6);

              if (locationData.speed * 3.6 <= 0) {
                print("in stop");
                setState(() {
                  counter++;
                });
              }
            } */

          if (locationData != null && _controller != null) {
            calculateDistanceNewMethod(
                LatLng(locationData.latitude, locationData.longitude));
            // print("counter wait $counter");
            updateMarkerAndCircle(
                Position(
                    latitude: locationData.latitude,
                    longitude: locationData.longitude),
                imageData);

            /* _controller.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(
                      bearing: 192.8334901395799,
                      target:
                          LatLng(locationData.latitude, locationData.longitude),
                      tilt: 0,
                      zoom: 14.00))); */
          }
        });
      }
    });
  }

  double _totalDistance = 0.0;

  LatLng _currentPosition, _previousPosition, fromPosition, toPosition;

  List<LatLng> locations = [];

  calculateDistanceNewMethod(LatLng taxiPosition) async {
    var newTaxiPosition = LatLng(taxiPosition.latitude, taxiPosition.longitude);

    _currentPosition = newTaxiPosition;
    locations.add(_currentPosition);
    if (locations.length >= 3) {
      _previousPosition = locations.elementAt(locations.length - 2);
      // calc(_previousPosition, _currentPosition);
      /* double newDistance = distance(
            _previousPosition.latitude,
            _previousPosition.longitude,
            _currentPosition.latitude,
            _currentPosition.longitude,
            'K');
  */

      double distanceInMtr = await Geolocator().distanceBetween(
        _previousPosition.latitude,
        _previousPosition.longitude,
        _currentPosition.latitude,
        _currentPosition.longitude,
      );

      // print('distance in meter' + (distanceInMtr / 1000).toStringAsFixed(4));

      // print(newDistance.toString());

      // _totalDistance += newDistance;
      setState(() {
        var newDistance = (distanceInMtr / 1000).toStringAsFixed(8);
        _totalDistance += double.parse(newDistance);
      });
      // print('Total Distance: $_totalDistance');
    } else {
      print('as');
    }
  }

  getLocation() async {
    Position position = await Geolocator().getCurrentPosition();
    // print(position.latitude + position.longitude);
  }

  sendSms(String phone, String amount, String distance, String days) async {
    ///* change bulkV2 to bulk
    ///* send id FSTSMS
    ///
    ///V2 Custom Message

    var authorization = Constants.SMS_API_KEY;

    var finalAmount = formatPrice(double.parse(amount));

    var rs = '%E2%82%B9';

    // var msg = "Your OTP is ${otp.toString()}. Thank you for registering! ";
    var msg =
        "Your Trip has ended.\nYou have travelled ${distance} Kms for ${days} days and AMOUNT TO BE PAID : Rs. $amount \nPlease pay the amount to the driver.\nHave a good day!\n\nRegards,\n${Constants.appName}";

    var numb = phone;
    var customMsgUrl =
        "https://www.fast2sms.com/dev/bulk?authorization=$authorization&sender_id=FSTSMS&message=$msg&language=english&route=p&numbers=$numb";

    var res = await http.get(customMsgUrl);
    print(res.body);
  }

  int counter = 0;

  bool isWaiting = false;

  List carNames = [
    'Hatchback',
    'Sedan',
    "Prime Sedan",
    'SUV',
    'Prime SUV',
    'Micro Van',
    'Traveller',
    'Mini Bus'
  ];
  List carPrice = [10, 12, 13, 15, 16, 13, 18, 18];
  String currentDays = '1';

  List carImage = [
    'https://covaitaxi.com/assets/images/hatchback.png',
    'https://covaitaxi.com/assets/images/swift.png',
    'https://covaitaxi.com/assets/images/etios.png',
    'https://covaitaxi.com/assets/images/eeco.png',
    'https://covaitaxi.com/assets/images/xylo.png',
    'https://covaitaxi.com/assets/images/crysta.png',
    'https://covaitaxi.com/assets/images/traveller.png',
    'https://covaitaxi.com/assets/images/minibus.png',
  ];

  TextEditingController roundDays = TextEditingController(text: '');

  showAlert() async {
    Size screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    var width = screenSize.width;
    var defaultSize = height * 0.05;
    var defaultPadding = 16;
    await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            var finalAmountWithAdditionalBata = 0.0;
            return AlertDialog(
              content: Container(
                height: widget.info.trip == "Round Trip"
                    ? height * 0.20
                    : height * 0.1,
                child: Column(children: [
                  Text(
                    'End this current trip?',
                    style: title,
                  ),
                  SizedBox(height: defaultSize),
                  widget.info.trip == "Round Trip"
                      ? Column(
                          children: [
                            Text(
                              'Round Trip Info',
                              style: sub,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                DropdownButton<String>(
                                  items: <String>[
                                    '1',
                                    '2',
                                    '3',
                                    '4',
                                    '5',
                                    '6',
                                    '7'
                                  ].map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: Center(child: new Text(value)),
                                    );
                                  }).toList(),
                                  value: currentDays,
                                  hint: Text('days  '),
                                  style: title,
                                  onChanged: (c) {
                                    setState(() {
                                      currentDays = c;
                                    });
                                    print("assa" + currentDays);
                                  },
                                ),
                                Text(
                                  ' Days',
                                  style: title,
                                )
                              ],
                            ),
                          ],
                        )
                      : Container(),
                  // Text('Days: $currentDays')
                ]),
              ),
              actions: [
                Container(
                  width: 100,
                  child: CustomButton(
                      title: 'yes'.toUpperCase(),
                      isIcon: false,
                      color: Colors.greenAccent.shade700,
                      context: context,
                      onPressed: () async {
                        var days = widget.info.days;
                        var diff = int.parse(currentDays) - int.parse(days);
                        var driverBataFinal = driverBata;

                        if (diff > 0) {
                          newFinal -= driverBata;

                          driverBataFinal =
                              ((int.parse(days) + diff) * onlyDriverBata);
                          // finalAmountWithAdditionalBata =
                          //     newFinal + driverBataFinal;
                        } else if (diff < 0) {
                          driverBataFinal = (diff * onlyDriverBata);
                        } else {
                          newFinal -= driverBata;
                          driverBataFinal = driverBata;
                        }
                        finalAmountWithAdditionalBata =
                            newFinal + driverBataFinal;

                        taxAmount =
                            (finalAmountWithAdditionalBata / 100) * taxPercent;
                        printInfo(
                            info:
                                "Difference and BATA FINAL ${driverBataFinal} diff " +
                                    driverBata.toString());
                        if (driverBataFinal.isNegative) {
                          driverBataFinal =
                              driverBata + (diff * onlyDriverBata);
                        }

                        printInfo(
                            info:
                                "Difference and BATA FINAL ${driverBataFinal} diff " +
                                    diff.toString());

                        commisionCharge =
                            (finalAmountWithAdditionalBata / 100) *
                                (commissionPercent + taxPercent);
                        print(taxAmount.toString() +
                            " commision " +
                            commisionCharge.toString() +
                            " bata " +
                            driverBataFinal.toString());
                        print(
                            "FINAL AMOUNT WITH ADD BATA $finalAmountWithAdditionalBata with bata $driverBataFinal for days $currentDays and differnece date $diff");
                        // await updateBookingInfo();
                        if (widget.info.custPhone.length > 1) {
                          sendSms(
                              widget.info.custPhone,
                              finalAmountWithAdditionalBata
                                  .toPrecision(2)
                                  .toString(),
                              _totalDistance.toPrecision(2).toString(),
                              currentDays);
                        }
                        _locationSubscription.cancel().then((value) {
                          print('Stream Cancelled');
                        });

                        updateBookingInfo(_totalDistance,
                            finalAmountWithAdditionalBata, driverBataFinal);
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EndTrip(
                                      bookInfo: widget.info,
                                      totalDist: _totalDistance,
                                      taxAmount: taxAmount.toString(),
                                      driverBata: driverBataFinal,
                                      commisionAmt: commisionCharge,
                                      days: int.parse(currentDays),
                                      finalAmount: finalAmountWithAdditionalBata
                                          .toStringAsFixed(2),
                                    )),
                            (route) => false);
                      }),
                )
              ],
            );
          });
        });

    // return true if the route to be popped
  }

  Firestore _firestore = Firestore.instance;

  BookingInfo updatedData;

  BasicController basicController = Get.put(BasicController());

  updateBookingInfo(
      double distance, double amount, double driverBataFinal) async {
    DriverDetails dr = basicController.getDriver();

    var date = DateFormat().add_yMMMMEEEEd().add_Hms().format(DateTime.now());

    var paymentId = DateTime.now().millisecondsSinceEpoch.toString();

    // print(dr.name);
    await _firestore.runTransaction((transaction) async {
      DocumentReference userDocRef = _firestore
          .collection('UserDetails')
          .document(widget.info.custUID)
          .collection("bookings")
          .document(widget.info.docId);
      DocumentReference adminRef =
          _firestore.collection('AdminDetails').document('allDetails');

      DocumentReference bookingRef =
          _firestore.collection('BookingDetails').document(widget.info.docId);

      DocumentReference driverRef =
          _firestore.collection('DriverDetails').document(dr.uid);
      // print(dr.ratings);

      await transaction.update(
        driverRef,
        {
          'totalTrips': FieldValue.increment(1),
          'amount': FieldValue.increment(-commisionCharge),
          'totalMoneyEarned': FieldValue.increment(amount),
          'totalDistanceTravelled': FieldValue.increment(distance),
          'lastTripTakenAt': date
        },
      );

      Payment pay = Payment(
        driverUid: dr.uid,
        amountAdded: commisionCharge.toString(),
        createdAt: date,
        driverName: dr.name,
        driverPhone: dr.phoneNum,
        paymentId: paymentId,
        errorMsg: 'no error',
        prevBalance: dr.amount.toString(),
        status: 'Ride Commission',
        timestamp: DateTime.now(),
        totalAmount: (dr.amount - commisionCharge).toString(),
        paymentThru: 'rideCommission',
        transactionReference: 'Ride Commission',
      );

      await Firestore.instance
          .collection('payments')
          .document(paymentId)
          .setData(pay.toJson());

      await transaction.update(
        userDocRef,
        {
          'totalAmountCalculated': amount.toStringAsFixed(2),
          'totalDistance': distance.toStringAsFixed(2),
          'tripCompletedAt': date,
          'status': 'Trip Completed',
          'isCompleted': true,
          'driverBata': driverBataFinal,
          'commisionCharge': commisionCharge,
          'taxCharge': taxAmount,
          'taxPercent': taxPercent,
          'days': currentDays,
        },
      );
      await transaction.update(
        bookingRef,
        {
          'totalAmountCalculated': amount.toStringAsFixed(2),
          'totalDistance': distance.toStringAsFixed(2),
          'tripCompletedAt': date,
          'status': 'Trip Completed',
          'isCompleted': true,
          'driverBata': driverBataFinal,
          'commisionCharge': commisionCharge,
          'taxCharge': taxAmount,
          'taxPercent': taxPercent,
          'days': currentDays,
        },
      );

      await transaction.update(
        adminRef,
        {
          'totalBookings': FieldValue.increment(1),
          'lastTripTakenAt': date,
          'lastTripTakenBy': dr.name,

          /*  'driverLocation':
                GeoPoint(dr.location.latitude, dr.location.longitude), */
        },
      );
    });
  }

  //? Calculation Amount
  var baseFare = 100;
  var waitingChargeAmount = 0.0;
  var miniKM;
  var calculatedKM = 0.0;
  double amountToCloud = 0.0;

  millisecToTimeConvert(var millisec) {
    var ms = millisec;
    var x = ms / 1000;
    var seconds = x % 60;
    x /= 60;
    var minutes = x % 60;
    x /= 60;
    var hours = x % 24;
    x /= 24;
    var days = x;
    print("min: " +
        minutes.toInt().toString() +
        " : " +
        seconds.toInt().toString());
    String formated =
        "${hours.toInt().toString()} hours ${minutes.toInt().toString()} minutes";
    print(formated);
    return formated;
  }

  sendTeleMsg() async {
    final String teleAPIKEY = '1791535286:AAEheK3P0IlUS27seNYYZnO49DvHbKAjYjw';
    final String bookedOn =
        DateFormat.yMMMMEEEEd().add_jm().format(DateTime.now());

    String messgae =
        "Cust Name : ${widget.info.custName}\nCust Phone : +91${widget.info.custPhone}\n\nDriver Name : ${widget.info.driverName}\nDriver Phone : +91${widget.info.driverPhone}\nCurrent Location : ${widget.info.from}\n\nReason : User is drunk\n\nRequested at : $bookedOn";
    //print(messgae);
    String url =
        "https://api.telegram.org/bot$teleAPIKEY/sendMessage?chat_id=-1001493013473&text=$messgae";
    var res = await http.get(
      url,
      headers: {"Accept": "application/json"},
    );

    print(res.body);
  }

  var newFinal = 0.0;
  var taxAmount = 0.0;

  var currentPlan = "Driver didnt come on time";

  double commisionCharge = 0.0;

  final Dependencies startTime = new Dependencies();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    // currentDays = widget.info.days;

    // getTaxPercent();

    // prevLoc = 0.0;
    // print(dependencies.stopwatch.elapsedMilliseconds.ceilToDouble().toString());
    // print("time : " + dependencies.stopwatch.elapsed.inMinutes.toString());
    //
    // startTime.stopwatch.start();
    Size screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    var width = screenSize.width;
    var defaultSize = height * 0.05;
    var defaultPadding = 16;

    // print(_totalDistance.toStringAsFixed(2));
    // if (_totalDistance - miniKM > 0) calculatedKM = (_totalDistance - miniKM);
    // print("final dist" + calculatedKM.toStringAsFixed(2));

    // var finalAmount = formatPrice(double.parse(
    //     ((calculatedKM) * 14 + waitingChargeAmount + baseFare)
    //         .toStringAsPrecision(4)));
    if (priceDetails != null) setDriverBata();
    if (miniKM != null) if (_totalDistance <= miniKM) {
      totalAmountFinal =
          miniKM * double.parse(widget.info.kmPrice) + driverBata;
    } else {
      totalAmountFinal =
          (_totalDistance * double.parse(widget.info.kmPrice)) + driverBata;
    }

    var finalAmount = formatPrice(totalAmountFinal + taxAmount);
    amountToCloud = totalAmountFinal;

    // print(finalAmount);

    // amountToCloud = amountToCloud + taxAmount;
    newFinal = amountToCloud;

    // millisecToTimeConvert(dependencies.stopwatch.elapsed.inMilliseconds);

    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        // appBar: buildGradientAppBar('Travelling'.toUpperCase()),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton.extended(
              heroTag: 'map',
              onPressed: () {
                // openGoogleMapDirection(
                //     LatLng(widget.info.fromLoc.latitude,
                //         widget.info.fromLoc.longitude),
                //     LatLng(widget.info.toLoc.latitude,
                //         widget.info.toLoc.longitude));
                launch(
                    "google.navigation:q=${widget.info.toLoc.latitude},${widget.info.toLoc.longitude}");
              },
              backgroundColor: Colors.red,
              label: Text(
                'Google map',
                style: title.copyWith(fontSize: 16, color: Colors.white),
              ),
              // icon: Icon(FontAwesomeIcons.checkCircle),
            ),
            FloatingActionButton.extended(
              heroTag: 'complete',
              onPressed: () {
                print("TAX AMOUNT $taxAmount");
                print("Com AMOUNT $commisionCharge");
                print("TOTAL AMOUNT BF ${amountToCloud}");
                print("TOTAL AMOUNT AF ${newFinal}");

                showAlert();

                // _moveCamera(myLocation, checkLoc);
              },
              backgroundColor: Colors.greenAccent.shade700,
              label: Text(
                'Complete',
                style: title.copyWith(fontSize: 16, color: Colors.white),
              ),
              // icon: Icon(FontAwesomeIcons.checkCircle),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

        body: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              child: Center(
                child: Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                      width: mediaQuery.size.width,
                      height: mediaQuery.size.height * 0.6,
                      child: GoogleMap(
                        key: _mapKey,
                        mapType: MapType.normal,
                        buildingsEnabled: true,
                        myLocationEnabled: false,

                        //zoomGesturesEnabled: true,
                        markers: _markers,
                        polylines: _polylines,
                        /*   onCameraMove: (pos) {
                              _moveCamera(myLocation, checkLoc);
                            }, */
                        initialCameraPosition:
                            CameraPosition(target: myLocation, zoom: 7),
                        onMapCreated: (GoogleMapController controller) {
                          moveCameraController = controller;
                          _controller = controller;
                          // _moveCamera(myLocation, checkLoc);
                          _controllerC.complete(controller);
                        },
                      )),
                ),
              ),
            ),
            /* Positioned(
                top: 30,
                right: 1,
                child: InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (c) {
                          return AlertDialog(
                            title: Text(
                              'Request Cancellation?',
                              textAlign: TextAlign.center,
                              style: title.copyWith(
                                  fontSize: 17, color: Colors.black),
                            ),
                            content: Container(
                              height: height * 0.5,
                              width: width * 0.9,
                              color: Colors.white,
                              child: Column(
                                children: [
                                  CustomRadioButton(
                                    enableShape: true,
                                    elevation: 0,
                                    defaultSelected:
                                        "Driver didnt come on time",
                                    enableButtonWrap: true,
                                    buttonTextStyle: ButtonTextStyle(
                                      unSelectedColor: Colors.white,
                                      selectedColor: Colors.black,
                                      textStyle: title.copyWith(
                                          color: Colors.white, fontSize: 13),
                                    ),
                                    width: width * 0.34,
                                    autoWidth: true,
                                    horizontal: false,
                                    unSelectedColor: Constants.primaryDark,
                                    buttonLables: [
                                      "Customer didnt come on time",
                                      "No safety measures followed",
                                      "Driver denied to come to pickup",
                                      "Unable to contact driver",
                                      "Other reasons",
                                    ],
                                    buttonValues: [
                                      "Customer didnt come on time",
                                      "Customer didnt follow safety measures followed",
                                      "Driver denied to go destination",
                                      "Unable to contact driver",
                                      "Other reasons",
                                    ],
                                    radioButtonValue: (value) async {
                                      setState(() {
                                        currentPlan = value;
                                      });
                                      print(value);
                                    },
                                    selectedColor: Colors.white,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(28.0),
                                    child: Custom_Button(
                                      hei: height,
                                      wid: width,
                                      title: 'Submit',
                                      onPress: () {
                                        sendTeleMsg();
                                        Firestore.instance
                                            .collection('CancelRequests')
                                            .document(widget.info.driverUid)
                                            .setData({
                                          'reason': 'User is drunk'
                                        }).then((value) {
                                          Fluttertoast.showToast(
                                              msg:
                                                  'Admin will contact you in 30 mins');
                                          Navigator.of(context).pop();
                                        });
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  },
                  child: Container(
                    // color: Colors.black,
                    child: Column(
                      children: [
                        CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.info_rounded,
                              color: Colors.red,
                            )),
                        SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Request Cancel',
                            style:
                                sub.copyWith(color: Colors.red, fontSize: 10),
                          ),
                        )
                      ],
                    ),
                  ),
                )), */
            Positioned(
              bottom: 0,
              child: Container(
                height: Get.height * 0.51,
                width: Get.width,
                decoration: BoxDecoration(
                  color: Color(0xff222222),
                  // gradient: FlutterGradients.premiumDark()
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Trip Details',
                      style: title.copyWith(color: Colors.white),
                    ),
                    SizedBox(height: defaultSize),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Travelled Km'.toUpperCase(),
                                  style: title.copyWith(
                                      fontSize: 15, color: Colors.white60),
                                ),
                                Text(
                                  '${(_totalDistance).toStringAsFixed(2)} Kms',
                                  style: sub.copyWith(
                                      color: Colors.white, fontSize: 25),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Price Per Km'.toUpperCase(),
                                  style: title.copyWith(
                                      fontSize: 15, color: Colors.white60),
                                ),
                                Text(
                                  '${formatPrice(double.parse(widget.info.kmPrice))} / Km',
                                  style: sub.copyWith(
                                      color: Colors.white, fontSize: 25),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: defaultSize),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Base Fare'.toUpperCase(),
                                  style: title.copyWith(
                                      fontSize: 15, color: Colors.white60),
                                ),
                                Text(
                                  '${finalAmount} ',
                                  style: sub.copyWith(
                                      color: Colors.white, fontSize: 30),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Total Time'.toUpperCase(),
                                  style: title.copyWith(
                                      fontSize: 15, color: Colors.white60),
                                ),
                                Text(
                                  '${(startTime.stopwatch.elapsed.toString().substring(0, startTime.stopwatch.elapsed.toString().indexOf('.')))} ',
                                  style: sub.copyWith(
                                      color: Colors.white, fontSize: 20),
                                ),
                              ],
                            ),
                          ],
                        ),
                        /*  CustomButton(
                            title: 'End Trip',
                            onPressed: () {
                              showAlert();
                            },
                            context: context,
                            color: Constants.primaryDark,
                          ) */
                      ],
                    ),
                  ],
                ),
              ),
            ),
            /* Positioned(
                  bottom: 20,
                  left: 20,
                  child: Container(
                    width: width * 0.9,
                    padding: EdgeInsets.all(30),
                    color: Colors.tealAccent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(currentLoc.toString()),
                        SizedBox(height: defaultSize),
                        Text("Speed : " +
                            (currentLoc != null ? currentLoc.speed * 3.6 : 0.0)
                                .toPrecision(2)
                                .toString() +
                            " km/hr"),
                        SizedBox(height: defaultSize),

                        Text("Distance : " +
                            _totalDistance.toPrecision(2).toString() +
                            " kms"),
                        SizedBox(height: defaultSize),

                        /* TimerText(
                          dependencies: dependencies,
                        ),
  */
                        Text("Waiting time " +
                            (dependencies.stopwatch.elapsed).toString() +
                            " minutes"),
                        SizedBox(height: defaultSize),
                        Text("Waiting charge amount in Rs : " +
                            (dependencies.stopwatch.elapsed.inSeconds * 0.0166666)
                                .toPrecision(2)
                                .toString() +
                            " rupees"),
                        // Text(currentLoc.accuracy.toString()),
                        // Text(currentLoc.altitude.toString()),
                        // Text(currentLoc.time.toString()),
                        // Text (currentLoc.heading.toString()),
                      ],
                    ),
                  )) */
            /*   Positioned(
                        bottom: 0,
                        child: Container(
                          height: Get.height * 0.5,
                          width: Get.width,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              gradient: LinearGradient(
                                  colors: [Colors.cyan, Colors.deepPurple]),
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(40),
                                  topLeft: Radius.circular(40))),
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                'Ride Details',
                                style: titleStyle.copyWith(color: Colors.white),
                              ),
                              SizedBox(height: defaultSize),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Text('Total Km Driven'.toUpperCase(),
                                          style: titleStyle),
                                      Text(
                                        '${(_totalDistance).toStringAsFixed(2)} Kms',
                                        style: sub.copyWith(
                                            color: Colors.white, fontSize: 25),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text('Total Payable Amount'.toUpperCase(),
                                          style: titleStyle),
                                      Text(
                                        '${double.parse(((_totalDistance) * 14).toStringAsPrecision(4))} ',
                                        style: sub.copyWith(
                                            color: Colors.white, fontSize: 30),
                                      ),
                                    ],
                                  ),
                                  Custom_Button(
                                    title: 'End Trip',
                                    onPress: () {
                                      // showAlert();
                                    },
                                    hei: height,
                                    wid: width,
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ), */
          ],
        ),
        /*   floatingActionButton: FloatingActionButton(
              backgroundColor: Constants.primaryColor,
              child: Icon(Icons.location_on),
              onPressed: () {
                showBottomSheetDialog(context);
                // getMyLocationBest();
                // /setPolylines(fromPosition, LatLng(13.0827, 80.2707));
                // calculateDistance(fromSNS, toAddr);
              }), */
      ),
    );
  }
}
