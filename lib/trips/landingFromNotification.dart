import 'package:driver_app/routes.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart' as URL;

class FutureTrips extends StatefulWidget {
  final String from;
  final String to;

  final Map<dynamic, dynamic> data;

  const FutureTrips({Key key, this.from, this.to, this.data}) : super(key: key);

  @override
  _FutureTripsState createState() => _FutureTripsState();
}

class _FutureTripsState extends State<FutureTrips> {
  bool active = false;
  var contextL;
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    var width = screenSize.width;
    var defaultSize = height * 0.05;
    var defaultPadding = 16;
    context = context;
    // print(widget.data['bookingId']);
    return Scaffold(
      appBar: AppBar(
        //TITLE GOES HERE
        title: Text('Driver: Ramesh TN38CE0979'),
        actions: <Widget>[
          IconButton(
            icon: Icon(active ? Icons.done_outline : Icons.done),
            onPressed: () {
              setState(() {
                active = !active;
              });
            },
          )
        ],
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection('BookingDetails')
                // .where('assigned', isEqualTo: active)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                print('loading');
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SpinKitThreeBounce(
                      color: Constants.primaryDark,
                      size: 70,
                    ),
                    Text(
                      'Bookings are loading',
                      style: title,
                    )
                  ],
                );
              } else {
                var data = snapshot.data.documents;

                return data.length > 0
                    ? Container(
                        child: ListView.builder(
                          itemBuilder: (context, i) {
                            var assigned = data[i]['assigned'];

                            var totalDist = double.parse('123');
                            return InkWell(
                                onTap: () async {
                                  await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return assigned == false
                                            ? AlertDialog(
                                                elevation: 10,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                title: Text(
                                                  'Are you sure to take this trip?',
                                                  textAlign: TextAlign.center,
                                                  style: title.copyWith(
                                                      fontSize: 18,
                                                      color: Constants
                                                          .primaryColor),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 50),
                                                content: Container(
                                                  height: height * 0.1,
                                                  width: width,
                                                  // decoration: BoxDecoration(
                                                  //     color: Colors.orange,
                                                  //     borderRadius: BorderRadius.circular(20)),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      SizedBox(
                                                          width: defaultSize),
                                                      Text(
                                                        'From : ${data[i]['from']}',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: sub,
                                                      ),
                                                      Text(
                                                        'To : ${data[i]['to']}',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: sub,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    child: Text('YES'),
                                                    onPressed: () {
                                                      snapshot.data.documents[i]
                                                          .reference
                                                          .updateData({
                                                        'assigned': true,
                                                        'driverName': 'Ramesh',
                                                      }).then((value) {
                                                        Navigator.of(context)
                                                            .pop();

                                                        Fluttertoast.showToast(
                                                            msg: 'sss');

                                                        BookingInfo
                                                            bookingInfo =
                                                            BookingInfo(
                                                          from: data[i]['from'],
                                                          to: data[i]['from'],
                                                          // createdAt: data[i]['created'],
                                                          isAssigned: true,
                                                        );
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        TripDetails(
                                                                          bookingInfo:
                                                                              bookingInfo,
                                                                        )));
                                                      });
                                                    },
                                                  ),
                                                  FlatButton(
                                                    child: Text('NO'),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  )
                                                ],
                                              )
                                            : AlertDialog(
                                                elevation: 10,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20)),
                                                title: Text(
                                                  'Sorry this is already taken by other person',
                                                  textAlign: TextAlign.center,
                                                  style: title.copyWith(
                                                      fontSize: 18,
                                                      color: Constants
                                                          .primaryColor),
                                                ),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 50),
                                                content: Container(
                                                  height: height * 0.2,
                                                  width: width,
                                                  // decoration: BoxDecoration(
                                                  //     color: Colors.orange,
                                                  //     borderRadius: BorderRadius.circular(20)),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      SizedBox(
                                                          width: defaultSize),
                                                      Text(
                                                        'From : ${data[i]['from']}',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: sub,
                                                      ),
                                                      Text(
                                                        'To : ${data[i]['to']}',
                                                        textAlign:
                                                            TextAlign.start,
                                                        style: sub,
                                                      ),
                                                      SizedBox(
                                                          height: defaultSize),
                                                      Center(
                                                        child: OutlineButton(
                                                          color: Colors.green,
                                                          child: Text('Close'),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                      });
                                },
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Banner(
                                      location: BannerLocation.topEnd,
                                      message: data[i]['assigned'] == true
                                          ? 'Assigned'
                                          : 'Not assigned',
                                      child: Card(
                                        elevation: 10,
                                        margin: EdgeInsets.all(10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Container(
                                          height: height * 0.3,
                                          width: width * 0.8,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(height: defaultSize),
                                              Row(
                                                children: <Widget>[
                                                  SizedBox(
                                                      width: defaultSize * 0.5),
                                                  Icon(
                                                    Icons.pin_drop,
                                                    color: Colors.red,
                                                  ),
                                                  Text(data[i]['from'],
                                                      style: sub),
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  SizedBox(
                                                      width: defaultSize * 0.5),
                                                  Icon(
                                                    Icons.pin_drop,
                                                    color: Colors.green,
                                                  ),
                                                  Text(
                                                    data[i]['to'],
                                                    style: sub,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: defaultSize),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    'Estimated Distance : ',
                                                    style: sub,
                                                  ),
                                                  Text(
                                                    totalDist
                                                        .toStringAsFixed(1),
                                                    style: title,
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    'Estimated Price : ',
                                                    style: sub,
                                                  ),
                                                  Text(
                                                    formatPrice(totalDist * 14),
                                                    style: title,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ));
                          },
                          itemCount: data.length,
                        ),
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
                            Spacer(),
                            InkWell(
                              onTap: () {
                                URL.launch(Uri.encodeFull(
                                    'https://api.whatsapp.com/send?phone=919791597993&text=Hello%20The%20Reciprocal%20Solutions%20%F0%9F%91%8B%0A'));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(13.0),
                                child: Text(
                                    'Made in ❤ with The Reciprocal Solutions',
                                    style: sub.copyWith(
                                        color: Colors.blue.shade800),
                                    textAlign: TextAlign.center),
                              ),
                            )
                          ],
                        ),
                      );
              }
            }),
      ),
    );
  }
}
