import 'package:driver_app/model/bookingModel.dart';
import 'package:driver_app/model/driverDetail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:driver_app/routes.dart';

class BasicController extends GetxController {
  //FIREBASE AUTH
  FirebaseUser _currentUser;
  FirebaseAuth auth;

  DriverDetails driverDetails;

  //FROM TO PLACEDETAILS

  String userPhone;

  //BOOKING INFORMATION
  BookingInfo currentBooking;

  BasicController() {
    checkUserAuth();
  }

  checkUserAuth() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();

    if (user == null) {
      print('not logged in');
    } else
      initCurrentUser();
  }

  Future<Position> getCurrentLocation() async {
    Position pos = await Geolocator().getCurrentPosition();
    return pos;
  }

  getCurrentFormattedAddress() async {
    var pos = await getCurrentLocation();
    var geo = await Geocoder.local
        .findAddressesFromCoordinates(Coordinates(pos.latitude, pos.longitude));
    return geo[0].addressLine;
  }

  void setCurrentUser(FirebaseUser user) {
    _currentUser = user;
    // print('Current User set success ${user.phoneNumber}');
    update();
  }

  setCurrentDriver(DriverDetails d) {
    driverDetails = d;
    print("Driver set${d.name}");
    update();
  }

  DriverDetails getDriver() {
    return driverDetails;
  }

  void setUserPhone(String phone) {
    userPhone = phone;
    print('Current phone no set success' + phone);
    update();
  }

  void setCurrentBookingInfo(BookingInfo info) {
    currentBooking = info;
    // print('Current info set success' + currentBooking.custPhone);
    update();
  }

  BookingInfo getCurrentBookingInfo() {
    return currentBooking;
  }

  String getUserEmail() {
    return _currentUser.email;
  }

  String getUserPhone() {
    return _currentUser.phoneNumber;
  }

  FirebaseUser getCurrentUser() {
    // _currentUser =  FirebaseAuth.instance.currentUser();
    return _currentUser;
  }

  initCurrentUser() async {
    _currentUser = await FirebaseAuth.instance.currentUser();
    print('init user done in controller${_currentUser.phoneNumber.toString()}');
  }
}
