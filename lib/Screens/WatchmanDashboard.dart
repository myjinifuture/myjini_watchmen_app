import 'dart:async';
import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization_delegate.dart';
import 'package:easy_localization/easy_localization_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info/package_info.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Common/join.dart';
import 'package:smartsocietystaff/Component/NotificationAnswerDialog.dart';
import 'package:smartsocietystaff/Component/masktext.dart';
import 'package:smartsocietystaff/Screens/AddVisitorForm.dart';
import 'package:smartsocietystaff/Screens/EnterCodeScanScreen.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as constant;
import 'package:smartsocietystaff/Screens/FreqVisitorlist.dart';
import 'package:smartsocietystaff/Screens/Visitor.dart';
import 'package:smartsocietystaff/Screens/watchmanVisitorList.dart';
import 'package:unique_identifier/unique_identifier.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

import 'FromMemberScreen.dart';

const APP_STORE_URL =
    'https://play.google.com/store/apps/details?id=com.itfuturz.mygenie_staff';
const PLAY_STORE_URL =
    'https://play.google.com/store/apps/details?id=com.itfuturz.mygenie_staff';

class WatchmanDashboard extends StatefulWidget {
  @override
  _WatchmanDashboardState createState() => _WatchmanDashboardState();
}

class _WatchmanDashboardState extends State<WatchmanDashboard> {
  DateTime currentBackPressTime;
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  StreamSubscription iosSubscription;
  ProgressDialog pr;
  bool isLoading = false;
  List _visitordata = [];

  String barcode = "";
  String fcmToken = "";
  TextEditingController txtvehicle = new TextEditingController();

  Future<void> initOneSignalNotification() async {
    OneSignal.shared.setNotificationOpenedHandler((
        OSNotificationOpenedResult result) async {
      print("Opened notification");
      print(result.notification.jsonRepresentation().replaceAll("\\n", "\n"));
      print(result.notification.payload.additionalData);
      dynamic data = result.notification.payload.additionalData;
      Vibration.vibrate(
        duration: 700,
      );
      if (data["NotificationType"] == 'VisitorAccepted') {
        Get.to(NotificationAnswerDialog(data,VisitorAccepted:"VisitorAccepted"));
      }
      else if (data["NotificationType"] == 'VisitorRejected') {
        Get.to(NotificationAnswerDialog(data,VisitorAccepted:"VisitorRejected"));

      }
      else if(data["CallResponseIs"] == 'Rejected') {
        Get.to(FromMemberScreen(rejected: "Rejected",));
      }
      else if (data["NotificationType"] == 'VisitorAccepted') {
        Get.to(NotificationAnswerDialog(data,VisitorAccepted:"VisitorAccepted"));
      }
      else if (data["NotificationType"] == 'VisitorRejected') {
        Get.to(NotificationAnswerDialog(data,VisitorAccepted:"VisitorRejected"));
      }
      else if(data["NotificationType"] == 'VoiceCall') {
        Get.to(JoinPage(entryIdWhileGuestEntry: data["CallingId"],voicecall : data["NotificationType"]));        // audioCache.play('Sound.mp3');
      }
      else if (data["NotificationType"]== 'VideoCalling') {
        Get.to(JoinPage(entryIdWhileGuestEntry:data["VisitorEntryId"],data: data,CallingId:data["CallingId"]));
      }
      else if (data["notificationType"] == 'UnknownVisitor') {
        if(data["CallStatus"] == "Accepted") {
          Get.to(JoinPage(
            unknownVisitorEntryId: data["EntryId"],
          ),
          );
        }
        else{
          Get.to(NotificationAnswerDialog(data));
        }

      }
      else if (data["NotificationType"] == 'Visitor') {
        Get.to(
          JoinPage(
            entryIdWhileGuestEntry: data["VisitorEntryId"],
            data: data,
            CallingId:data["CallingId"],
          ),
        );
      }
      else if (data["Type"] == 'Accepted') {
        Get.to(JoinPage());
      }
      else {
        Get.to(NotificationAnswerDialog(data));
      }
    });
  }

