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

class FutureRidesNew extends StatefulWidget {
  static final String routeName = "ride-history-page";

  @override
  _FutureRidesNewState createState() => _FutureRidesNewState();
}

class _FutureRidesNewState extends State<FutureRidesNew> {
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

  BasicController controller = Get.put(BasicController());

  DriverDetails driver;

  List<DriverDetails> driversList = [];

  List<LatLng> latlngDriver = [
    LatLng(11.89, 78.123),
  ];

  getDatabase() async {
    driver = controller.getDriver();
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
              // .document('Wed, May 19, 2021 5:58 PM')
              .where('isAssigned', isEqualTo: false)
              .orderBy('createdAt', descending: true)
              // .where('sendToDriver', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              historyList = [];

              var items = snapshot.data.documents;
              items.forEach((element) {
                BookingInfo it = BookingInfo.fromJson(element.data);

                if (it.sendToAll == true || (it.sendToDriver == driver.uid)) {
                  historyList.add(it);
                }
              });

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
                                          driver: driver),
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
                                "Customer Bookings",
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
                              'There is no new bookings, Please check back after some time!',
                              style: title,
                              textAlign: TextAlign.center),
                          // Spacer(),
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
                                  //? CHECK THIS ONE APPEARING MULTIPLE TIME WHEN COMMING FROM NOTIFICATION
                                  // upload once its finished

                                  if (Navigator.canPop(context)) {
                                    Navigator.of(context).pop();
                                  } else
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => DriverHomeScreen()));
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
  final DriverDetails driver;

  final BookingInfo bookingInfo;

  const RideHistoryWidget(
      {Key key,
      this.from,
      this.to,
      this.phone,
      this.date,
      this.bookingInfo,
      this.driverLoc,
      this.driver,
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
      onTap: () {
        // Navigator.of(context).pushNamed(RideDetailsPage.routeName);
        if (driver.isAdminVerified == false) {
          Fluttertoast.showToast(
            msg:
                'Your profile is under review!\nYou cannot view the future ride details',
          );
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => ConfirmBookingScreen(
                      estimatedDistance: bookingInfo.estimatedDistance,
                      estimatedPrice: bookingInfo.totalAmount,
                      estimatedTime: bookingInfo.totalTravelingTime,
                      from: bookingInfo.from,
                      to: bookingInfo.to,
                      trip: bookingInfo.trip,
                      type: bookingInfo.carType,
                      kmPrice: bookingInfo.kmPrice,
                      bookedDate: bookingInfo.bookedTime,
                      noOfDays: bookingInfo.days,
                      bookingInfo: bookingInfo,
                      docId: bookingInfo.docId)));
        }
      },
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
        height: height * 0.45,
        width: width * 0.9,
        child: Column(
          children: <Widget>[
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
                        Text('Estimated Distance :',
                            textAlign: TextAlign.start,
                            style: title.copyWith(fontSize: 10)),
                        Text('${bookingInfo.estimatedDistance}Kms.',
                            textAlign: TextAlign.start,
                            style: title.copyWith(
                                fontSize: 13, color: Colors.deepPurpleAccent)),
                      ],
                    ),
                    Column(
                      children: [
                        Text('Estimated Price :',
                            textAlign: TextAlign.start,
                            style: title.copyWith(fontSize: 10)),
                        Text(
                            '${formatPrice(double.parse(bookingInfo.totalAmount))}',
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
