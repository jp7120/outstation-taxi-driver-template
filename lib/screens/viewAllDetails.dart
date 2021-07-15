import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/maps/movement.dart';
import 'package:driver_app/model/driverDetail.dart';
import 'package:driver_app/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'confrimBooking.dart';
import 'futureRides.dart';
import 'package:flutter_gradients/flutter_gradients.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:share/share.dart';

import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:url_launcher/url_launcher.dart' as url;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideDetailsPage extends StatefulWidget {
  static final routeName = "ride-details-page";

  final BookingInfo bookingInfo;
  final List<LatLng> driverLocation;
  final List<DriverDetails> drivers;

  const RideDetailsPage(
      {Key key, this.bookingInfo, this.driverLocation, this.drivers})
      : super(key: key);

  @override
  _RideDetailsPageState createState() => _RideDetailsPageState();
}

class _RideDetailsPageState extends State<RideDetailsPage> {
  var latlng = LatLng(11.004556, 76.961632);

  BookingInfo bookingInfo;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  bool isMapCreated = false;
  final Key _mapKey = UniqueKey();
  Set<Marker> _markers = {};
  // LatLng _center = LatLng(23.63936, 68.14712);

  String _mapStyle;
  BitmapDescriptor _mylocation;
  BitmapDescriptor _taxilocation;
  BitmapDescriptor carLocation;
  LatLng _initialCameraPosition;
  LatLng _destinationPosition;

  LatLng myLocation;

  LatLngBounds bound;

  // _RideDetailsPageState(this.bookingInfo, this.drivers);

  var driverLoc;

  List<LatLng> latlngDriver;
  // final List<DriverDetails> drivers;

  /* getDatabase() async {
    // imageData = await getMarker();

    await webFirestore
        .collection('locations')
        // .where('docsUploaded', '==', true)
        .get()
        .then((value) {
      if (value.empty) {
        print('no loc');
      } else {
        value.docs.forEach((element) {
          /* setState(() {
            driverLoc = element.data()['position']['geopoint'];
          }); */
          // print("driverLOCC" + driverLoc.latitude.toString());
          setState(() {
            latlngDriver = LatLng(
                element.data()['position']['geopoint'].latitude,
                element.data()['position']['geopoint'].longitude);
          });

