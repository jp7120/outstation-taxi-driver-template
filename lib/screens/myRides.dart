import 'package:driver_app/screens/bookingConfirm.dart';
import 'package:driver_app/model/driverDetail.dart';
import 'package:driver_app/routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/routes.dart';

import 'package:flutter/material.dart';
import 'package:flutter_gradients/flutter_gradients.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'viewAllDetails.dart';

import '../constants.dart';
import 'confrimBooking.dart';
import 'package:url_launcher/url_launcher.dart' as URL;

class MyRides extends StatefulWidget {
  static final String routeName = "ride-history-page";

  @override
  _MyRidesState createState() => _MyRidesState();
}

class _MyRidesState extends State<MyRides> {
  String from, to, phone;

  // BasicController basicController = Get.put(BasicController());

  /*  getDocuments() async {
   /*  var users = await controller.getCurrentUser();
    var docId = controller.getCurrentBookingInfo();
 */
    setState(() {
      user = users;
    });

    /* await Firestore.instance
        .collection('BookingDetails')
        .document('UserID')
        .get()
        .then((value) {
      setState(() {
        from = value.data['from'];
        to = value.data['to'];
        phone = value.data['phone'];
      });
    }); */

    await DatabaseService()
        .userDetailRef
        .document(users.uid)
        .collection("bookings")
        .orderBy('createdAt')
        .getDocuments()
        .then((value) {
      /* value.documents.forEach((element) {
            
          }) */
    });
  }

  var stream;
 */

  var driverLoc;

  List<DriverDetails> driversList = [];

  List<LatLng> latlngDriver = [
    LatLng(11.89, 78.123),
  ];

  BasicController basicController = Get.put(BasicController());

  DriverDetails driver;

  getDatabase() {
    setState(() {
      driver = basicController.getDriver();
    });
  }

  @override
  void initState() {
    super.initState();
    getDatabase();
  }

  List<BookingInfo> historyList = [];

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    var width = screenSize.width;
    var defaultSize = height * 0.05;
    var defaultPadding = 16;
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('BookingDetails')
              .where('driverUid', isEqualTo: driver.uid)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              historyList = [];

              // print(snapshot.data.documents[0].data);

              var items = snapshot.data.documents;
              items.forEach((element) {
                BookingInfo it;
                it = BookingInfo.fromJson(element.data);
                if (element.data['totalAmountCalculated'] == null) {
                  it.totalAmountCalculated = '0.0';
                }
                historyList.add(it);
              });

              // print(historyList.length);

              return historyList.length > 0
                  ? Stack(
                      children: <Widget>[
                        Container(
                          width: mQ.width,
                          height: mQ.height,
                          decoration: BoxDecoration(
                              gradient: FlutterGradients.happyFisher(
                                  tileMode: TileMode.clamp,
                                  startAngle: 425,
                                  type: GradientType.linear,
                                  center: Alignment.centerRight,
                                  endAngle: 180)),
                        ),
                        // NoLogoHeaderWidget(height: mQ.height * 0.5),
                        Positioned(
                            top: mQ.height * 0.18,
                            left: 5,
                            right: 5,
                            child: Container(
                                height: mQ.height * 0.8,
                                child: ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: RideHistoryWidget(
                                        from: historyList[index].from,
                                        to: historyList[index].to,
                                        phone: historyList[index].custPhone,
                                        date: historyList[index].bookedTime,
                                        bookingInfo: historyList[index],
                                        driverLoc: latlngDriver,
                                        driverList: driversList,
                                      ),
                                    );
                                  },
                                  itemCount: historyList.length,
                                ))),
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
                                "My Rides",
                                style: CustomStyles.cardBoldTextStyle
                                    .copyWith(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Container(
                      height: height,
                      width: width,
                      child: Column(
                        children: <Widget>[
                          Lottie.asset('assets/images/nobookings.json'),
                          Text(
                              'You did not took any ride before.\nPlease accept a ride & check back after some time!',
                              style: title,
                              textAlign: TextAlign.center),
                          SizedBox(height: defaultSize),
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.black,
                            child: IconButton(
                                icon: Icon(
                                  Icons.chevron_left_rounded,
                                  size: 50,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                          )
                        ],
                      ),
                    );
            } else if (snapshot.connectionState == ConnectionState.none) {
              return Padding(
                padding: const EdgeInsets.all(28.0),
                child: Center(
                    child: Container(
                  child: Text(
                    'There is a problem while getting the database. Please try again later',
                    style: title,
                    textAlign: TextAlign.center,
                  ),
                )),
              );
            } else if (!snapshot.hasData ||
                snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SpinKitThreeBounce(
                  color: Constants.primaryColor,
                ),
              );
            } else {
              return Center(
                child: SpinKitThreeBounce(
                  color: Constants.primaryColor,
                ),
              );
            }
          }),
    );
  }
}

