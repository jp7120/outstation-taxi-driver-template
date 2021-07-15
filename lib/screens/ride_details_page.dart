import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:driver_app/routes.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class RideDetailsPage extends StatefulWidget {
  static final routeName = "ride-details-page";

  final BookingInfo bookingInfo;

  const RideDetailsPage({Key key, this.bookingInfo}) : super(key: key);

  @override
  _RideDetailsPageState createState() => _RideDetailsPageState(bookingInfo);
}

class _RideDetailsPageState extends State<RideDetailsPage> {
  final BookingInfo bookingInfo;

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
  LatLng _initialCameraPosition;
  LatLng _destinationPosition;

  LatLng myLocation;

  LatLngBounds bound;

  _RideDetailsPageState(this.bookingInfo);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    controller.setMapStyle(_mapStyle);
    setState(() {
      _markers.clear();
      addMarker(
          LatLng(bookingInfo.fromLoc.latitude, bookingInfo.fromLoc.longitude),
          "PickUp",
          " ",
          _taxilocation);
      addMarker(LatLng(bookingInfo.toLoc.latitude, bookingInfo.toLoc.longitude),
          "Destination", "", _mylocation);
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 50);
      this.mapController.animateCamera(u2).then((void v) {
        check(u2, this.mapController);
      });
    });
    _controller.complete(controller);
  }

  void addMarker(LatLng mLatLng, String mTitle, String mDescription,
      BitmapDescriptor marker) {
    _markers.add(Marker(
      markerId:
          MarkerId((mTitle + "_" + _markers.length.toString()).toString()),
      position: mLatLng,
      infoWindow: InfoWindow(
        title: mTitle,
        snippet: mDescription,
      ),
      icon: marker,
    ));
  }

  LatLng _lastMapPosition;

  @override
  void initState() {
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

  getLocation(GoogleMapController controller) async {
    var position = await Geolocator().getCurrentPosition();
    /*  setState(() {
      myLocation = LatLng(position.latitude, position.longitude);
    }); */

    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: myLocation,
      zoom: 5,
    )));

    print(position);
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.bookingInfo.from);
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Container(
            width: mQ.width,
            height: mQ.height,
          ),
          NoLogoHeaderWidget(height: mQ.height * 0.5),
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
                    borderRadius: new BorderRadius.all(Radius.circular(5.0)),
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
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0, top: 30.0),
                          child: _buildRideInfo(
                              "From",
                              "${from}",
                              "${from.substring(0, from.indexOf(','))}",
                              Colors.green),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(left: 20, top: 10),
                            child: _buildRideInfo(
                                "To",
                                "${to}",
                                "${to.substring(0, to.indexOf(','))}",
                                Colors.red)),
                        Container(
                            margin: const EdgeInsets.all(20),
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: GoogleMap(
                              key: _mapKey,
                              mapType: MapType.normal,
                              zoomGesturesEnabled: true,
                              markers: _markers,
                              onMapCreated: _onMapCreated,
                              initialCameraPosition: CameraPosition(
                                target: myLocation,
                                zoom: 10.0,
                              ),
                              // onCameraMove: _onCameraMove,
                            )),
                        ListTile(
                          leading: Icon(
                            FontAwesomeIcons.user,
                            color: Constants.primaryColor,
                            size: 35,
                          ),
                          title: Text("DRIVER",
                              style: CustomStyles.smallLightTextStyle),
                          subtitle: Text(
                            "${bookingInfo.driverName}",
                            style: CustomStyles.cardBoldDarkTextStyle,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Contact Number".toUpperCase(),
                                  style: CustomStyles.smallLightTextStyle),
                              Text(
                                "${bookingInfo.driverPhone}",
                                style: CustomStyles.cardBoldDarkTextStyle,
                              ),
                            ],
                          ),
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
                                  style: CustomStyles.smallLightTextStyle),
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
                            style: CustomStyles.smallLightTextStyle),
                      ],
                    ),
                  ),
                ),
              )),
          bookingInfo.status == 'Completed'
              ? Positioned(
                  child: Container(
                      height: Get.height * 0.2,
                      child: Image.network(
                          "https://www.onlygfx.com/wp-content/uploads/2018/04/completed-stamp-2-1024x788.png")),
                  top: 30,
                  right: 10,
                )
              : Container(),
          bookingInfo.status == 'cancel'
              ? Positioned(
                  child: Container(
                      height: Get.height * 0.2,
                      child: Image.asset("assets/images/cancel.png")),
                  bottom: 100,
                  right: Get.width * 0.25,
                )
              : Container(),
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
      ),
    );
  }
}