          print("LATLNG $latlngDriver");
          // print(element.data()['position']['geopoint'].latitude);
          // print(element.data()['name']);
/* 
          driverDetails = DriverDetails.fromJson(element.data());
          print(driverDetails.name);
          list.add(driverDetails);
          print(list.length); */
        });
        /*  setState(() {
          data = value.docs.first.data();
        }); */
      }
    });
  } */

  Firestore _firestore = Firestore.instance;
  Uint8List imageData;

  BookingInfo updatedData;

  void _onMapCreated(GoogleMapController controller) {
    print("IN CREATED " + latlngDriver.toString());
    Size screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    var width = screenSize.width;
    var defaultSize = height * 0.05;
    var defaultPadding = 16;
    mapController = controller;

    controller.setMapStyle(_mapStyle);

    if (bookingInfo != null) {
      setState(() {
        _markers.clear();
        addMarker(
            LatLng(bookingInfo.fromLoc.latitude, bookingInfo.fromLoc.longitude),
            "PickUp",
            "${bookingInfo.from}",
            _taxilocation,
            false);
        addMarker(
            LatLng(bookingInfo.toLoc.latitude, bookingInfo.toLoc.longitude),
            "Destination",
            "${bookingInfo.to}",
            _mylocation,
            false);

        // LatLng(latlng)

        /* drivers.forEach((element) {
        addDriverMarker(
            LatLng(element.location.latitude, element.location.longitude),
            "${element.name}",
            "${element.carNumber}\n${element.phoneNum}",
            carLocation,
            element);
      }); */

        /* addDriverMarker(LatLng(latlngDriver.latitude, latlngDriver.longitude),
          "Driver", "Ramesh Kumar\n+918271387483", carLocation, true); */

        /* _markers.add(Marker(
          markerId: MarkerId("home"),
          position: latlng,
          // rotation: newLocalData.heading,
          draggable: false,
          zIndex: 2,
          onTap: () {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: Text("Driver Name : Rajesh"),
                      content: Column(
                        children: <Widget>[
                          Text("Walllet balance : Rs.500"),
                          DefaultButton(
                            height: height,
                            width: width,
                          ),
                        ],
                      ),
                    ));
          },
          infoWindow:
              InfoWindow(snippet: 'Driver', title: 'Rajesh', onTap: () {}),
          visible: true,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData))); */
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 50);
        this.mapController.animateCamera(u2).then((void v) {
          setState(() {});
          check(u2, this.mapController);
        });
      });
      _controller.complete(controller);
    } else {
      Fluttertoast.showToast(msg: "No active booking");
    }
  }

  /*  Future<Uint8List> getMarker() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("assets/images/car_icon.png");

    setState(() {
      imageData = byteData.buffer.asUint8List();
    });
    return byteData.buffer.asUint8List();
  }
 */
  var rating = 9.1;

  bool isUpdated = false;

  /* updateBookingInfo(DriverDetails dr) async {
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
          'isAssigned': true,
          'driverRatings': dr.ratings,
          'driverLocation':
              GeoPoint(dr.location.latitude, dr.location.longitude),
        },
      );
      await transaction.update(
        bookingDocRef,
        {
          'driverName': dr.name,
          'driverPhone': dr.phoneNum,
          'isAssigned': true,
          'driverRatings': dr.ratings,
          'driverLocation':
              GeoPoint(dr.location.latitude, dr.location.longitude),
        },
      );
      setState(() {
        isUpdated = true;
        updatedData = BookingInfo(
          driverName: dr.name,
          isAssigned: true,
          driverPhone: dr.phoneNum,
          assignedTo: dr.name,
          carType: dr.carNumber,
          days: dr.profileImage,
          // currentLoc: GeoPoint(dr.location.latitude, dr.location.longitude),
          createdAt: DateTime.now().toIso8601String(),
          status: 'Driver Assigned',
        );
      });
      Fluttertoast.showToast(msg: 'SDJSADHDHKSD');
    });

    print("booking id${bookingInfo.custUID}");
    /*  Firestore.instance
        .collection('UserDetails')
        .document(bookingInfo.custUID)
        .collection("bookings")
        .document(bookingInfo.docId)
        .updateData(
      {
        'driverName': dr.name,
        'driverPhone': dr.phoneNum,
        'isAssigned': true,
        'driverRatings': dr.ratings,
        'driverLocation': GeoPoint(dr.location.latitude, dr.location.longitude),
      },
    ).then((value) {
      setState(() {
        isUpdated = true;
        updatedData = BookingInfo(
          driverName: dr.name,
          isAssigned: true,
          driverPhone: dr.phoneNum,
          assignedTo: dr.name,
          carType: dr.carNumber,
          days: dr.profileImage,
          // currentLoc: GeoPoint(dr.location.latitude, dr.location.longitude),
          createdAt: DateTime.now().toIso8601String(),
          status: 'Driver Assigned',
        );
      });
      Fluttertoast.showToast(msg: 'SDJSADHDHKSD');
    }); */
  } */

  void addDriverMarker(LatLng mLatLng, String mTitle, String mDescription,
      BitmapDescriptor marker, DriverDetails driver) {
    Size screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    var width = screenSize.width;
    var defaultSize = height * 0.05;
    var defaultPadding = 16;
    _markers.add(Marker(
      markerId:
          MarkerId((mTitle + "_" + _markers.length.toString()).toString()),
      position: mLatLng,
      infoWindow: InfoWindow(
        title: mTitle,
        snippet: mDescription,
      ),
      icon: marker,
      /* onTap: () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Center(
                      child: Text(
                    "Driver Name : ${driver.name}",
                    style: title.copyWith(color: Colors.deepPurpleAccent),
                    textAlign: TextAlign.center,
                  )),
                  content: Container(
                    height: height * 0.7,
                    width: width * 0.9,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        /* Text(
                          // "Walllet balance : ${formatPrice(1235.09)}",
                          "",
                          style: title,
                        ), */
                        Text(
                          "Phone number : ${driver.phoneNum}",
                          style: title,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Online  : ${driver.isOnline.toString()}",
                          style: title,
                          textAlign: TextAlign.center,
                        ),
                        Container(
                          height: 200,
                          width: 200,
                          child: Image.network(
                              'https://thumbs.dreamstime.com/b/businessman-icon-vector-male-avatar-profile-image-profile-businessman-icon-vector-male-avatar-profile-image-182095609.jpg'),
                        ),
                        SmoothStarRating(
                          starCount: 5,
                          // onRatingChanged: (s) {
                          //   // print(s);
                          //   setState(() {
                          //     rating = s;
                          //   });
                          // },
                          allowHalfRating: true,
                          color: Colors.amberAccent,
                          rating: double.parse(driver.ratings ?? 4.0),
                          borderColor: Colors.amber,
                          size: 30,
                        ),
                        Text(
                          "Car number : ${driver.carNumber.toString()}",
                          textAlign: TextAlign.center,
                          style: title,
                        ),
                        Text(
                          "Car Type: ${driver.carType}",
                          textAlign: TextAlign.center,
                          style: title,
                        ),
                        DefaultButton(
                          height: height,
                          width: width * 0.8,
                          color: Colors.blue,
                          title: 'Assign',
                          onPressed: () {
                            Fluttertoast.showToast(
                                msg: 'Driver Ramesh assigned');

                            // updateBookingInfo(driver);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ));
      }, */
      visible: true,
      flat: true,
      anchor: Offset(0.5, 0.5),
    ));
  }

  void addMarker(LatLng mLatLng, String mTitle, String mDescription,
      BitmapDescriptor marker, bool isCar) {
    Size screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    var width = screenSize.width;
    var defaultSize = height * 0.05;
    var defaultPadding = 16;
    _markers.add(Marker(
      markerId:
          MarkerId((mTitle + "_" + _markers.length.toString()).toString()),
      position: mLatLng,
      infoWindow: InfoWindow(
        title: mTitle,
        snippet: mDescription,
      ),
      icon: marker,
      visible: true,
      flat: true,
      anchor: Offset(0.5, 0.5),
    ));
  }

  LatLng _lastMapPosition;

  BasicController basicController = Get.put(BasicController());

  @override
  void initState() {
    // getDatabase();

    bookingInfo = basicController.getCurrentBookingInfo();

    latlngDriver = widget.driverLocation;

    if (bookingInfo != null) {
      myLocation =
          LatLng(bookingInfo.fromLoc.latitude, bookingInfo.fromLoc.longitude);

      _initialCameraPosition =
          LatLng(bookingInfo.fromLoc.latitude, bookingInfo.fromLoc.longitude);
      _destinationPosition =
          LatLng(bookingInfo.toLoc.latitude, bookingInfo.toLoc.longitude);

      BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
              'assets/images/mylocation.png')
          .then((onValue) {
        _taxilocation = onValue;
      });

      BitmapDescriptor.fromAssetImage(
              ImageConfiguration(
                devicePixelRatio: 2.5,
                size: Size(10, 10),
              ),
              'assets/images/car_icon.png')
          .then((onValue) {
        carLocation = onValue;
      });

      BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
              'assets/images/mydestination.png')
          .then((onValue) {
        _mylocation = onValue;
      });

      rootBundle.loadString('assets/images/map_style.txt').then((string) {
        _mapStyle = string;
      });

      getLatLngBounds(_initialCameraPosition, _destinationPosition);

      setData();
    } else {
      print('no');
    }
    super.initState();
  }

  var from, to;

  setData() {
    from = bookingInfo.from;
    to = bookingInfo.to;
  }

