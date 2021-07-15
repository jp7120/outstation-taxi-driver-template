import 'dart:io';
import 'package:driver_app/maps/movement.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:driver_app/constants.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:driver_app/trips/landingFromNotification.dart';

class NotificationLaunch extends StatefulWidget {
  @override
  _NotificationLaunchState createState() => _NotificationLaunchState();
}

class _NotificationLaunchState extends State<NotificationLaunch> {
  FirebaseMessaging messaging = FirebaseMessaging();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    messaging.getToken().then((value) => print(value));

    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        /*  showNotification('New Trip from ' + message['data']['fromD'],
            " to " + message['data']['to']); */
        showMessgae(message);
        showNotification('New Trip from ' + message['data']['fromD'],
            " to " + message['data']['to']);

        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");

        var data = Map<String, dynamic>.from(message['data']);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FutureTrips(
                    from: message['data']['fromD'],
                    to: message['data']['to'],
                    data: data)));
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        showResumeNotification('New Trip from ' + message['data']['fromD'],
            " to " + message['data']['to']);
        var data = Map<String, dynamic>.from(message['data']);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FutureTrips(
                    from: message['data']['fromD'],
                    to: message['data']['to'],
                    data: data)));

        /*  showResumeNotification(
            message['notification']['title'], message['notification']['body']); */
      },
    );
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(url);
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future onSelectNotification(String payload) async {
    showDialog(
      context: context,
      builder: (_) {
        return new AlertDialog(
          title: Text("PayLoad"),
          content: Text("Payload : $payload"),
        );
      },
    );
  }

  void showNotification(String title, String body) async {
    await _demoNotification(title, body, 2.toString());
  }

  void showResumeNotification(String title, String body) async {
    await _demoResNotification(title, body, 5.toString());
  }

  Future<void> _demoResNotification(
      String title, String body, String id) async {
    // AndroidNotificationSound notificationSound = 'slow_spring_board';
    final String bigPicturePath = await _downloadAndSaveFile(
        Constants().notificationBigPicture, 'bigPicture');
    final String largeIconPath = await _downloadAndSaveFile(
        Constants().notificationLargeIcon, 'largeIcon');
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      contentTitle: ' <b>$title</b>  <b>$body</b> ',
      htmlFormatContentTitle: true,
      summaryText: 'Check it out and get assigned',
      htmlFormatSummaryText: true,
      largeIcon: FilePathAndroidBitmap(largeIconPath),
    );
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'default_notification_channel_id',
        'Customer Bookings',
        'all the booking notifications is here',
        importance: Importance.max,
        playSound: true,
        // sound: 'slow_spring_board',
        styleInformation: bigPictureStyleInformation,
        priority: Priority.high,
        // vibrationPattern: vibrationPattern,
        enableLights: true,
        sound: RawResourceAndroidNotificationSound('sounds'),
        color: const Color.fromARGB(255, 255, 0, 0),
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        icon: 'logo',
        enableVibration: true,
        maxProgress: 50,
        category: 'Customer Bookings',
        channelShowBadge: true,
        ledOffMs: 500,
        ticker: 'test ticker');

    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails();
    platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSChannelSpecifics);
    // androidPlatformChannelSpecifics, iOSChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(5, title, body, platformChannelSpecifics, payload: 'test');
  }

  Future<void> _demoNotification(String title, String body, String id) async {
    // AndroidNotificationSound notificationSound = 'slow_spring_board';
    final String bigPicturePath = await _downloadAndSaveFile(
        Constants().notificationBigPicture, 'bigPicture');
    final String largeIconPath = await _downloadAndSaveFile(
        Constants().notificationLargeIcon, 'largeIcon');
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      contentTitle: ' <b>$title</b>  <b>$body</b> ',
      htmlFormatContentTitle: true,
      summaryText: 'Check it out and get assigned',
      htmlFormatSummaryText: true,
      largeIcon: FilePathAndroidBitmap(largeIconPath),
    );

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'default_notification_channel_id',
        'Customer Bookings',
        'all the booking notifications is here',
        importance: Importance.max,
        playSound: true,

        // sound: 'slow_spring_board',
        styleInformation: bigPictureStyleInformation,
        priority: Priority.high,
        // vibrationPattern: vibrationPattern,
        enableLights: true,
        sound: RawResourceAndroidNotificationSound('sounds'),
        color: const Color.fromARGB(255, 255, 0, 0),
        ledColor: const Color.fromARGB(255, 255, 0, 0),
        ledOnMs: 1000,
        icon: 'logo',
        enableVibration: true,
        maxProgress: 50,
        category: 'Customer Bookings',
        channelShowBadge: true,
        ledOffMs: 500,
        ticker: 'test ticker');

    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails();
    platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics, iOS: iOSChannelSpecifics);
    // androidPlatformChannelSpecifics, iOSChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(1, title, body, platformChannelSpecifics, payload: 'test');
  }

  showMessgae(var message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: ListTile(
          title: Text(message['notification']['title']),
          subtitle: Text(message['notification']['body']),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //TITLE GOES HERE
        title: Text(
          'TRS TAXI DRIVER',
          style: title.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(
            child: Text(
              'Welcome to Driver App',
              style: sub,
            ),
          ),
          RaisedButton(
            child: Text('View All Bookings'),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => FutureTrips()));
            },
          ),
          RaisedButton(
            child: Text('Driver Tracking'),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RidingMode()));
            },
          )
        ],
      ),
    );
  }
}
