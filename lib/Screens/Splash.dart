import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
// import 'package:device_info/device_info.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as constant;
import 'package:mobile_number/mobile_number.dart';
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:unique_identifier/unique_identifier.dart';

import 'WatchmanDashboard.dart';

class PermissionsService {
  final PermissionHandler permissionHandler = PermissionHandler();
}

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  String _mobileNumber = '';
  List<SimCard> _simCard = <SimCard>[];
  String called;

  @override
  void initState() {
    Timer(Duration(seconds: 1), () async {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      var release = androidInfo.version.release;
      print("release");
      print(release);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String MemberId = prefs.getString(constant.Session.MemberId);
      String Role = prefs.getString(constant.Session.Role);
      // constant.NODE_API = "http://3.7.94.50/";
      // constant.IMG_URL = "http://3.7.94.50/";
      //   if (MemberId != null && MemberId != "") {
      //     Navigator.pushReplacementNamed(context, '/WatchmanDashboard');
      //   }
      //   else {
      //     PermissionHandler().requestPermissions(
      //       [
      //         PermissionGroup.camera,PermissionGroup.microphone,PermissionGroup.phone,PermissionGroup.location
      //       ],
      //     );
      //     initMobileNumberState();
      //     // Navigator.pushReplacementNamed(context, '/Login');
      //   }
      FirebaseFirestore.instance.collection("DYNAMIC-URL-MYJINI-MEMBER-APP")
          .get()
          .then((value) async {
        // constant.NODE_API = "https://myjini.herokuapp.com/";
        //constant.NODE_API_2 = "https://myjini2.herokuapp.com/";

        constant.NODE_API = "${value.docs[0]["DYNAMIC-URL-MYJINI-MEMBER-APP"]}";
        constant.IMG_URL = "${value.docs[0]["DYNAMIC-URL-MYJINI-MEMBER-APP"]}";
        print("constant.NODE_API");
        print(constant.NODE_API);
        if (MemberId != null && MemberId != "")
          Navigator.pushReplacementNamed(context, '/WatchmanDashboard');
        else{
          // called = prefs.getString(constant.Session.called);
          // bool calledfirst = true;
          // print("called"); // for android 11
          // print(called);
          // prefs.setString(constant.Session.called, calledfirst.toString());
          // initMobileNumberState();
          initMobileNumberState();
        }
      });
    });
  }

  final PermissionHandler _permissionHandler = PermissionHandler();

  Future<bool> _requestPermission() async {
    // var result = await _permissionHandler.requestPermissions([
    //   PermissionGroup.phone,
    //   PermissionGroup.camera,
    //   PermissionGroup.microphone]);
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.phone);
    if (permission == PermissionStatus.granted) {
      PermissionStatus permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.camera);
      if (permission == PermissionStatus.granted) {
        PermissionStatus permission = await PermissionHandler()
            .checkPermissionStatus(PermissionGroup.microphone);
        if(permission == PermissionStatus.granted){
          return true;
        }
        else{
          return false;
        }
      }
    }
  }

  Future<bool> requestPermissions({Function onPermissionDenied}) async {
    var granted = await _requestPermission();
    if (!granted) {
      onPermissionDenied();
    }
    return granted;
  }

  // Future<bool> _requestPermission() async {
  //    // _permissionHandler.requestPermissions(await [PermissionGroup.camera,PermissionGroup.phone]);
  //   // if (result == PermissionStatus.granted) {
  //   //   return true;
  //   // }
  //   // return false;
  // }

  Future<void> initMobileNumberState() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // print("prefs.getString(constant.Session.called)");
    // print(prefs.getString(constant.Session.called));// for android 11
    // print(prefs.getString(constant.Session.called).runtimeType);
    // if(prefs.getString(constant.Session.called) == 'true') {
    //   prefs.setString(constant.Session.called, 'null');
      String mobileNumber = '';
      try {
        // if (!await MobileNumber.hasPhonePermission) {
        //   await MobileNumber.requestPhonePermission;
        //   return;// for android 11
        // }
        mobileNumber = (await MobileNumber.mobileNumber);
        _simCard = (await MobileNumber.getSimCards);
        print("_simCard");
        print(_simCard);
        _simCard.forEach((e) {
          print("e.number");
          print(e.toMap());
          var mobileNo;
          if (!e.number.contains("+") && e.number.length == 12) {
            getMobileNumbers("+" + "${e.number}");
          }
          else if (!e.number.contains("+") && e.number.length == 10) {
            getMobileNumbers("+91" + "${e.number}");
          }
          else {
            getMobileNumbers("${e.number}");
          }
        });
      } on PlatformException catch (e) {
        debugPrint("Failed to get mobile number because of '${e.message}'");
      }

      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;

      setState(() {
        _mobileNumber = mobileNumber;
      });
    // }
  }

  var playerId;
  void _handleSendNotification(String mobileNo) async {
    var status = await OneSignal.shared.getPermissionSubscriptionState();

    playerId = status.subscriptionStatus.userId;
    print("playerid");
    print(playerId);
    checkLogin(mobileNo);
  }

  String _platformImei = 'Unknown';
  String uniqueId = "Unknown";
  Future<void> initPlatformState(String mobileNo) async {
    String platformImei;
    String  identifier =await UniqueIdentifier.serial;
    if (!mounted) return;

    setState(() {
      _platformImei = platformImei;
      uniqueId = identifier;
    });
    _handleSendNotification(mobileNo);
  }

  showMsg(String msg, {String title = 'MYJINI'}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {

        return AlertDialog(
          title: new Text(title),
          content: new Text(msg),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Okay"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  checkLogin(String mobileNo) async {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          var data = {
            "mobileNo1" : mobileNo,
            "DeviceType" : Platform.isAndroid ? "Android" : "IOS",
            "IMEI" : uniqueId,
          };
          print("data");
          print(data);
          Services.responseHandler(apiName: "watchman/login",body: data).then((data) async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            if (data.Data != null && data.Data.length > 0) {
              // pr.hide();
              await prefs.setString(
                Session.MemberId,
                data.Data[0]["_id"].toString(),
              );
              await prefs.setString(
                Session.societyName,
                data.Data[0]["SocietyData"][0]["Name"].toString(),
              );
              await prefs.setString(
                Session.RoleId,
                data.Data[0]["RoleId"].toString(),
              );
              await prefs.setString(
                Session.mobileNo,
                data.Data[0]["ContactNo1"].toString(),
              );

              await prefs.setString(
                Session.SocietyId,
                data.Data[0]["societyId"].toString(),
              );
              await prefs.setString(
                Session.Name,
                data.Data[0]["Name"].toString(),
              );
              await prefs.setString(
                Session.WingId,
                data.Data[0]["wingId"].toString(),
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WatchmanDashboard(societyName : ""),
                ),
              );
              // Navigator.pushReplacementNamed(context, '/WatchmanDashboard');
              // : Navigator.pushReplacementNamed(context, '/Dashboard');
            } else {
              // pr.hide();
              showMsg("Invalid login Detail.");
            }
          }, onError: (e) {
            // pr.hide();
            print("Error : on Login Call $e");
            showMsg("Something Went Wrong Please Try Again");
          });
        } else {
          // pr.hide();
          showMsg("No Internet Connection.");
        }
      } on SocketException catch (_) {
        showMsg("No Internet Connection.");
      }
  }

  bool mobileNoFound = false;
  getMobileNumbers(String mobileNo) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var body = {};
        Services.responseHandler(apiName: "watchman/getAllWatchmanMobileNo",body: body).then((data) async {
          if (data.Data.length > 0) {
            for(int i=0;i<data.Data.length;i++){
              if(mobileNo.toString() == data.Data[i]["ContactNo1"].toString()){
                var androidInfo = await DeviceInfoPlugin().androidInfo;
                var release = androidInfo.version.release;
                print("release");
                print(release);
                if(int.parse(release) < 11) {
                  PermissionHandler().requestPermissions(
                    [
                      PermissionGroup.camera,
                      PermissionGroup.microphone,
                      PermissionGroup.location
                    ],
                  );
                }
                mobileNoFound = true;
                initPlatformState(data.Data[i]["ContactNo1"].toString().replaceRange(0, 3, ""));
                break;
              }
            }
            // if(!mobileNoFound){
            //   Fluttertoast.showToast(
            //       msg: "Your Mobile Number ${mobileNo} is not Registered", toastLength: Toast.LENGTH_LONG);
            // }
          }
        }, onError: (e) {
          Fluttertoast.showToast(
              msg: "$e", toastLength: Toast.LENGTH_LONG);
        });
      } else {
        Fluttertoast.showToast(
            msg: "No Internet Connection.", toastLength: Toast.LENGTH_LONG);
      }
    } on SocketException catch (_) {
      Fluttertoast.showToast(
          msg: "Something Went Wrong", toastLength: Toast.LENGTH_LONG);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Image.asset(
                'images/background.png',
                fit: BoxFit.fill,
              )),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 60, right: 40, left: 60),
                child: Image.asset(
                  'images/gini.png',
                  height: MediaQuery.of(context).size.height / 1.6,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Image.asset(
                  'images/myginitext.png',
                  height: 100,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
