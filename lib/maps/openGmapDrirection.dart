import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart' as url;

//? Accesing by
//   openGoogleMapDirection(
// LatLng(11.34, 77.88),
// LatLng(12.89, 78.89));
//
openGoogleMapDirection(LatLng from, LatLng to) {
  url.launch(
      'https://www.google.com/maps/dir/?api=1&origin=${from.latitude},${from.longitude}&destination=${to.latitude},${to.longitude}');
}
