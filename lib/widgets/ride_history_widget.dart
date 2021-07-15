import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:driver_app/routes.dart';

import 'package:url_launcher/url_launcher.dart' as url;

class RideHistoryWidget extends StatelessWidget {
  final String from;
  final String to;
  final String phone;
  final String date;

  final BookingInfo bookingInfo;

  const RideHistoryWidget(
      {Key key, this.from, this.to, this.phone, this.date, this.bookingInfo})
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
              constraints: BoxConstraints(maxWidth: width * 0.65),

              // width: Get.width,
              child: Text('$point - $title',
                  overflow: TextOverflow.ellipsis,
                  style: CustomStyles.smallLightTextStyle),
            ),
            SizedBox(
              height: 3,
            ),
            Container(
              constraints: BoxConstraints(maxWidth: width * 0.68),
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
    return GestureDetector(
      onTap: () {
        // Navigator.of(context).pushNamed(RideDetailsPage.routeName);

        /*  Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => RideDetailsPage(
                      bookingInfo: bookingInfo,
                    ))); */
      },
      child: Container(
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
                  height: 30,
                ),
                InkWell(
                  onTap: () {
                    url.launch("tel:$phone");
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Icon(Icons.phone),
                      Text("$phone",
                          style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Constants.primaryColor)),
                      Text(
                        '$date',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        margin: EdgeInsets.only(left: 25, right: 25),
        height: 185,
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