  var playerId;
  void _handleSendNotification() async {
    var status = await OneSignal.shared.getPermissionSubscriptionState();

    playerId = status.subscriptionStatus.userId;
    print("playerid");
    print(playerId);
    updateMemberPlayerId(WatchManId, mobileNo, playerId, uniqueId);
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
    _handleSendNotification();
  }

  @override
  void initState() {
    initOneSignalNotification();
    _getLocaldata();
    try {
      versionCheck(context);
    } catch (e) {
      print(e);
    }
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
        saveDeviceToken();
      });
      _firebaseMessaging
          .requestNotificationPermissions(IosNotificationSettings());
    } else {
      saveDeviceToken();
    }
  }

  updateMemberPlayerId(String watchmanId,String mobileNo,String playerId,String IMEI) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          "watchmanId": watchmanId,
          "mobileNo1": mobileNo,
          "playerId": playerId,
          "IMEI": IMEI,
          "DeviceType": Platform.isAndroid ? "Android" : "IOS"
        };
        print("data during update");
        print(data);
        Services.responseHandler(apiName: "watchman/updateWatchmanPlayerId", body: data)
            .then((data) async {
          print("data");
          print(data);
        }, onError: (e) {
          showMsg("Something Went Wrong.\nPlease Try Again");
          setState(() {
            isLoading = false;
          });
        });
      }
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
    }
  }

  saveDeviceToken() async {
    _firebaseMessaging.getToken().then((String token) {
      print("Original Token:$token");
      setState(() {
        fcmToken = token;
        // sendFCMTokan(token);
      });
      print("FCM Token : $token");
    });
  }

  versionCheck(context) async {
    //Get Current installed version of app
    final PackageInfo info = await PackageInfo.fromPlatform();
    double currentVersion = double.parse(info.version.trim().replaceAll(".", ""));

    //Get Latest version info from firebase config
    final RemoteConfig remoteConfig = await RemoteConfig.instance;

    try {
      // Using default duration to force fetching from remote server.
      await remoteConfig.fetch(expiration: const Duration(seconds: 0));
      await remoteConfig.activateFetched();
      remoteConfig.getString('force_update_current_version');
      double newVersion = double.parse(remoteConfig
          .getString('force_update_current_version')
          .trim()
          .replaceAll(".", ""));
      print("newversion");
      print(newVersion);
      print("currentVersion");
      print(currentVersion);

      if (newVersion > currentVersion) {
        _showVersionDialog(context);
      }
    } on FetchThrottledException catch (exception) {
      // Fetch throttled.
      print(exception);
    } catch (exception) {
      print('Unable to fetch remote config. Cached or default values will be '
          'used');
    }
  }

  _showVersionDialog(context) async {
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "New Update Available";
        String message =
            "There is a newer version of app available please update it now.";
        String btnLabel = "Update Now";
        String btnLabelCancel = "Later";
        return Platform.isIOS
            ? new CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text(btnLabel),
              onPressed: () => launch(APP_STORE_URL),
            ),
            FlatButton(
              child: Text(btnLabelCancel),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        )
            : new AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text(btnLabel),
              onPressed: () => launch(PLAY_STORE_URL),
            ),
            FlatButton(
              child: Text(btnLabelCancel),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  sendFCMTokan(var FcmToken) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Future res = Services.SendTokanToServer(FcmToken);
        res.then((data) async {}, onError: (e) {
          print("Error : on Login Call");
        });
      }
    } on SocketException catch (_) {}
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "Press Back Again to Exit");
      return Future.value(false);
    }
    return Future.value(true);
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  // Overridden methods

  // API List

  // _getVisitorData(String VisitorId, String type) async {
  //   try {
  //     final result = await InternetAddress.lookup('google.com');
  //     if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
  //       SharedPreferences preferences = await SharedPreferences.getInstance();
  //       String SocietyId = preferences.getString(Session.SocietyId);
  //       // pr.show();
  //       Future res =
  //           Services.getScanVisitorByQR_or_Code(SocietyId, type, "", VisitorId);
  //       setState(() {
  //         isLoading = true;
  //       });
  //       res.then((data) async {
  //         // pr.hide();
  //         if (data != null && data.length > 0) {
  //           setState(() {
  //             _visitordata = data;
  //             isLoading = false;
  //           });
  //           _showVisitorData(data);
  //         } else {
  //           setState(() {
  //             _visitordata = data;
  //             isLoading = false;
  //           });
  //           //showMsg("Data Not Found");
  //         }
  //       }, onError: (e) {
  //         // pr.hide();
  //         showMsg("Something Went Wrong Please Try Again");
  //         setState(() {
  //           isLoading = false;
  //         });
  //       });
  //     } else {
  //       showMsg("No Internet Connection.");
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //   } on SocketException catch (_) {
  //     // pr.hide();
  //     showMsg("No Internet Connection.");
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  String entryNo;
  _getVisitorData(String entryNo,String watchmenId,bool isGuest,{String vehicleNo}) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // // pr.show();
        entryNo = entryNo;
        FormData formData = new FormData.fromMap({
          "entryNo": entryNo,
          "watchmanId": watchmenId,
          "vehicleNo": vehicleNo,
          "deviceType" : Platform.isAndroid ? "Android" : "IOS",
          "societyId" : societyId
        });
        print({
          "entryNo": entryNo,
          "watchmanId": watchmenId,
          "vehicleNo": vehicleNo,
          "deviceType" : Platform.isAndroid ? "Android" : "IOS",
          "societyId" : societyId
        });
        setState(() {
          isLoading = true;
        });
        Services.responseHandler(apiName: "watchman/addVisitorEntry",body: formData).then((data) async {
          // // pr.hide();
          print("message");
          print(data.Data);
          if(isGuest){
            if(data.Data.toString() == "1"){
              Fluttertoast.showToast(
                  msg: "Guest Left Successfully!!",
                  backgroundColor: Colors.green,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.white);
            }
            else if(isGuest && data.Data.length > 0) {
              _showVisitorData(data.Data);
              setState(() {
                _visitordata = data.Data;
                isLoading = false;
              });
            }
            else{
              Fluttertoast.showToast(
                  msg: "Please enter correct code!!",
                  backgroundColor: Colors.red,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.white);
            }
          }
          else{
            if(data.Data.toString() == "1"){
              Fluttertoast.showToast(
                  msg: "Staff Left Successfully!!",
                  backgroundColor: Colors.green,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.white);
            }
            else if(data.Data.length == 0) {
              Fluttertoast.showToast(
                  msg: "Please enter correct code!!",
                  backgroundColor: Colors.red,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.white);
            }
            else{
              Fluttertoast.showToast(
                  msg: "Staff Added Successfully!!",
                  backgroundColor: Colors.green,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.white);
            }
          }

        }, onError: (e) {
          // pr.hide();
          showMsg("Something Went Wrong Please Try Again");
          setState(() {
            isLoading = false;
          });
        });
      } else {
        showMsg("No Internet Connection.");
        setState(() {
          isLoading = false;
        });
      }
    } on SocketException catch (_) {
      // pr.hide();
      showMsg("No Internet Connection.");
      setState(() {
        isLoading = false;
      });
    }
  }
  // _addVisitorEntry() async {
  //   try {
  //     final result = await InternetAddress.lookup('google.com');
  //     if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
  //       SharedPreferences preferences = await SharedPreferences.getInstance();
  //       String SocietyId = preferences.getString(Session.SocietyId);
  //
  //       // pr.show();
  //
  //       print('_visitordata[0]["lastentry"].toString().isNotEmpty');
  //       print(_visitordata[0]["lastentry"].isNotEmpty);
  //       var formData = {
  //         "Id": "0",
  //         "SocietyId": SocietyId,
  //         "TypeId": _visitordata[0]["lastentry"].isNotEmpty  ?  _visitordata[0]["lastentry"]["TypeId"] : "",
  //         "Type": _visitordata[0]["lastentry"].isNotEmpty ? _visitordata[0]["lastentry"]["Type"] : "",
  //         "Purpose": "",
  //         "VehicleNo": txtvehicle.text,
  //         "WorkId": _visitordata[0]["worklist"]
  //       };
  //
  //       Services.CheckInVisitorStaff(formData).then((data) async {
  //         // pr.hide();
  //         if (data.Data != "0" && data.IsSuccess == true) {
  //           Fluttertoast.showToast(
  //               msg: "Visitor CheckIn Successfully",
  //               backgroundColor: Colors.green,
  //               gravity: ToastGravity.TOP,
  //               textColor: Colors.white);
  //         } else {
  //           showMsg(data.Message, title: "Error");
  //         }
  //       }, onError: (e) {
  //         // pr.hide();
  //         showMsg("Try Again.");
  //       });
  //     }
  //   } on SocketException catch (_) {
  //     // pr.hide();
  //     showMsg("No Internet Connection.");
  //   }
  // }

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

  // Future scan() async {
  //   try {
  //     String barcode = await BarcodeScanner.scan();
  //     print(barcode);
  //     var data = barcode.split(",");
  //     if (barcode != null) {
  //       _getVisitorData(data[0], data[1]);
  //     } else
  //       showMsg("Try Again..");
  //   } on PlatformException catch (e) {
  //     if (e.code == BarcodeScanner.CameraAccessDenied) {
  //       setState(() {
  //         this.barcode = 'The user did not grant the camera permission!';
  //       });
  //     } else {
  //       setState(() => this.barcode = 'Unknown error: $e');
  //     }
  //   } on FormatException {
  //     setState(() => this.barcode =
  //         'null (User returned using the "back"-button before scanning anything. Result)');
  //   } catch (e) {
  //     setState(() => this.barcode = 'Unknown error: $e');
  //   }
  // }

  String WatchManId,societyId,mobileNo;
  _getLocaldata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    WatchManId = prefs.getString(constant.Session.MemberId);
    societyId = prefs.getString(constant.Session.SocietyId);
    mobileNo = prefs.getString(constant.Session.mobileNo);
    initPlatformState();
  }

  Future scan() async {
    String defaultType = "Visitor";
    try {
      String barcode = await BarcodeScanner.scan();
      print(barcode);
      var data = barcode.split(",");
      if(data[0].split("-")[0]=="GUEST")
        _getVisitorData(data[0].split("-")[1],WatchManId,true);
      else
        _getVisitorData(data[0],WatchManId,false);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcode =
      'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }
 /* void _showVisitorData(data) {

    showDialog(
      context: context,
      builder: (BuildContext context) {

        return AlertDialog(
          elevation: 0,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
                child: ClipOval(
                    child: FadeInImage.assetNetwork(
                        placeholder: 'images/Logo.png',
                        image: constant.IMG_URL + "${data[0]["Image"]}",
                        width: 100,
                        height: 100,
                        fit: BoxFit.fill)),
              ),
              Text(
                "${data[0]["Name"]}",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700]),
              ),
              Text(
                "${data[0]["ContactNo"]}",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[700]),
              ),
              Divider(
                color: Colors.grey[300],
                endIndent: 10,
                indent: 10,
                height: 1,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
//                        Text(
//                          "VisitorType",
//                          style: TextStyle(
//                              fontSize: 12,
//                              fontWeight: FontWeight.w600,
//                              color: Colors.grey[700]),
//                        ),
//                        Text(
//                          "${data[0]["VisitorTypeName"]}",
//                          style: TextStyle(
//                              fontSize: 13,
//                              fontWeight: FontWeight.w400,
//                              color: Colors.grey[700]),
//                        ),
                      ],
                    ),
                   *//* Row(
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Company\n Name",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700]),
                            ),
                            Text(
                              "${data[0]["CompanyName"]}",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ],
                    )*//*
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: Row(
                  children: <Widget>[
                   *//* Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Purpose of Visit",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700]),
                        ),
                        Text(
                          "${data[0]["Purpose"]}",
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[700]),
                        ),
                      ],
                    ),*//*
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  height: 50,
                  width: 150,
                  color: Colors.grey[200],
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            "Vehicle No",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700]),
                          ),
                        ),
                        Text(
                          "${data[0]["VehicleNo"]}",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  RaisedButton(
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.red,
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                  RaisedButton(
                      child: Text(
                        "OK",
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Colors.green,
                      onPressed: () {
                        Navigator.pop(context);
                        _addVisitorEntry();
                      })
                ],
              )
            ],
          ),
        );
      },
    );
  }*/

  // void _showVisitorData(data) {
  //
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //
  //       return Dialog(
  //         child: SingleChildScrollView(
  //           child: Column(
  //             children: <Widget>[
  //               Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: ClipOval(
  //                     child: FadeInImage.assetNetwork(
  //                         placeholder: 'images/Logo.png',
  //                         image: constant.IMG_URL + "${data[0]["Image"]}",
  //                         width: 100,
  //                         height: 100,
  //                         fit: BoxFit.fill)),
  //               ),
  //               Text(
  //                 "${data[0]["Name"]}",
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.w600,
  //                     color: Colors.grey[700]),
  //               ),
  //               Text(
  //                 "${data[0]["Role"]}",
  //                 style: TextStyle(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.w400,
  //                     color: Colors.grey[700]),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.all(10.0),
  //                 child: SizedBox(
  //                   height: 50,
  //                   child: TextFormField(
  //                     inputFormatters: [
  //                       MaskedTextInputFormatter(
  //                         mask: 'xx-xx-xx-xxxx',
  //                         separator: '-',
  //                       ),
  //                     ],
  //                     controller: txtvehicle,
  //                     keyboardType: TextInputType.text,
  //                     textCapitalization: TextCapitalization.characters,
  //                     decoration: InputDecoration(
  //                         border: new OutlineInputBorder(
  //                           borderRadius: new BorderRadius.circular(5.0),
  //                           borderSide: new BorderSide(),
  //                         ),
  //                         counterText: "",
  //                         labelText: "Enter Vehicle Number",
  //                         hintText: "XX-00-XX-0000",
  //                         hasFloatingPlaceholder: true,
  //                         labelStyle: TextStyle(fontSize: 13)),
  //                   ),
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.all(8.0),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                   children: <Widget>[
  //                     RaisedButton(
  //                         child: Text(
  //                           "Cancel",
  //                           style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),
  //                         ),
  //                         color: Colors.red[600],
  //                         onPressed: () {
  //                           Navigator.pop(context);
  //                         }),
  //                     RaisedButton(
  //                         child: Text(
  //                           "Check In",
  //                           style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),
  //                         ),
  //                         color: Colors.green,
  //                         onPressed: () {
  //                           Navigator.pop(context);
  //                           _addVisitorEntry();
  //                         })
  //                   ],
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  _addVehicleDetailOfGuest(String guestId,String vehicleNo) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // pr.show();
        var data = {
          "guestEntryId": guestId,
          "vehicleNo":vehicleNo
        };
        Services.responseHandler(apiName: "watchman/addGuestVehicle",body: data).then((data) async {
          // pr.hide();
          if (data.Data != null && data.Data.toString() == "1") {
            Fluttertoast.showToast(
                msg: "Guest Added Successfully!!",
                backgroundColor: Colors.green,
                gravity: ToastGravity.TOP,
                textColor: Colors.white);
          } else {
            //showMsg("Data Not Found");
          }
        }, onError: (e) {
          // pr.hide();
          showMsg("Something Went Wrong Please Try Again");
        });
      } else {
        showMsg("No Internet Connection.");

      }
    } on SocketException catch (_) {
      // pr.hide();
      showMsg("No Internet Connection.");

    }
  }

  void _showVisitorData(data) {
    // print('ssssssssssssssss${data[0]["Role"].runtimeType}');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipOval(
                      child: FadeInImage.assetNetwork(
                          placeholder: 'images/Logo.png',
                          image: constant.IMG_URL + "${data[0]["guestImage"]}",
                          width: 100,
                          height: 100,
                          fit: BoxFit.fill)),
                ),
                Text(
                  "${data[0]["Name"]}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700]),
                ),
                Text(
                  (data[0]["Role"] != null) ? "${data[0]["Role"]}" : "Visitor",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[700]),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: 50,
                    child: TextFormField(
                      inputFormatters: [
                        MaskedTextInputFormatter(
                          mask: 'xx-xx-xx-xxxx',
                          separator: '-',
                        ),
                      ],
                      controller: txtvehicle,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(5.0),
                            borderSide: new BorderSide(),
                          ),
                          counterText: "",
                          labelText: "Enter Vehicle Number",
                          hintText: "XX-00-XX-0000",
                          hasFloatingPlaceholder: true,
                          labelStyle: TextStyle(fontSize: 13)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      RaisedButton(
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                          color: Colors.red[600],
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              txtvehicle.text = '';
                            });
                          }),
                      RaisedButton(
                          child: Text(
                            "Check In",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                          color: Colors.green,
                          onPressed: () {
                            Navigator.pop(context);
                            _addVehicleDetailOfGuest(data[0]["_id"],txtvehicle.text);
                            setState(() {
                              txtvehicle.text = '';
                            });
                          })
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    var data = EasyLocalizationProvider.of(context).data;
    return EasyLocalizationProvider(
      data: data,
      child: WillPopScope(
        onWillPop: onWillPop,
        child: DefaultTabController(
          length: 2,
          child: new Scaffold(
              appBar: new AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: constant.appPrimaryMaterialColor,
                flexibleSpace: new Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    new TabBar(
                      tabs: [
                        Tab(
                          child: Column(
                            children: <Widget>[
                              new Icon(Icons.keyboard, size: 20),
                              new SizedBox(
                                width: 5.0,
                              ),
                              new Text(
                                "${AppLocalizations.of(context).tr('EnterCode')}",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        /*Tab(
                          child: Column(
                            children: <Widget>[
                              new Icon(
                                Icons.person,
                                size: 20,
                              ),
                              new SizedBox(
                                width: 5.0,
                              ),
                              new Text(
                                "${AppLocalizations.of(context).tr('FeqVisitor')}",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),*/
                        Tab(
                          child: Column(
                            children: <Widget>[
                              new Icon(
                                Icons.people,
                                size: 20,
                              ),
                              new SizedBox(
                                width: 5.0,
                              ),
                              new Text(
                                "${AppLocalizations.of(context).tr('Visitor')}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    EnterCodeScanScreen(data),
                    // FreqVisitorlist(),
                    visitorlist(),
                  ]),
              bottomNavigationBar: Container(
                height: 60,
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: InkWell(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.person_add),
                              Text(
                                  "${AppLocalizations.of(context).tr('AddVisitor')}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11))
                            ],
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/AddVisitorForm');
                          },
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: InkWell(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                'images/scanner.png',
                                width: 24,
                                height: 24,
                              ),
                              Text(
                                  "${AppLocalizations.of(context).tr('ScanCode')}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11))
                            ],
                          ),
                          onTap: () {
                            scan();
                          },
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: InkWell(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.supervised_user_circle),
                              Text(
                                  "${AppLocalizations.of(context).tr('Staffs')}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11))
                            ],
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/StaffList');
                          },
                        ),
                      ),
                    ),
                    Flexible(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: InkWell(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.call),
                              Text(
                                  "${AppLocalizations.of(context).tr('Call')}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11))
                            ],
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/CallSocietyMembers');
                          },
                        ),
                      ),
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
