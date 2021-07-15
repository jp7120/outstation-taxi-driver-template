import 'package:flutter/rendering.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ? Font Styles

var title = GoogleFonts.montserrat(
    fontSize: 20, color: Colors.black, fontWeight: FontWeight.w800);
var sub = GoogleFonts.montserrat(
    fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500);

//? Colors
var black = Colors.black;
var white = Colors.white;

class Constants {
  static final String logo = "assets/images/logo.png";
  static final String bgleaf = "assets/images/bg_leaf.png";
  static final Color primaryColor = Color(0xffe84545);
  static final Color primaryColorDark = Color(0xff903749);
  static final Color primaryDark = Color(0xff2b2e4a);

  static final String appName = "Taxi-Go Driver";
  static final String companyNumber = "+919786999777";
  static final String companyWeb = "http://www.silveronewaytaxi.in/";

  ///? DATABASE COLLECTION PATHs

  static const String driverCollection = "DriverDetails";
  static const String userCollection = "DriverDetails";
  static const String bookingCollection = "DriverDetails";

  static final String baseUrl =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

  static final SMS_API_KEY =
      'tXGFnAr4LNYZM8Q9jwPVHxWdvs6eahl2qk5of7SzpRbOUEumITTnoiOFHqdCLhzJPgaxer2mpZ8UNEyf';

  static final String API_KEY = 'AIzaSyBNKpr4auBLgBgiOXJ41UUWTB58MZa6p3E';

  var notificationBigPicture =
      'https://lh3.googleusercontent.com/ogw/ADGmqu817KXx7d2OrQLDQis8nxj4yvdB-nGwJId3YlzG=s500';

  var notificationLargeIcon =
      'https://lh3.googleusercontent.com/ogw/ADGmqu817KXx7d2OrQLDQis8nxj4yvdB-nGwJId3YlzG=s500';
  var notificationSmallIcon =
      'https://lh3.googleusercontent.com/ogw/ADGmqu817KXx7d2OrQLDQis8nxj4yvdB-nGwJId3YlzG=s500';

  List<String> statusList = [
    'Booking Confirmed',
    'Driver Assigned',
    'Driver On the way',
    'Travelling',
    'Reached Destination',
  ];

  static final String whatsappUrl =
      "https://api.whatsapp.com/send?phone=$companyNumber&text=Hello $appName";
}

formatDate(DateTime date) {
  var da = DateFormat().add_yMMMMEEEEd().add_Hms().format(DateTime.now());
  return da;
}