class RideHistoryWidget extends StatelessWidget {
  final String from;
  final String to;
  final String phone;
  final String date;
  final List<LatLng> driverLoc;
  final List<DriverDetails> driverList;

  final BookingInfo bookingInfo;

  const RideHistoryWidget(
      {Key key,
      this.from,
      this.to,
      this.phone,
      this.date,
      this.bookingInfo,
      this.driverLoc,
      this.driverList})
      : super(key: key);
  _buildRideInfo(String point, String title, String subtitle, Color color,
      Size screenSize) {
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
              constraints: BoxConstraints(maxWidth: width * 0.6),

              // width: Get.width,
              child: Text('$point - $title',
                  overflow: TextOverflow.ellipsis,
                  style: CustomStyles.smallLightTextStyle),
            ),
            SizedBox(
              height: 3,
            ),
            Container(
              constraints: BoxConstraints(maxWidth: width * 0.6),
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

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    var width = screenSize.width;
    var defaultSize = height * 0.05;
    var defaultPadding = 16;
    return InkWell(
      onTap: bookingInfo.isCompleted == null || bookingInfo.isCompleted == false
          ? () {
              // Navigator.of(context).pushNamed(RideDetailsPage.routeName);
              //

              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AcceptedScreen(
                            bookingInfo: bookingInfo,
                          )));
            }
          : () {},
      /*  onLongPress: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RideDetailsPage(
                      bookingInfo: bookingInfo,
                      driverLocation: driverLoc,
                      drivers: driverList,
                    )));
      }, */
      child: Container(
        height: height * 0.47,
        width: width * 0.9,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(color: Colors.greenAccent),
              width: width,
              child: Text(
                bookingInfo.status == 'Not Started'
                    ? 'Upcoming'
                    : bookingInfo.isCompleted == true
                        ? 'Completed'
                        : 'Started',
                style: title.copyWith(fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 30.0),
                  child: _buildRideInfo(
                      "From",
                      "${from}",
                      "${from.substring(0, from.indexOf(','))}",
                      Colors.green,
                      screenSize),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 20, top: 5),
                    child: _buildRideInfo(
                        "To",
                        "${to}",
                        "${to.substring(0, to.indexOf(','))}",
                        Colors.red,
                        screenSize)),
                SizedBox(
                  height: defaultSize * 0.5,
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x33303030),
                        offset: Offset(0, 5),
                        blurRadius: 15,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Text('${bookingInfo.carType.toUpperCase()}',
                      textAlign: TextAlign.start,
                      style: title.copyWith(fontSize: 13, color: Colors.white)),
                ),
                SizedBox(
                  height: defaultSize * 0.5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                            '${bookingInfo.isCompleted ? 'Total Distance : ' : 'Estimated Distance : '}',
                            textAlign: TextAlign.start,
                            style: title.copyWith(fontSize: 10)),
                        Text(
                            '${bookingInfo.isCompleted ? bookingInfo.totalDistance : bookingInfo.estimatedDistance}Kms.',
                            textAlign: TextAlign.start,
                            style: title.copyWith(
                                fontSize: 13, color: Colors.deepPurpleAccent)),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                            '${bookingInfo.isCompleted && bookingInfo.totalAmountCalculated != '0.0' ? 'Total Amount : ' : 'Estimated Amount : '}',
                            textAlign: TextAlign.start,
                            style: title.copyWith(fontSize: 10)),
                        Text(
                            bookingInfo.totalAmountCalculated != '0.0'
                                ? '${formatPrice(double.parse(bookingInfo.totalAmountCalculated))}'
                                : '${formatPrice(double.parse(bookingInfo.totalAmount))}',
                            textAlign: TextAlign.start,
                            style: title.copyWith(
                                fontSize: 13, color: Colors.deepPurpleAccent)),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: defaultSize * 0.2,
                ),

                /*  Text(
                    'Estimated Price : ${formatPrice(double.parse(bookingInfo.totalAmount))}',
                    textAlign: TextAlign.start,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      // fontWeight: FontWeight.bold,
                      fontSize: 11,
                    )), */
                SizedBox(
                  height: defaultSize * 0.5,
                ),
                Text('$date',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      // fontWeight: FontWeight.bold,
                      fontSize: 11,
                    )),
              ],
            ),
          ],
        ),
        margin: EdgeInsets.only(left: 15, right: 15),
        // height: 185,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Color(0x33303030),
              offset: Offset(0, 5),
              blurRadius: 15,
              spreadRadius: 0,
            ),
          ],
        ),
      ),
    );
  }
}
