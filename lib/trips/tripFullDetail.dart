import 'package:driver_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:driver_app/model/bookingModel.dart';

class TripDetails extends StatefulWidget {
  final BookingInfo bookingInfo;

  const TripDetails({Key key, this.bookingInfo}) : super(key: key);
  @override
  _TripDetailsState createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Details'),
        backgroundColor: Constants.primaryColor,
      ),
      body: Center(
        child: Text('${widget.bookingInfo.from}'),
      ),
    );
  }
}
