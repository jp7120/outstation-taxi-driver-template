import 'dart:io';

import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:driver_app/auth/login.dart';
import 'package:driver_app/model/driverDetail.dart';
import 'package:driver_app/notification/setup.dart';
import 'package:driver_app/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

class UploadDocuments extends StatefulWidget {
  @override
  _UploadDocumentsState createState() => _UploadDocumentsState();
}

class _UploadDocumentsState extends State<UploadDocuments> {
  SharedPreferences preferences;

  BasicController controller = Get.put(BasicController());

  FirebaseUser user;

  String token = '';
  Future<void> _logout() async {
    /// Method to Logout the `FirebaseUser` (`_firebaseUser`)
    try {
      // signout code
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e);
    }
  }

  getlo() async {
    FirebaseUser str = controller.getCurrentUser();
    var tokenee = await getTokens();
    GeolocationStatus status =
        await Geolocator().checkGeolocationPermissionStatus();
    print(status == GeolocationStatus.granted);
    if (status != GeolocationStatus.granted) {
      Permission p = Permission.location;
      p.request();
    }
    Position pos = await Geolocator().getCurrentPosition();

    setState(() {
      user = str;
      token = tokenee;
      position = pos;
    });
    print(pos);
  }

  bool loading = false;
  List proofList = ['policy', 'rc', 'dl', 'pollution', 'permit', 'fitness'];
  List listTitle = [
    'Aadhar Card',
    'Driving License',
    'RC Copy',
    'Insurance ',
  ];

  File policy, rc, dl, pollution, permit, fitness;

  @override
  void initState() {
    super.initState();
    getlo();
  }

  uploadImage(File file, var name, int i) async {
    String down;
    String fileName = name;
    if (user != null) {
      StorageReference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('DriverProofs/${user.phoneNumber}/$fileName');
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(file);
      await uploadTask.onComplete.then((value) {
        value.ref.getDownloadURL().then((value) {
          print(value);
          proofList[i] = value;
          setState(() {
            down = value.toString();
          });
        });
      });
    } else {
      StorageReference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('DriverProofs/${'8797'}/$fileName');
      StorageUploadTask uploadTask = firebaseStorageRef.putFile(file);
      await uploadTask.onComplete.then((value) {
        value.ref.getDownloadURL().then((value) {
          print(value);
          proofList[i] = value;
          setState(() {
            down = value.toString();
          });
        });
      });
    }

    print(down);
    //return down;
  }

  openCamera(var index) async {
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 30);
    print(index);
    if (image != null) {
      listStatus[index] = true;
      switch (index) {
        case 0:
          policy = image;
          //var base64 = convertBase64Image(policy);

          String downUrl = await uploadImage(image, 'policy', index);
          print(downUrl);
          break;
        case 1:
          rc = image;
          var downUrl = await uploadImage(rc, 'rc', index);

          setState(() {
            proofList[index] = downUrl;
          });
          break;
        case 2:
          dl = image;
          var downUrl = uploadImage(dl, 'dl', index);

          proofList[index] = downUrl;
          break;
        case 3:
          pollution = image;
          var downUrl = uploadImage(pollution, 'pollution', index);

          proofList[index] = downUrl;
          break;
        case 4:
          permit = image;
          var downUrl = uploadImage(permit, 'permit', index);

          proofList[index] = downUrl;
          break;
        case 5:
          fitness = image;
          var downUrl = uploadImage(fitness, 'fitness', index);

          proofList[index] = downUrl;
          break;
      }
    } else {
      Fluttertoast.showToast(msg: 'Please select the image to continue');
    }
  }

  FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  TextEditingController name = TextEditingController(text: '');
  TextEditingController phone = TextEditingController(text: '');
  TextEditingController type = TextEditingController(text: '');
  TextEditingController regNo = TextEditingController(text: '');
  TextEditingController carName = TextEditingController(text: '');

  getLoc() async {
    Position pos = await Geolocator().getCurrentPosition();
    return pos;
  }

  getTokens() async {
    var token = await firebaseMessaging.getToken();
    return token;
  }

  Position position;

  onSubmit() async {
    var da = DateFormat().add_yMMMMEEEEd().add_Hms().format(DateTime.now());

    if (name.text.isNotEmpty &&
        listStatus[0] &&
        listStatus[1] &&
        listStatus[2] &&
        listStatus[3] &&
        carName.text.isNotEmpty &&
        regNo.text.isNotEmpty) {
      setState(() {
        loading = true;
      });
      await Firestore.instance
          .collection('DriverDetails')
          .document(user.uid)
          .setData({
        'name': name.text.toString(),
        'phoneNum': user.phoneNumber,
        'uid': user.uid,
        'amount': 0.0,
        'accountCreatedAt': da,
        'carType': currentType.toString(),
        'carNumber': regNo.text.toUpperCase().toString(),
        'carName': carName.text.toString(),
        'docsUploaded': true,
        'isAdminVerified': false,
        'disableDriver': false,
        'isOnline': false,
        'ratings': '4.3',
        'token': token,
        'location': position != null
            ? GeoPoint(position.latitude, position.longitude)
            : GeoPoint(11.127123, 78.656891),
        'profileImage':
            'https://thumbs.dreamstime.com/b/businessman-icon-vector-male-avatar-profile-image-profile-businessman-icon-vector-male-avatar-profile-image-182095609.jpg',
        'driverNativeLocation': {
          'country': countryValue.capitalizeFirst,
          'state': stateValue.capitalizeFirst,
          'district': cityValue.capitalizeFirst,
        },
        'proofs': {
          'userPhone': user.phoneNumber,
          'created_at': da,
          'aadharCopy': proofList[0].toString(),
          'dlCopy': proofList[1].toString(),
          'rcCopy': proofList[2].toString().length > 10
              ? proofList[2].toString()
              : 'Not provided',
          'insuranceCopy': proofList[3].toString().length > 10
              ? proofList[3].toString()
              : 'Not provided',
        }
      }).then((value) async {
        // await Firestore.instance
        //     .collection("AdminDetails")
        //     .document('allDetails')
        //     .updateData({
        //   'lastDriverCreatedAt': DateTime.now().toString(),
        //   'lastDriverCreatedName': name.text.toString(),
        //   'totalDrivers': FieldValue.increment(1)
        // });
        setState(() {
          loading = false;
        });

        controller.setCurrentDriver(DriverDetails(
            isOnline: false,
            uid: user.uid,
            isAdminVerified: false,
            amount: 0200,
            carNumber: regNo.text.toString().toUpperCase(),
            name: name.text.toString(),
            phoneNum: phone.text.toString(),
            docsUploaded: true));

        // Fluttertoast.showToast(msg: 'Database entry success');
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => DriverHomeScreen()));
      });
    } else if (phone.text.isEmpty)
      Fluttertoast.showToast(msg: 'Please enter your 10 digit number');
    else
      Fluttertoast.showToast(
          msg: 'Please select all the proofs to continue',
          textColor: Colors.white,
          backgroundColor: Colors.red);
  }

  List<bool> listStatus = [false, false, false, false, false, false];
  String countryValue;
  String stateValue;
  String cityValue;

  List carTypes = [
    ['Hatchback', 'Sedan', 'SUV']
  ];

  // var currentType = 'Hatchback';
  var currentType = 'SUV';

  @override
  Widget build(BuildContext context) {
    // print(user.phoneNumber);
    // getUserInfo();

    // setDocumentStatus();

    Size screenSize = MediaQuery.of(context).size;
    var height = screenSize.height;
    var width = screenSize.width;
    var defaultSize = height * 0.05;
    var defaultPadding = 16;
    print(name.text);
    return Scaffold(
      appBar: buildGradientAppBar('Registration'),
      floatingActionButton: FloatingActionButton.extended(
        label: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
              gradient: FlutterGradients.trueSunset(),
              boxShadow: [
                BoxShadow(
                    offset: Offset(0, 5), blurRadius: 10, spreadRadius: -5)
              ],
              borderRadius: BorderRadius.circular(40)),
          child: loading
              ? Center(
                  child: SpinKitThreeBounce(
                    size: 20,
                    color: Colors.white,
                  ),
                )
              : Row(
                  children: [
                    Text(
                      'Upload now',
                      style: title.copyWith(color: Colors.white, fontSize: 16),
                    ),
                    Icon(Icons.upload_file),
                  ],
                ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        // icon: Icon(Icons.upload_file),
        onPressed: loading != true
            ? onSubmit
            : () {
                onSubmit();
              },
        /*   onPressed: () {
          FirebaseAuth.instance.signOut();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (c) => PhoneAuthGetPhone()),
              (route) => false);
        }, */
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            buildTextField('name', name, ''),
            buildNumberTextField('phone', phone),
            // buildTextField('car type', type),
            Text('Choose the car type'),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                items:
                    <String>['Hatchback', 'Sedan', 'SUV'].map((String value) {
                  return new DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
                hint: Text('Choose the car type'),
                itemHeight: height * 0.1,
                isExpanded: true,
                value: currentType,
                onChanged: (s) {
                  setState(() {
                    currentType = s;
                  });
                  print(currentType);
                },
              ),
            ),
            buildTextField('car model', carName, 'Swift, Innova,...'),
            buildTextField('car number', regNo, 'TN34AX1234'),
            // SizedBox(height: defaultSize),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child:
                  /* CSCPicker(
                showFlag: false,
                layout: Layout.vertical,
                onCountryChanged: (value) {
                  setState(() {
                    countryValue = 'India';
                  });
                },
                onStateChanged: (value) {
                  setState(() {
                    stateValue = value;
                  });
                },
                onCityChanged: (value) {
                  setState(() {
                    cityValue = value;
                  });
                },
              ), */
                  SelectState(
                onCountryChanged: (value) {
                  setState(() {
                    countryValue = value;
                  });
                  print(countryValue.removeAllWhitespace.toString());
                },
                onStateChanged: (value) {
                  setState(() {
                    stateValue = value;
                  });
                },
                onCityChanged: (value) {
                  setState(() {
                    cityValue = value;
                  });
                },
              ),
            ),
            /*  InkWell(
                onTap: () {
                  print('country selected is $countryValue');
                  print('country selected is $stateValue');
                  print('country selected is $cityValue');
                },
                child: Text(' Check')), */
            buildSelectDocuments(height, width),
          ],
        ),
      ),
    );
  }

  Padding buildTextField(var label, var controller, var hint) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        maxLength: label == 'car number' ? 10 : null,
        controller: controller,
        textCapitalization: TextCapitalization.characters,
        decoration:
            InputDecoration(labelText: 'Enter $label', hintText: hint ?? ''),
      ),
    );
  }

  Padding buildNumberTextField(var label, var controller) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextFormField(
        maxLength: 10,
        keyboardType: TextInputType.number,
        controller: controller,
        decoration: InputDecoration(labelText: 'Enter $label'),
      ),
    );
  }

  Container buildSelectDocuments(double height, double width) {
    return Container(
      height: height * 0.7,
      width: width,
      padding: EdgeInsets.all(20),
      child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 1,
              childAspectRatio: 0.9,
              mainAxisSpacing: 1),
          itemCount: 4,
          itemBuilder: (c, i) {
            return InkWell(
              onTap: () {
                openCamera(i);
              },
              child: Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(listTitle[i]),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          height: 150,
                          width: 150,
                          child: listStatus[i]
                              ? getImage(i) //Image.memory(issad)
                              : Placeholder(),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Widget getImage(var index) {
    switch (index) {
      case 0:
        return Image.file(
          policy,
          fit: BoxFit.cover,
        );
        break;
      case 1:
        return Image.file(
          rc,
          fit: BoxFit.cover,
        );
        break;
      case 2:
        return Image.file(
          dl,
          fit: BoxFit.cover,
        );
        break;
      case 3:
        return Image.file(
          pollution,
          fit: BoxFit.cover,
        );
        break;
      case 4:
        return Image.file(
          permit,
          fit: BoxFit.cover,
        );
        break;
      case 5:
        return Image.file(
          fitness,
          fit: BoxFit.cover,
        );
        break;
      default:
        return CircularProgressIndicator();
    }
  }
}
