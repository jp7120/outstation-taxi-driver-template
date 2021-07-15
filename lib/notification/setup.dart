import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:driver_app/screens/futureRides.dart';
import 'package:driver_app/screens/profile.dart';

import 'package:driver_app/model/driverDetail.dart';
import 'package:driver_app/routes.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
/* import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg; */

import 'package:intl/intl.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:driver_app/trips/landingFromNotification.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:url_launcher/url_launcher.dart';

/* class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging();

  Future initialise() async {
    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }
} */

class DriverHomeScreen extends StatefulWidget {
  @override
  _DriverHomeScreenState createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final FirebaseMessaging _fcm = FirebaseMessaging();

  BasicController controller = Get.put(BasicController());

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  getTokenAndUpload(FirebaseUser user) {
    _fcm.getToken().then((value) {
      notifiToken = value;
      print(notifiToken);
      Firestore.instance
          .collection("DriverDetails")
          .document(user.uid)
          .updateData({'token': notifiToken});
    }).then((value) {
      print('notification token updated in firbase');
    });
  }

  getLocationAndUpload() async {
    var da = DateFormat().add_yMMMMEEEEd().add_Hms().format(DateTime.now());
    await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.low)
        .then((currPos) {
      print("in loc " + currPos.toString());
      if (mounted) {
        setState(() {
          currentLocation = LatLng(currPos.latitude, currPos.longitude);
        });
        // print(currPos.altitude);
        _addPoint(currPos.latitude, currPos.longitude);
      }
    });
    /* await Geolocator()
        .getLastKnownPosition(
            // desiredAccuracy: LocationAccuracy.bestForNavigation,
            desiredAccuracy: LocationAccuracy.low,
            locationPermissionLevel: GeolocationPermission.locationAlways)
        .then((lastPos) {
      if (lastPos == null) {
        print("In curr pos");

        Geolocator().getCurrentPosition().then((currPos) {
          if (mounted) {
            setState(() {
              currentLocation = LatLng(currPos.latitude, currPos.longitude);
            });
            // print(currPos.altitude);
            _addPoint(currPos.latitude, currPos.longitude);
          }
        });
      } else {
        print("In laast known pos");

        if (mounted) {
          setState(() {
            currentLocation = LatLng(lastPos.latitude, lastPos.longitude);
          });
          // print(lastPos.altitude);
          _addPoint(lastPos.latitude, lastPos.longitude);
        }
      }
      /* Firestore.instance
          .collection("DriverDetails")
          .document('VUeXHYc40ggBqgGAvU64fXIjxiG3')
          .updateData({
        'location': GeoPoint(value.latitude, value.longitude),
        'locationLastUpdatedAt': da,
      }); */
      // print(value);
    }); */
  }

  LatLng myLocation;
  Set<Marker> _markers = {};
  String _mapStyle;
  BitmapDescriptor _taxilocation;
  BitmapDescriptor _mylocation;
  BitmapDescriptor _mydestination;
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController moveCameraController;
  bool isMapCreated = false;
  final Key _mapKey = UniqueKey();
  int _selectedIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _fromLocationController = TextEditingController();
  final TextEditingController _toLocationController = TextEditingController();
  var sessionToken;
  var googleMapServices;
  Set<Polyline> _polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  bool _hasGottenCordinates = false;
  LatLngBounds bound;

  String notifiToken = '';

  DriverDetails driver;

  FirebaseUser user;

  Timer timer;

  getDriverDetails() {
    var curr = controller.getCurrentUser();
    drivers = basicController.getDriver();

    setState(() {
      user = curr;
      isOnline = drivers.isOnline;
    });
  }

  @override
  void dispose() {
    // timer.cancel();

    // TODO: implement dispose
    super.dispose();
  }

  final _firestore = Firestore.instance;
  Geoflutterfire geo;
  Stream<List<DocumentSnapshot>> stream;

  BasicController basicController = Get.find<BasicController>();

  DriverDetails drivers;

  FirebaseUser _currentUser;

  void _addPoint(double lat, double long) {
    var da = DateFormat().add_yMMMMEEEEd().add_Hms().format(DateTime.now());

    GeoFirePoint geoFirePoint = geo.point(latitude: lat, longitude: long);
    print(_currentUser.phoneNumber);
    _firestore
        .collection('DriverDetails')
        .document(_currentUser.uid)
        .updateData({
      // 'name': '${drivers.name}',
      'isOnline': isOnline,
      'position': geoFirePoint.data,
      'locationLastUpdatedAt': da,
    }).then((_) {
      print('added ${geoFirePoint.hash} successfully');
    });
  }

  getUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      _currentUser = user;
    });
  }

  @override
  void initState() {
    super.initState();

    _createNotificationChannel('new_notification_final', 'as', 'asd', 'sounds');

    getUser();
    // Future.delayed(Duration(seconds: 1), () => getDriverDetails());
    getDriverDetails();

    geo = Geoflutterfire();
    GeoFirePoint center = geo.point(latitude: 12.960632, longitude: 77.641603);

    getLocationAndUpload();
    myLocation = LatLng(11.0168, 76.9558);

    timer = Timer.periodic(Duration(minutes: 10), (timer) {
      print("timer" + timer.tick.toString());
      getLocationAndUpload();
    });

    _markers.add(Marker(
        markerId: MarkerId("My Location"),
        position: LatLng(myLocation.latitude, myLocation.longitude),
        icon: _mylocation,
        infoWindow: InfoWindow(
          title: "My Location",
        ),
        onTap: () {}));

    // TODO: implement initState
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    super.initState();
    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showMessgae(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FutureRidesNew()));
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        var data = Map<String, dynamic>.from(message['data']);
        // Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => FutureTrips(
        //             from: message['data']['fromD'],
        //             to: message['data']['to'],
        //             data: data)));

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => FutureRidesNew()));
      },
    );
  }

  showMessgae(var message) async {
    FlutterTts flutterTts = FlutterTts();

    flutterTts.speak(
      'You have a new booking..You have a new booking..You have a new booking..You have a new booking',
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // backgroundColor: Colors.greenAccent,
        content: Container(
          height: 150,
          child: ListTile(
            title: Text(
              message['notification']['title'],
              style: title,
              textAlign: TextAlign.center,
            ),
            /*  subtitle: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Text(
                message['notification']['body'],
                style: sub,
                textAlign: TextAlign.center,
              ),
            ), */
          ),
        ),
        actions: <Widget>[
          RaisedButton(
            color: Colors.greenAccent,
            child: Text(
              'Accept',
              style: title.copyWith(color: Colors.white),
            ),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => FutureRidesNew()));
            },
          ),
          RaisedButton(
            color: Colors.red,
            child: Text(
              'Decline',
              style: title.copyWith(color: Colors.white),
            ),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  showGoOnlineAlert(
    var message,
    var body,
    var titles,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text(
          message,
          style: title.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        content: ListTile(
          subtitle: Text(
            '$body',
            style: sub.copyWith(color: Colors.white),
          ),
        ),
        actions: <Widget>[
          RaisedButton(
            color: Colors.green.shade300,
            child: Text(
              'GO $titles',
              style: sub.copyWith(color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                isOnline = !isOnline;
              });
              getLocationAndUpload();
              /* Navigator.push(
                  context, MaterialPageRoute(builder: (context) => HomePage())); */
            },
          ),
          ElevatedButton(
            child: Text(
              'CANCEL',
              style: sub.copyWith(color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  showGoOfflineAlert(
    var message,
    var body,
    var titles,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.redAccent,
        title: Text(
          message,
          style: title.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        content: ListTile(
          subtitle: Text(
            '$body',
            style: sub.copyWith(color: Colors.white),
          ),
        ),
        actions: <Widget>[
          RaisedButton(
            color: Colors.green.shade300,
            child: Text(
              'GO $titles',
              style: sub.copyWith(color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              /*  Navigator.push(
                  context, MaterialPageRoute(builder: (context) => HomePage())); */
              setState(() {
                isOnline = !isOnline;
              });
            },
          ),
          ElevatedButton(
            child: Text(
              'CANCEL',
              style: sub.copyWith(color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  showLowAlertMessage(
    var message,
    var body,
    var titles,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.redAccent,
        title: Text(
          message,
          style: title.copyWith(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        content: ListTile(
          subtitle: Text(
            '$body',
            style: sub.copyWith(color: Colors.white),
          ),
        ),
        actions: <Widget>[
          RaisedButton(
            color: Colors.green.shade300,
            child: Text(
              'GO $titles',
              style: sub.copyWith(color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddMoneyScreen()));
            },
          ),
          ElevatedButton(
            child: Text(
              'CANCEL',
              style: sub.copyWith(color: Colors.white),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _createNotificationChannel(
      String id, String name, String description, String sound) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var androidNotificationChannel = AndroidNotificationChannel(
      id,
      'Customers Bookingas',
      'all the booking notificationass is here',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound(sound),
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel)
        .then((value) => print('asdsa'));
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(url);
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  FlutterTts flutterTts = FlutterTts();

  bool isOnline = false;

  bool isSwitched = false;
  var textValue = 'Switch is OFF';
  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      /* setState(() {
        isSwitched = true;
        isOnline = true;
        // textValue = 'Switch Button is ON';
      }); */
      showGoOnlineAlert(
          'Do you want to go ${!isOnline ? 'Online' : 'Offline'}?',
          "Click the below button ",
          "${!isOnline ? 'Online' : 'Offline'}");
      print(isSwitched);
    } else {
      setState(() {
        isSwitched = false;
        isOnline = false;
        //textValue = 'Switch Button is OFF';
      });
      print(isSwitched);
    }
  }

  LatLng currentLocation;

  moveToCurrentLoc() async {
    await Geolocator().getCurrentPosition().then((value) {
      if (value != null) {
        if (_markers.length > 0) {
          _markers.clear();
        }
        setState(() {
          _markers.add(Marker(
              markerId: MarkerId("My Location"),
              infoWindow: InfoWindow(title: 'My Location'),
              icon: BitmapDescriptor.defaultMarker,
              position: LatLng(value.latitude, value.longitude)));
        });

        moveCameraController
            .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: LatLng(value.latitude, value.longitude),
          zoom: 17,
        )));
      }
    });
  }

  bool isAdminVerified = false;
  @override
  Widget build(BuildContext context) {
    // getDriverDetails();
    // getTokenAndUpload(user);

    Size screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    var width = screenSize.width;
    var defaultSize = height * 0.05;
    var defaultPadding = 16;
    return Scaffold(
        appBar: isOnline ? buildAppBar('ONLINE') : buildAppBar('OFFLINE'),
        /* floatingActionButton: FloatingActionButton(
          child: Icon(Icons.directions),
          onPressed: () {
            /* _createNotificationChannel(
                'new_notification_final', 'as', 'asd', 'sounds'); */
            // Navigator.push(context,
            // MaterialPageRoute(builder: (context) => MovementsScreen()));
          },
        ), */
        drawer: isAdminVerified ? DrawerWidget() : null,
        body: StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance
                .collection("DriverDetails")
                .document(user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                var dri = snapshot.data.data;
                if (dri != null) {
                  var driver = DriverDetails.fromJson(dri);
                  controller.setCurrentDriver(driver);
                  print(driver.token);
                  // isOnline = driver.isOnline;
                  isAdminVerified = driver.isAdminVerified;
                  print(isOnline);
                  return SafeArea(
                    child: driver.isAdminVerified && !driver.disableDriver
                        ? Stack(
                            children: <Widget>[
                              currentLocation != null
                                  ? GoogleMap(
                                      key: _mapKey,
                                      mapType: MapType.normal,
                                      buildingsEnabled: true,
                                      myLocationEnabled: true,
                                      zoomControlsEnabled: false,
                                      myLocationButtonEnabled: true,

                                      //zoomGesturesEnabled: true,
                                      markers: _markers,
                                      polylines: _polylines,
                                      initialCameraPosition: CameraPosition(
                                          target: currentLocation, zoom: 15),
                                      onMapCreated:
                                          (GoogleMapController controller) {
                                        controller.setMapStyle(_mapStyle);
                                        moveCameraController = controller;
                                        moveToCurrentLoc();

                                        // _controller.complete(controller);
                                      },
                                    )
                                  : Center(
                                      child: CircularProgressIndicator(),
                                    ),
                              Positioned(
                                bottom: height * 0.07,
                                left: width * 0.07,
                                child: Container(
                                    width: width * 0.85,
                                    height: height * 0.25,
                                    decoration: BoxDecoration(
                                        // gradient: LinearGradient(
                                        //     begin: Alignment.topLeft,
                                        //     end: Alignment.topRight,
                                        //     colors: [Color(0xFF7CB3FF), Color(0xFF90CAFF)]),
                                        //color: Colors.white,
                                        gradient: FlutterGradients.deepBlue2(),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey,
                                              spreadRadius: 1,
                                              blurRadius: 1),
                                        ],
                                        borderRadius:
                                            BorderRadius.circular(20.0)),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: height * 0.008,
                                          left: width * 0.04,
                                          right: width * 0.04,
                                          bottom: height * 0.004),
                                      child: Column(
                                        //crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Status  ".toUpperCase(),
                                                style: title.copyWith(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              isOnline == true
                                                  ? Text(
                                                      "${'ONLINE'}"
                                                          .toUpperCase(),
                                                      style: title.copyWith(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )
                                                  : Text(
                                                      "Offline".toUpperCase(),
                                                      style: title.copyWith(
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                              Transform.scale(
                                                scale: width * 0.004,
                                                child: Switch(
                                                  onChanged: toggleSwitch,
                                                  value: isOnline,
                                                  activeColor:
                                                      Color(0xFF29bb89),
                                                  activeTrackColor:
                                                      Colors.green.shade300,
                                                  inactiveThumbColor:
                                                      Color(0xFFec4646),
                                                  inactiveTrackColor:
                                                      Colors.red.shade300,
                                                  // materialTapTargetSize: MaterialTapTargetpadded
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: height * 0.01,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProfileScreen(
                                                                driverDetails:
                                                                    driver,
                                                              )));
                                                },
                                                child: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      "${driver.profileImage}"),
                                                  radius: width * 0.07,
                                                ),
                                              ),
                                              SizedBox(
                                                width: width * 0.05,
                                              ),
                                              Row(
                                                children: [
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "${driver.name}",
                                                        style: title.copyWith(
                                                            color: Colors.white,
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      SizedBox(
                                                        height: height * 0.006,
                                                      ),
                                                      Text(
                                                        "${driver.carNumber}",
                                                        style: title.copyWith(
                                                            color: Colors.white,
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                      SizedBox(
                                                        height: height * 0.006,
                                                      ),
                                                      Text(
                                                        "Rating : ${driver.ratings}/5",
                                                        style: title.copyWith(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: height * 0.004,
                                                      ),
                                                      SmoothStarRating(
                                                        rating: double.parse(
                                                            driver.ratings),
                                                        // isReadOnly: false,
                                                        size: 14,
                                                        filledIconData:
                                                            Icons.star,
                                                        halfFilledIconData:
                                                            Icons.star_half,
                                                        defaultIconData:
                                                            Icons.star_border,
                                                        color:
                                                            Colors.yellowAccent,
                                                        borderColor: Colors
                                                            .yellowAccent
                                                            .shade400,
                                                        starCount: 5,
                                                        allowHalfRating: true,
                                                        spacing: 2.0,
                                                        /*   onRated: (value) {
                                        print("rating value -> $value");
                                        // print("rating value dd -> ${value.truncate()}");
                                      }, */
                                                      ),
                                                      SizedBox(
                                                        height: height * 0.002,
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                width: width * 0.04,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: height * 0.002,
                                                  ),
                                                  Text(
                                                    "Balance",
                                                    style: title.copyWith(
                                                      color: Colors.white,
                                                      fontSize: 17,
                                                      //fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: height * 0.008,
                                                  ),
                                                  Text(
                                                    "${formatPrice(double.parse(driver.amount.toString()))}",
                                                    style: title.copyWith(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    height: height * 0.025,
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  AddMoneyScreen()));
                                                    },
                                                    child: Container(
                                                      height: height * 0.04,
                                                      width: width * 0.27,
                                                      decoration: BoxDecoration(
                                                          color: Colors.red,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0)),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              "Add Money",
                                                              style: title.copyWith(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize:
                                                                      width *
                                                                          0.027),
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  width * 0.018,
                                                            ),
                                                            Icon(
                                                              FontAwesomeIcons
                                                                  .plusCircle,
                                                              size:
                                                                  width * 0.03,
                                                              color:
                                                                  Colors.white,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    )),
                              )
                            ],
                          )
                        : Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Text(
                                    'You profile is getting verified by the admin!\nPlease wait until its completed',
                                    style: title,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(28.0),
                                  child: CustomButton(
                                    context: context,
                                    title: 'Contact',
                                    color: Colors.amberAccent.shade700,
                                    onPressed: () {
                                      launch(
                                          'tel://${Constants.companyNumber}');
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                  );
                } else {
                  return Center(
                      child: Text(
                    'There is one problem with your account.\n Please restart the app',
                    style: title,
                    textAlign: TextAlign.center,
                  ));
                }
              } else {
                return Center(
                  child: SpinKitThreeBounce(
                    color: Colors.blueGrey.shade900,
                  ),
                );
              }
            }));
  }
}
