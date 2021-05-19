import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'package:smartsocietystaff/Common/Constants.dart' as cnst;
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/LoadingComponent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unique_identifier/unique_identifier.dart';

import 'OTP.dart';

ProgressDialog pr;

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController txtMobileNo = new TextEditingController();
  TextEditingController txtPassword = new TextEditingController();
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  StreamSubscription iosSubscription;

  var playerId;
  void _handleSendNotification() async {
    var status = await OneSignal.shared.getPermissionSubscriptionState();

    playerId = status.subscriptionStatus.userId;
    print("playerid");
    print(playerId);
  }

  @override
  void initState() {
    initPlatformState();
    _handleSendNotification();
    pr = new ProgressDialog(context, type: ProgressDialogType.Normal);
    pr.style(
        message: "Please Wait",
        borderRadius: 10.0,
        progressWidget: Container(
          padding: EdgeInsets.all(15),
          child: CircularProgressIndicator(
              //backgroundColor: cnst.appPrimaryMaterialColor,
              ),
        ),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.w600));
    if (Platform.isIOS) {
      iosSubscription =
          _firebaseMessaging.onIosSettingsRegistered.listen((data) {
            print("FFFFFFFF" + data.toString());
            // saveDeviceToken();
          });
      _firebaseMessaging
          .requestNotificationPermissions(IosNotificationSettings());
    } else {
      // saveDeviceToken();
    }
  }

  String fcmToken = "";
  saveDeviceToken() async {
    print("true");
    _firebaseMessaging.getToken().then((String token) {
      print("Original Token:$token");
      setState(() {
        fcmToken = token;
      });
      print("FCM Token : $token");
    });
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

  String _platformImei = 'Unknown';
  String uniqueId = "Unknown";
  Future<void> initPlatformState() async {
    String platformImei;
    String idunique;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // try {
    //   platformImei =
    //   await ImeiPlugin.getImei(shouldShowRequestPermissionRationale: false);
    //   List<String> multiImei = await ImeiPlugin.getImeiMulti();
    //   print(multiImei);
    //   idunique = await ImeiPlugin.getId();
    // } on PlatformException {
    //   platformImei = 'Failed to get platform version.';
    // }
    String  identifier =await UniqueIdentifier.serial;
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformImei = platformImei;
      uniqueId = identifier;
    });
    print("_platformImei");
    print(_platformImei);
    print("uniqueid");
    print(identifier);
  }

  checkLogin(String staffId) async {
    if (txtMobileNo.text != "" &&
        txtMobileNo.text != null ) {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          // pr.show();
          var data = {
            "mobileNo1" : txtMobileNo.text,
            // "fcmToken" : fcmToken,
            "DeviceType" : Platform.isAndroid ? "Android" : "IOS",
            "IMEI" : uniqueId,
            // "playerId" : playerId
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

              // await prefs.setString(
              //   Session.UserName,
              //   data[0]["UserName"].toString(),
              // );
              // await prefs.setString(
              //   Session.Password,
              //   data[0]["Password"].toString(),
              // );
              // await prefs.setString(
              //   Session.Role,
              //   data[0]["Role"].toString(),
              // );
              // data[0]["Role"].toString() == "Watchmen"
              //     ?
              Navigator.pushReplacementNamed(context, '/WatchmanDashboard');
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
    } else {
      showMsg("Please Fill All Details");
    }
  }

  List societyIds = [];
  List societyNames = [];

  getSocietyNames(String societyId) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Future res = Services.GetSocietyName(societyId);
        res.then((data) async {
          if (data != null && data.length > 0) {
                societyNames.add({
                  "societyName": data[0]["Name"],
                  "societyId": societyId
                });
                setState(() {
                  multipleSociety = true;
                });
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

  String selSociety,societyId,selectedSocietyId="";
  bool mobileNumberRegistered = false;
  bool multipleSociety = false;
  String selectedStaffId = "";

  @override
  Widget build(BuildContext context) {
    print(societyNames);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Image.asset("images/Logo.png",
                      width: 120.0, height: 120.0, fit: BoxFit.contain),
                  Padding(
                    padding: const EdgeInsets.only(bottom:40.0,top: 8.0),
                    child: Text("MYJINI",style: TextStyle(fontSize: 18,fontWeight: FontWeight.w600),),
                  ),
                  Container(
                    // margin: EdgeInsets.only(bottom: 10),
                    child: TextFormField(
                      controller: txtMobileNo,
                      maxLength: 10,
                      keyboardType: TextInputType.number,
                      scrollPadding: EdgeInsets.all(0),
                      decoration: InputDecoration(
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.black),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          prefixIcon: Icon(
                            Icons.supervised_user_circle,
                            //color: cnst.appPrimaryMaterialColor,
                          ),
                          hintText: "Mobile Number"),
                      style: TextStyle(color: Colors.black),
                      // onChanged: (String val){
                      //   if(val.length==10){
                      //     getSocietyId(val);
                      //   }
                      //   else{
                      //     setState(() {
                      //       multipleSociety = false;
                      //     });
                      //   }
    // },
                    ),
                  ),
                  multipleSociety ? Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 2,left: 10),
                    child: SizedBox(
                      height: 50,
                      child: DropdownButton(
                        hint: Text('Select Your Society'),
                        value: selSociety,
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        onChanged: (newValue) {
                          for(int i=0;i<societyNames.length;i++){
                            if(societyNames[i]["societyName"] == newValue){
                              for(int j=0;j<societyIds.length;j++){
                                if(societyNames[i]["societyId"] == societyIds[j]["societyId"]) {
                                  selectedStaffId = societyIds[j]["staffId"];
                              }
                            }}
                          }
                          setState(() {
                            selSociety = newValue;
                          });
                        },
                        isExpanded: true,
                        items: societyNames.map((val) {
                          societyNames.toSet().toList();
                          return DropdownMenuItem(
                            child: Text(val["societyName"]),
                            value: val["societyName"],
                          );
                        }).toList(),
                      ),
                    ),
                  ):Container(),

/*
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: TextFormField(
                      controller: txtPassword,
                      scrollPadding: EdgeInsets.all(0),
                      decoration: InputDecoration(
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.black),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          prefixIcon: Icon(
                            Icons.lock,
                            //color: cnst.appPrimaryMaterialColor,
                          ),
                          hintText: "Password"),
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
*/
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(top: 10),
                    height: 45,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0)),
                      color: cnst.appPrimaryMaterialColor,
                      minWidth: MediaQuery.of(context).size.width - 20,
                      onPressed: () {
                        if(selSociety == null && multipleSociety == true){
                          Fluttertoast.showToast(
                              msg: "Please Select Society",
                              backgroundColor: Colors.red,
                              gravity: ToastGravity.BOTTOM,
                              textColor: Colors.white);
                        }
                        else if(txtMobileNo.text != ''){
                          print(selectedStaffId);
                          checkLogin(selectedStaffId);
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => OTP(
                          //         mobileNo: txtMobileNo.text.toString(),
                          //         onSuccess: () {s
                          //           checkLogin(selectedStaffId);
                          //         },
                          //       ),
                          //     ));
                        }
                        else{
                          Fluttertoast.showToast(
                            msg: "Please Enter Mobile Number",
                            backgroundColor: Colors.red,
                            gravity: ToastGravity.BOTTOM,
                            textColor: Colors.white,
                          );
                        }
                      },
                      child: Text(
                        "SIGN IN",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17.0,
                            fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
