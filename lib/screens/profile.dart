import 'package:driver_app/auth/login.dart';
import 'package:driver_app/screens/addMoney.dart';
import 'package:driver_app/model/bookingModel.dart';
import 'package:driver_app/model/driverDetail.dart';
import 'package:driver_app/notification/setup.dart';
import 'package:driver_app/routes.dart';
import 'package:driver_app/widgets/customButton.dart';
import 'package:driver_app/widgets/money.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants.dart';

class ProfileScreen extends StatefulWidget {
  final DriverDetails driverDetails;

  const ProfileScreen({
    Key key,
    this.driverDetails,
  }) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  BasicController basicController = Get.put(BasicController());

  DriverDetails driver;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setDriver();
  }

  setDriver() {
    setState(() {
      driver = basicController.getDriver();
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
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                          "https://cdn.iconscout.com/icon/free/png-256/ambulance-driver-2349770-1955457.png"),
                    ),
                  ),
                  SizedBox(
                    width: width * 0.018,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddMoneyScreen()));
                    },
                    child: Container(
                      height: height * 0.04,
                      width: width * 0.27,
                      decoration: BoxDecoration(
                          // color: Colors.red,
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(
                              "Add Money",
                              style: title.copyWith(
                                  color: Colors.black, fontSize: width * 0.027),
                            ),
                            SizedBox(
                              width: width * 0.018,
                            ),
                            Icon(
                              FontAwesomeIcons.plusCircle,
                              size: width * 0.03,
                              color: Colors.black,
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(spreadRadius: -15, blurRadius: 50)
                            ],
                            color: Colors.white),
                        child: Text(
                          'Total Rides : ${driver.totalTrips == null ? '0' : driver.totalTrips}',
                          style: sub.copyWith(fontSize: 17),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(spreadRadius: -15, blurRadius: 50)
                            ],
                            color: Colors.black),
                        child: Text(
                          'Balance : ${formatPrice(driver.amount)}',
                          overflow: TextOverflow.ellipsis,
                          style:
                              sub.copyWith(fontSize: 15, color: Colors.white),
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Name : ',
                        style: sub.copyWith(fontSize: 20),
                      ),
                      Text(
                        '${driver.name}',
                        style: sub.copyWith(fontSize: 20),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Phone : ',
                      style: sub.copyWith(fontSize: 20),
                    ),
                    Text(
                      '${driver.phoneNum}',
                      style: sub.copyWith(fontSize: 20),
                    ),
                  ],
                ),
                Center(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.amberAccent),
                    child: Text(
                      'My Car Details',
                      style: sub.copyWith(fontSize: 17),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Category : ',
                      style: sub.copyWith(fontSize: 17),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      ' ${driver.carType}',
                      style: title,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Name :',
                      style: sub.copyWith(fontSize: 17),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      ' ${driver.carName}',
                      style: title,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reg No :',
                      style: sub.copyWith(fontSize: 17),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      "${driver.carNumber}",
                      style: title,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Account Created At :',
                        style: sub.copyWith(fontSize: 17),
                        textAlign: TextAlign.start,
                      ),
                      Text(
                        ' ${driver.accountCreatedAt}',
                        style: title.copyWith(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                CustomButton(
                  color: Colors.greenAccent.shade700,
                  context: context,
                  title: 'Logout  ',
                  onPressed: () {
                    basicController.setCurrentUser(null);
                    showLogoutButton(context);
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  showLogoutButton(var context) async {
    await showDialog(
        context: context,
        builder: (c) {
          return AlertDialog(
            backgroundColor: Colors.red,
            title: new Text(
              "Logout?",
              style: title.copyWith(color: Colors.black),
              textAlign: TextAlign.center,
            ),
            content: new Container(
                // color: Colors.black,
                height: Get.height * 0.1,
                width: Get.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Container(
                          child: Text(
                        'Are you sure you want to logout from this app?',
                        textAlign: TextAlign.center,
                        style: sub.copyWith(
                          color: Colors.white,
                        ),
                      )),
                    )
                  ],
                )),
            actions: <Widget>[
              FlatButton(
                // color: Colors.blue,
                child: Text(
                  'Yes'.toUpperCase(),
                  style: title.copyWith(color: Colors.white),
                ),
                onPressed: () {
                  FirebaseAuth.instance.signOut().then((value) {
                    if (Navigator.canPop(c)) {
                      Navigator.pop(c);
                    }
                    Fluttertoast.showToast(msg: "Signing out");
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (c) => PhoneInputScreen()),
                        (route) => false);
                  });
                },
              ),
              FlatButton(
                // color: Colors.white,
                child: Text(
                  'No'.toUpperCase(),
                  style: title.copyWith(color: Colors.white),
                ),
                onPressed: () {
                  if (Navigator.canPop(c)) {
                    Navigator.pop(c);
                  }
                },
              )
            ],
          );
        });
  }
}