/* 
  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }
 */
  void getLatLngBounds(LatLng from, LatLng to) {
    if (from.latitude > to.latitude && from.longitude > to.longitude) {
      bound = LatLngBounds(southwest: to, northeast: from);
    } else if (from.longitude > to.longitude) {
      bound = LatLngBounds(
          southwest: LatLng(from.latitude, to.longitude),
          northeast: LatLng(to.latitude, from.longitude));
    } else if (from.latitude > to.latitude) {
      bound = LatLngBounds(
          southwest: LatLng(to.latitude, from.longitude),
          northeast: LatLng(from.latitude, to.longitude));
    } else {
      bound = LatLngBounds(southwest: from, northeast: to);
    }
  }

  void check(CameraUpdate u, GoogleMapController c) async {
    c.setMapStyle(_mapStyle);

    c.animateCamera(u);
    //  mapController.animateCamera(u);
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();
    print(l1.toString());
    print(l2.toString());
    if (l1.southwest.latitude == -90 || l2.southwest.latitude == -90)
      check(u, c);
  }

  _buildRideInfo(
    String point,
    String title,
    String subtitle,
    Color color,
  ) {
    Size screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    var width = screenSize.width;
    var defaultSize = height * 0.05;
    var defaultPadding = 16;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            Icon(
              FontAwesomeIcons.solidDotCircle,
              size: 12,
              color: color,
            ),
          ],
        ),
        SizedBox(
          width: 15,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                constraints: BoxConstraints(maxWidth: width * 0.7),
                child: Text('$point - $title',
                    softWrap: false,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CustomStyles.smallLightTextStyle)),
            SizedBox(
              height: 3,
            ),
            Container(
              // width: 100,
              constraints: BoxConstraints(maxWidth: width * 0.75),
              child: Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: CustomStyles.normalTextStyle,
              ),
            ),
          ],
        )
      ],
    );
  }

  /* getLocation(GoogleMapController controller) async {
    var position = await Geolocator().getCurrentPosition();
    /*  setState(() {
      myLocation = LatLng(position.latitude, position.longitude);
    }); */

    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: myLocation,
      zoom: 5,
    )));

    print(position);
  } */

  @override
  Widget build(BuildContext context) {
    // print(widget.bookingInfo.from);
    /*  print(imageData);
    print(bookingInfo.fromLoc.latitude + bookingInfo.fromLoc.longitude); */
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: bookingInfo != null
          ? Stack(
              children: <Widget>[
                Container(
                  width: mQ.width,
                  height: mQ.height,
                  decoration: BoxDecoration(
                      gradient: FlutterGradients.happyFisher(
                          tileMode: TileMode.mirror)),
                ),
                // NoLogoHeaderWidget(height: mQ.height * 0.5),
                Positioned(
                    top: 100,
                    left: 10,
                    right: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        alignment: Alignment.center,
                        width: mQ.width,
                        height: mQ.height * 0.8,
                        decoration: new BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.white,
                          borderRadius:
                              new BorderRadius.all(Radius.circular(5.0)),
                          boxShadow: [
                            BoxShadow(
                                color: Color(0x29000000),
                                offset: Offset(0, 5),
                                blurRadius: 6,
                                spreadRadius: 0)
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              /*  Padding(
                            padding: const EdgeInsets.only(top: 30.0),
                            child: Text(
                              'Customer Name : ${bookingInfo.custName}',
                              textAlign: TextAlign.center,
                              style: title,
                            )),
                        InkWell(
                          onTap: () {
                            url.launch("tel:8072021913");
                          },
                          child: Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: Text(
                                'Customer Phone : ${bookingInfo.custPhone}',
                                textAlign: TextAlign.center,
                                style: sub,
                              )),
                        ), */
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, top: 30.0),
                                child: _buildRideInfo(
                                    "From",
                                    "${from}",
                                    "${from.substring(0, from.indexOf(','))}",
                                    Colors.green),
                              ),
                              Padding(
                                  padding:
                                      const EdgeInsets.only(left: 20, top: 10),
                                  child: _buildRideInfo(
                                      "To",
                                      "${to}",
                                      "${to.substring(0, to.indexOf(','))}",
                                      Colors.red)),
                              Container(
                                  margin: const EdgeInsets.all(20),
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                  child: GoogleMap(
                                    key: _mapKey,
                                    mapType: MapType.normal,
                                    // zoomGesturesEnabled: true,

                                    markers: _markers,
                                    onMapCreated: _onMapCreated,
                                    initialCameraPosition: CameraPosition(
                                      target: myLocation,
                                      zoom: 10.0,
                                    ),
                                    // onCameraMove: _onCameraMove,
                                  )),
                              ListTile(
                                leading: !isUpdated
                                    ? Icon(
                                        FontAwesomeIcons.user,
                                        color: Constants.primaryColor,
                                        size: 35,
                                      )
                                    : CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(updatedData.days),
                                      ),
                                title: Text("CUSTOMER",
                                    style: CustomStyles.smallLightTextStyle),
                                subtitle: Text(
                                  "${bookingInfo.custName.substring(0, bookingInfo.custName.indexOf("@"))}",
                                  style: CustomStyles.cardBoldDarkTextStyle,
                                ),
                                trailing: InkWell(
                                  onTap: () {
                                    url.launch('tel:${bookingInfo.custPhone}');
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text("Contact Number".toUpperCase(),
                                          style:
                                              CustomStyles.smallLightTextStyle),
                                      Text(
                                        "${bookingInfo.custPhone}",
                                        style:
                                            CustomStyles.cardBoldDarkTextStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ListTile(
                                leading: Icon(
                                  FontAwesomeIcons.star,
                                  color: Constants.primaryColor,
                                  size: 30,
                                ),
                                title: Text("Ratings",
                                    style: CustomStyles.smallLightTextStyle),
                                subtitle: SmoothStarRating(
                                  starCount: 5,
                                  rating: 4.3,
                                  color: Colors.amberAccent,
                                  borderColor: Colors.amber,
                                  allowHalfRating: true,
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text("Car Number".toUpperCase(),
                                        style:
                                            CustomStyles.smallLightTextStyle),
                                    Text(
                                      "${basicController.driverDetails.carNumber}",
                                      style: CustomStyles.cardBoldDarkTextStyle,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              ListTile(
                                leading: Icon(
                                  FontAwesomeIcons.moneyCheck,
                                  color: Constants.primaryColor,
                                  size: 30,
                                ),
                                title: Text("PAYMENT",
                                    style: CustomStyles.smallLightTextStyle),
                                subtitle: Text(
                                  "${formatPrice(double.parse(bookingInfo.totalAmount))}",
                                  style: CustomStyles.cardBoldDarkTextStyle,
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text("Distance".toUpperCase(),
                                        style:
                                            CustomStyles.smallLightTextStyle),
                                    Text(
                                      "${bookingInfo.totalDistance} Kms.",
                                      style: CustomStyles.cardBoldDarkTextStyle,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text("${bookingInfo.bookedTime}".toUpperCase(),
                                  style: CustomStyles.cardBoldDarkTextStyle),
                              SizedBox(
                                height: 10,
                              ),
                              DefaultButton(
                                width: Get.width,
                                height: Get.height,
                                title: 'Start the trip',
                                color: Colors.redAccent,

                                //? FOR ASSIGNING DRIVER THERES A GOOGLE MAP FEATURE AND CHECK DRIVERS WITH CURRENT LOCS
                                //?AND ASSIGN THEM BY VIEWING THEM IN MAP
                                // onPressed: assignDriverAlertWithGoogleMap()
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => RidingMode(
                                                info: bookingInfo,
                                              )));

                                  /*   Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ConfirmBookingScreen(
                                                estimatedDistance: bookingInfo
                                                    .estimatedDistance,
                                                estimatedPrice:
                                                    bookingInfo.totalAmount,
                                                estimatedTime: bookingInfo
                                                    .totalTravelingTime,
                                                from: bookingInfo.from,
                                                to: bookingInfo.to,
                                                trip: bookingInfo.trip,
                                                type: bookingInfo.carType,
                                                kmPrice: bookingInfo.kmPrice,
                                                bookedDate:
                                                    bookingInfo.bookedTime,
                                                noOfDays: bookingInfo.days,
                                              ))); */
                                  var message =
                                      "There's a new booking for you!\n\n FROM\n${bookingInfo.from} TO ${bookingInfo.to}\n\nFULL DETAILS:\n";
                                  // Share.share("Hello $message");
                                },
                              ),
                              SizedBox(
                                height: 30,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
                /* bookingInfo.status != 'Completed'
              ? Positioned(
                  child: Container(
                      height: Get.height * 0.2,
                      child: Image.network(
                          "https://www.onlygfx.com/wp-content/uploads/2018/04/completed-stamp-2-1024x788.png")),
                  top: 30,
                  right: 10,
                )
              : Container(), */
                /*   bookingInfo.status != 'cancel'
              ? Positioned(
                  child: Container(
                      height: Get.height * 0.2,
                      child: Image.asset("assets/images/cancel.png")),
                  bottom: 100,
                  right: Get.width * 0.25,
                )
              : Container(), */
                Positioned(
                  top: 50.0,
                  left: 0.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      MaterialButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        color: Colors.white,
                        textColor: Colors.green,
                        child: Icon(
                          Icons.arrow_back,
                          size: 15,
                        ),
                        padding: EdgeInsets.all(6),
                        shape: CircleBorder(),
                      ),
                      Text(
                        "Ride Details",
                        style: CustomStyles.cardBoldTextStyle,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Center(
              child: Text(
                'You dont have a current booking',
                style: title,
                textAlign: TextAlign.center,
              ),
            ),
    );
  }

  assignDriverAlertWithGoogleMap() async {
    await showDialog(
        context: context,
        builder: (c) {
          return Container(
              margin: const EdgeInsets.all(20),
              height: MediaQuery.of(context).size.height * 0.3,
              child: GoogleMap(
                key: _mapKey,
                mapType: MapType.normal,
                zoomGesturesEnabled: true,

                markers: _markers,
                // onMapCreated: _onMapCreated,

                initialCameraPosition: CameraPosition(
                  target: myLocation,
                  zoom: 5.0,
                ),

                // onCameraMove: _onCameraMove,
              ));
        });
  }
}

class DefaultButton extends StatelessWidget {
  final Color color;
  final String title;
  final Function onPressed;
  const DefaultButton({
    Key key,
    @required this.width,
    @required this.height,
    this.color,
    this.title,
    this.onPressed,
  }) : super(key: key);

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed ?? () {},
      child: Container(
        decoration: BoxDecoration(
            color: color ?? Colors.white,
            borderRadius: BorderRadius.circular(20)),
        width: width * 0.7,
        height: height * 0.06,
        padding: EdgeInsets.all(8.0),
        child: Text(
          title ?? 'start',
          style: GoogleFonts.poppins(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
