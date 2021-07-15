import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../routes.dart';



class RateDriverPage extends StatefulWidget {
  static final routeName = "rate-driver";

  final String totalDistance;

  const RateDriverPage({Key key, this.totalDistance}) : super(key: key);

  @override
  _RateDriverPageState createState() => _RateDriverPageState();
}

class _RateDriverPageState extends State<RateDriverPage> {
  double rating = 0.0;
  _buildDurationTime(String titles, String subtitle) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Text(titles, style: title.copyWith(fontSize: 13)),
        Text(
          subtitle,
          style:
              title.copyWith(fontSize: 17, color: Colors.amberAccent.shade700),
        ),
      ],
    );
  }

  var driverImage = null;

  @override
  Widget build(BuildContext context) {
    final mQ = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Container(
            width: mQ.width,
            height: mQ.height,
          ),
          NoLogoHeaderWidget(height: mQ.height * 0.4),
          Positioned(
              top: mQ.height * 0.15,
              child: Container(
                height: mQ.height * 0.8,
                width: mQ.width,
                child: ListView(
                  children: <Widget>[
                    Container(
                      width: 150,
                      height: 150,
                      decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xffd6d6d6),
                          boxShadow: [
                            BoxShadow(
                                color: Color(0x29000000),
                                offset: Offset(0, 5),
                                blurRadius: 6,
                                spreadRadius: 0)
                          ],
                          image: DecorationImage(
                            image: NetworkImage(
                                'https://randomuser.me/api/portraits/men/3.jpg'),
                          )),
                      child: ClipRRect(
                          child: Image.network(
                              'https://randomuser.me/api/portraits/men/3.jpg'),
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text("Your Driver",
                        textAlign: TextAlign.center,
                        style: CustomStyles.smallLightTextStyle),
                    Text(
                      "Dennis Osagiede",
                      textAlign: TextAlign.center,
                      style: CustomStyles.cardBoldDarkTextStyle,
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        // _buildDurationTime("Time", "15 min"),
                        // _buildDurationTime("Price", "N 1000"),
                        _buildDurationTime("Total Estimated Distance\n",
                            "${widget.totalDistance}"),
                      ],
                    ),
                    SizedBox(
                      height: mQ.height * 0.05,
                    ),
                    Text("Please let us know",
                        textAlign: TextAlign.center,
                        style: CustomStyles.smallLightTextStyle),
                    Text(
                      "How is your trip ?",
                      textAlign: TextAlign.center,
                      style: CustomStyles.cardBoldDarkTextStyle,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                        child: SmoothStarRating(
                      rating: rating,
                      size: 45,
                      filledIconData: Icons.star,
                      borderColor: Colors.amberAccent,
                      color: Colors.amberAccent,
                      halfFilledIconData: Icons.star_half,
                      defaultIconData: Icons.star_border,
                      starCount: 5,
                      allowHalfRating: false,
                      spacing: 2.0,
                      onRatingChanged: (value) {
                        setState(() {
                          rating = value;
                        });
                      },
                    )),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              )),
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
                  textColor: Constants.primaryColor,
                  child: Icon(
                    Icons.arrow_back,
                    size: 15,
                  ),
                  padding: EdgeInsets.all(6),
                  shape: CircleBorder(),
                ),
                Text(
                  "You are now reached the destination!",
                  overflow: TextOverflow.ellipsis,
                  style: CustomStyles.cardBoldTextStyle,
                ),
              ],
            ),
          ),
          Positioned(
              bottom: 10,
              right: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    "Submit",
                    style: CustomStyles.cardBoldDarkTextStyleGreen,
                  ),
                  MaterialButton(
                    onPressed: () {
                      ///TODO: add rating to drivers profile
/* 
                      Navigator.pushNamedAndRemoveUntil(context,
                          BookTaxiPageCustom.routeName, (route) => false); */
                    },
                    color: Constants.primaryColor,
                    textColor: Colors.white,
                    child: Icon(
                      Icons.arrow_forward,
                      size: 15,
                    ),
                    padding: EdgeInsets.all(6),
                    shape: CircleBorder(),
                  )
                ],
              )),
        ],
      ),
    );
  }
}
