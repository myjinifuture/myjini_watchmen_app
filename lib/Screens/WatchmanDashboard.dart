import 'dart:async';
import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:dio/dio.dart' as D;
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
import 'package:avatar_glow/avatar_glow.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_text_to_speech/flutter_text_to_speech.dart';

import 'FromMemberScreen.dart';

const APP_STORE_URL =
    'https://play.google.com/store/apps/details?id=com.itfuturz.mygenie_staff';
const PLAY_STORE_URL =
    'https://play.google.com/store/apps/details?id=com.itfuturz.mygenie_staff';

class WatchmanDashboard extends StatefulWidget {

  String societyName = "";

  WatchmanDashboard({this.societyName});

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
  List memberData = [];

  String barcode = "";
  String fcmToken = "";
  TextEditingController txtvehicle = new TextEditingController();

  Future<void> initOneSignalNotification() async {
    OneSignal.shared.setNotificationOpenedHandler(
        (OSNotificationOpenedResult result) async {
      print("Opened notification");
      print(result.notification.jsonRepresentation().replaceAll("\\n", "\n"));
      print(result.notification.payload.additionalData);
      dynamic data = result.notification.payload.additionalData;
      Vibration.vibrate(
        duration: 700,
      );
      if (data["NotificationType"] == 'VisitorAccepted') {
        Get.to(
            NotificationAnswerDialog(data, VisitorAccepted: "VisitorAccepted"));
      } else if (data["NotificationType"] == 'VisitorRejected') {
        Get.to(
            NotificationAnswerDialog(data, VisitorAccepted: "VisitorRejected"));
      } else if (data["CallResponseIs"] == 'Rejected') {
        Get.to(FromMemberScreen(
          rejected: "Rejected",unknown: false,
        ));
      } else if (data["NotificationType"] == 'VisitorAccepted') {
        Get.to(
            NotificationAnswerDialog(data, VisitorAccepted: "VisitorAccepted"));
      } else if (data["NotificationType"] == 'VisitorRejected') {
        Get.to(
            NotificationAnswerDialog(data, VisitorAccepted: "VisitorRejected"));
      } else if (data["NotificationType"] == 'VoiceCall') {
        Get.to(
            JoinPage(
            entryIdWhileGuestEntry: data["CallingId"],
            voicecall:
                data["NotificationType"],
            ),
        ); // audioCache.play('Sound.mp3');
      } else if (data["NotificationType"] == 'VideoCalling') {
        Get.to(JoinPage(
            entryIdWhileGuestEntry: data["VisitorEntryId"],
            data: data,
            CallingId: data["CallingId"]));
      } else if (data["notificationType"] == 'UnknownVisitor') {
        if (data["CallStatus"] == "Accepted") {
          Get.to(
            JoinPage(
              unknownVisitorEntryId: data["EntryId"],
                isAudioCall : data["isAudioCall"]
            ),
          );
        } else {
          Get.to(NotificationAnswerDialog(data));
        }
      } else if (data["NotificationType"] == 'Visitor') {
        Get.to(
          JoinPage(
            entryIdWhileGuestEntry: data["VisitorEntryId"],
            data: data,
            CallingId: data["CallingId"],
          ),
        );
      } else if (data["Type"] == 'Accepted') {
        Get.to(JoinPage());
      } else {
        Get.to(NotificationAnswerDialog(data));
      }
    });
  }

  var playerId;

  void _handleSendNotification() async {
    var status = await OneSignal.shared.getPermissionSubscriptionState();

    playerId = status.subscriptionStatus.userId;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'playerId',
      playerId,
    );
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
    String identifier = await UniqueIdentifier.serial;
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
  _getDirectoryListing(String SocietyId) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {"societyId": SocietyId};
        // setState(() {
        //   isLoading = true;
        // });
        Services.responseHandler(apiName: "admin/directoryListing", body: data)
            .then((data) async {
          memberData.clear();
          if (data.Data != null && data.Data.length > 0) {
            setState(() {
              memberData = data.Data;
              // for(int i=0;i<data.Data.length;i++){
              //   if(data.Data[i]["society"]["wingId"] == selectedWing){
              //     memberData.add(data.Data[i]);
              //   }
              // }
              // isLoading = false;
            });
            print("memberData");
            print(memberData);
          } else {
            // setState(() {
            //   isLoading = false;
            // });
          }
        }, onError: (e) {
          showMsg("Something Went Wrong Please Try Again");
        });
      }
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
    }
  }
  String wing;
  callingToMemberFromWatchmen(bool CallingType, var dataofMember) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if(prefs.getString(Session.WingId).length > 0){
        wing = prefs.getString(Session.WingId).replaceAll("[", "")
            .replaceAll("]", "").split(",")[0];
      }
      else{
        wing = prefs.getString(Session.WingId);
      }
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          // "FromName": prefs.getString(Session.Name),
          // "ToName" : widget.MemberData["Name"].toString(),
          "watchmanId": prefs.getString(Session.MemberId),
          "callerWingId": wing,
          "receiverMemberId": dataofMember["_id"].toString(),
          "receiverWingId": dataofMember["WingData"][0]["_id"].toString(),
          "receiverFlatId": dataofMember["FlatData"][0]["_id"].toString(),
          "contactNo": dataofMember["ContactNo"].toString(),
          "AddedBy": "Member",
          "societyId": prefs.getString(Session.SocietyId),
          "isVideoCall": CallingType,
          "callFor": 2,
          // "deviceType": Platform.isAndroid ? "Android" : "IOS"
        };
        print("data");
        print(data);

        Services.responseHandler(apiName: "member/memberCalling", body: data)
            .then((data) async {
          if (data.Data != "0" && data.IsSuccess == true) {
            // SharedPreferences preferences =
            // await SharedPreferences.getInstance();
            // await preferences.setString('data', data.Data);
            // await for camera and mic permissions before pushing video page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FromMemberScreen(
                  fromMemberData: dataofMember,
                  CallingType: "${CallingType}",
                  unknown: false,
                  id: data.Data[0]["_id"],
                ),
              ),
            );
            /*Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JoinPage(
                    )
                  );*/
          } else {}
        }, onError: (e) {
          showMsg("Try Again.");
        });
      } else
        showMsg("No Internet Connection.");
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
    }
  }
  List wingList = [];
  getWingsId(String societyId) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var body = {"societyId": societyId};
        Services.responseHandler(
            apiName: "admin/getAllWingOfSociety", body: body)
            .then((data) async {
          if (data != null) {
            setState(() {
              wingList = data.Data;
            });
            if (wingList.length == 0) {
              Fluttertoast.showToast(
                  msg: "No Wings Found",
                  backgroundColor: Colors.red,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.white);
            }
          }
        }, onError: (e) {
          Fluttertoast.showToast(msg: "$e", toastLength: Toast.LENGTH_LONG);
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
  String selectedWingId;
  GetFlatData(String WingId, {bool isVoice, String voiceMessage}) async {
    try {
      //check Internet Connection
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // setState(() {
        //   // pr.show();
        // });

        var body = {"societyId": societyId, "wingId": WingId};
        FlatData.clear();
        Services.responseHandler(apiName: "admin/getFlatsOfSociety_v1", body: body)
            .then((data) async {
          print("data.Data");
          // setState(() {
          //   isLoading = false;
          // });
          // pr.hide();
          if (data.Data.length > 0) {
            setState(() {
              // FlatData = data.Data
              for (int i = 0; i < data.Data.length; i++) {
                if (data.Data[i]["memberIds"].length > 0) {
                  FlatData.add(data.Data[i]);
                }
              }
            });
            print("flatdata");
            print(FlatData);
            if (FlatData.length > 0) {
              if (!isVoice) {
                _flatSelectionBottomsheet(context);
              } else {
                for (int i = 0; i < FlatData.length; i++) {
                  if (FlatData[i]["flatNo"].toString() == voiceMessage) {
                    selectedFlatId = FlatData[i]["_id"];
                  }
                }
                sendNotificationToParent(flatId: selectedFlatId, isVoice: true);
              }
            }
          } else {
            Fluttertoast.showToast(
                msg: "No Flat Member Found",
                backgroundColor: Colors.red,
                gravity: ToastGravity.TOP,
                textColor: Colors.white);
          }
        }, onError: (e) {
          setState(() {
            // pr.hide();
          });
          showHHMsg("Try Again.", "");
        });
      } else {
        setState(() {
          // pr.hide();
        });
        showHHMsg("No Internet Connection.", "");
      }
    } on SocketException catch (_) {
      showHHMsg("No Internet Connection.", "");
    }
  }
  Size _screenSize;
  int _currentDigit;
  int _firstDigit;
  int _secondDigit;
  int _thirdDigit;
  int _fourthDigit;
  int _fifthDigit;
  int _sixthDigit;
  var _text = 'Tap the button and start speaking';
  bool spoke = false;
  @override
  void initState() {
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
    // if (Platform.isIOS) {
    //   iosSubscription =
    //       _firebaseMessaging.onIosSettingsRegistered.listen((data) {
    //     print("FFFFFFFF" + data.toString());
    //     saveDeviceToken();
    //   });
    //   _firebaseMessaging
    //       .requestNotificationPermissions(IosNotificationSettings());
    // } else {
    //   saveDeviceToken();
    // }
  }

  updateMemberPlayerId(
      String watchmanId, String mobileNo, String playerId, String IMEI) async {
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
        Services.responseHandler(
                apiName: "watchman/updateWatchmanPlayerId", body: data)
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
    double currentVersion =
        double.parse(info.version.trim().replaceAll(".", ""));

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
        // _showVersionDialog(context);
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

  _getVisitorData(String entryNo, String watchmenId, bool isGuest,
      {String vehicleNo}) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // // pr.show();
        entryNo = entryNo;

        D.FormData formData = new D.FormData.fromMap({
          "entryNo": entryNo,
          "watchmanId": watchmenId,
          "vehicleNo": vehicleNo,
          "deviceType": Platform.isAndroid ? "Android" : "IOS",
          "societyId": societyId
        });
        print({
          "entryNo": entryNo,
          "watchmanId": watchmenId,
          "vehicleNo": vehicleNo,
          "deviceType": Platform.isAndroid ? "Android" : "IOS",
          "societyId": societyId
        });
        setState(() {
          isLoading = true;
        });
        Services.responseHandler(
                apiName: "watchman/addVisitorEntry", body: formData)
            .then((data) async {
          // // pr.hide();
          print("message");
          print(data.Data);
          if (isGuest) {
            if (data.Data.toString() == "1") {
              Fluttertoast.showToast(
                  msg: "Guest Left Successfully!!",
                  backgroundColor: Colors.green,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.white);
            } else if (isGuest && data.Data.length > 0) {
              _showVisitorData(data.Data);
              setState(() {
                _visitordata = data.Data;
                isLoading = false;
              });
            } else {
              Fluttertoast.showToast(
                  msg: "Please enter correct code!!",
                  backgroundColor: Colors.red,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.white);
            }
          } else {
            if (data.Data.toString() == "1") {
              Fluttertoast.showToast(
                  msg: "Staff Left Successfully!!",
                  backgroundColor: Colors.green,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.white);
            } else if (data.Data.length == 0) {
              Fluttertoast.showToast(
                  msg: "Please enter correct code!!",
                  backgroundColor: Colors.red,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.white);
            } else {
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

  _addVisitorEntry() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        String SocietyId = preferences.getString(Session.SocietyId);

        // pr.show();

        print('_visitordata[0]["lastentry"].toString().isNotEmpty');
        print(_visitordata[0]["lastentry"].isNotEmpty);
        var formData = {
          "Id": "0",
          "SocietyId": SocietyId,
          "TypeId": _visitordata[0]["lastentry"].isNotEmpty  ?  _visitordata[0]["lastentry"]["TypeId"] : "",
          "Type": _visitordata[0]["lastentry"].isNotEmpty ? _visitordata[0]["lastentry"]["Type"] : "",
          "Purpose": "",
          "VehicleNo": txtvehicle.text,
          "WorkId": _visitordata[0]["worklist"]
        };

        Services.CheckInVisitorStaff(formData).then((data) async {
          // pr.hide();
          if (data.Data != "0" && data.IsSuccess == true) {
            Fluttertoast.showToast(
                msg: "Visitor CheckIn Successfully",
                backgroundColor: Colors.green,
                gravity: ToastGravity.TOP,
                textColor: Colors.white);
          } else {
            showMsg(data.Message, title: "Error");
          }
        }, onError: (e) {
          // pr.hide();
          showMsg("Try Again.");
        });
      }
    } on SocketException catch (_) {
      // pr.hide();
      showMsg("No Internet Connection.");
    }
  }
  List FlatData = [];
  _flatSelectionBottomsheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Select Flat",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: GridView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: FlatData.length,
                    itemBuilder: (BuildContext context, int i) {
                      print("FlatData");
                      print(FlatData);
                      return Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: InkWell(
                          onTap: () {
                            if (FlatData.length > 0) {
                              setState(() {
                                _FlateNo = FlatData[i]["flatNo"];
                                for (int i = 0; i < FlatData.length; i++) {
                                  if (FlatData[i]["flatNo"] == _FlateNo) {
                                    selectedFlatId = FlatData[i]["_id"];
                                  }
                                }
                              });
                              sendNotificationToParent(
                                  flatId: selectedFlatId, isVoice: false);
                              Navigator.pop(context);
                            }
                          },
                          child: Card(
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      '${FlatData[i]["flatNo"].toString()}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                      ;
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    )),
              )
            ],
          );
        });
  }
  String _FlateNo;
  String selectedFlatId;
  String selectedWing;
  // String _FlateNo;
  sendNotificationToParent({String flatId, bool isVoice}) async {
    try {
      //check Internet Connection
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // setState(() {
        //   // pr.show();
        // });

        var data = {
          "societyId": societyId,
          "wingId": selectedWingId,
          "flatId": selectedFlatId,
          // "deviceType": Platform.isAndroid ? "Android" : "IOS",
          "watchmanId": WatchManId
        };
        Services.responseHandler(
            apiName: "watchman/sendNotificationForVisitorEntry", body: data)
            .then((data) async {
          setState(() {
            isLoading = false;
          });
          // pr.hide();
          print("data");
          print(data.Data);
          if (data.Data.length > 0) {
            setState(() {
              Fluttertoast.showToast(
                  msg: "Video Call Sent!!!",
                  backgroundColor: Colors.green,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.white);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FromMemberScreen(fromMemberData: data.Data[0],unknown: true,id: data.Data[0]["EntryId"],),
                ),
              );
            });
          } else {
            // setState(() {
            //   // pr.hide();
            // });
            Fluttertoast.showToast(
                msg: "No Member Found",
                backgroundColor: Colors.red,
                gravity: ToastGravity.TOP,
                textColor: Colors.white);
          }
        }, onError: (e) {
          setState(() {
            // pr.hide();
          });
          showHHMsg("Try Again.", "");
        });
      } else {
        setState(() {
          // pr.hide();
        });
        showHHMsg("No Internet Connection.", "");
      }
    } on SocketException catch (_) {
      showHHMsg("No Internet Connection.", "");
    }
  }
  showHHMsg(String title, String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(title),
          content: new Text(msg),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              color: Colors.grey[100],
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  _getVisitorDatanew(String entryNo, String watchmenId, {String vehicleNo}) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // // pr.show();
        entryNo = entryNo;
        D.FormData formData = new D.FormData.fromMap({
          "entryNo": entryNo,
          "watchmanId": watchmenId,
          "vehicleNo": vehicleNo,
          "deviceType": Platform.isAndroid ? "Android" : "IOS",
          "societyId": societyId
        });
        print({
          "entryNo": entryNo,
          "watchmanId": watchmenId,
          "vehicleNo": vehicleNo,
          "deviceType": Platform.isAndroid ? "Android" : "IOS",
          "societyId": societyId
        });
        setState(() {
          isLoading = true;
        });
        Services.responseHandler(
            apiName: "watchman/addVisitorEntry", body: formData)
            .then((data) async {
          // // pr.hide();
          print("message");
          print(data.Data);
          print(data.Message);
          if (data.Message.split(" ")[0] == "Guest" ||
              data.Message == "Visitor Added") {
            if (data.Data.toString() == "1") {
              Fluttertoast.showToast(
                  msg: "Guest Left Successfully!!",
                  backgroundColor: Colors.green,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.white);
              setState(() {
                _firstDigit = null;
                _secondDigit = null;
                _thirdDigit = null;
                _fourthDigit = null;
                _fifthDigit = null;
                _sixthDigit = null;
              });
            } else if (data.Message.split(" ")[0] == "Guest" ||
                data.Data.length > 0) {
              _showVisitorData(data.Data);
              setState(() {
                _visitordata = data.Data;
                isLoading = false;
              });
            } else {
              Fluttertoast.showToast(
                msg: "Please enter correct code!!",
                backgroundColor: Colors.red,
                gravity: ToastGravity.TOP,
                textColor: Colors.white,
              );
              setState(() {
                _firstDigit = null;
                _secondDigit = null;
                _thirdDigit = null;
                _fourthDigit = null;
                _fifthDigit = null;
                _sixthDigit = null;
              });
            }
          } else {
            if (data.Data.toString() == "1") {
              Fluttertoast.showToast(
                  msg: "Staff Left Successfully!!",
                  backgroundColor: Colors.green,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.white);
              setState(() {
                _firstDigit = null;
                _secondDigit = null;
                _thirdDigit = null;
                _fourthDigit = null;
                _fifthDigit = null;
                _sixthDigit = null;
              });
            } else if (data.Data.length == 0) {
              Fluttertoast.showToast(
                  msg: "Please enter correct code!!",
                  backgroundColor: Colors.green,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.white);
              setState(() {
                _firstDigit = null;
                _secondDigit = null;
                _thirdDigit = null;
                _fourthDigit = null;
                _fifthDigit = null;
                _sixthDigit = null;
              });
            } else {
              Fluttertoast.showToast(
                  msg: "Staff Added Successfully!!",
                  backgroundColor: Colors.green,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.white);
              // setState(() {
              //   _firstDigit = null;
              //   _secondDigit = null;
              //   _thirdDigit = null;
              //   _fourthDigit = null;
              //   _fifthDigit = null;
              //   _sixthDigit = null;
              // });
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
  List _visitorList = [];

  String WatchManId, societyId, mobileNo;
  _getInsideVisitor(String id) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {"societyId": id};

        setState(() {
          isLoading = true;
        });
        Services.responseHandler(
            apiName: "watchman/getAllVisitorEntry", body: data)
            .then((data) async {
          _visitorList.clear();
          if (data.Data != null && data.Data.length > 0) {
            setState(() {
              _visitorList = data.Data;
              isLoading = false;
              // for(int i=0;i<data.Data.length;i++){
              //   if(data.Data[i]["outDateTime"].length == 0){
              //     print("deleted");
              //     _visitorList.add(data.Data[i]);
              //     // _visitorInsideList.length--;
              //   }
              // }
              _visitorList = _visitorList.reversed.toList();
            });
          } else {
            setState(() {
              _visitorList = data.Data;
              isLoading = false;
            });
          }
        }, onError: (e) {
          showMsg("Something Went Wrong Please Try Again");
          setState(() {
            isLoading = false;
          });
        });
      }
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
      setState(() {
        isLoading = false;
      });
    }
  }

  _getLocaldata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    WatchManId = prefs.getString(constant.Session.MemberId);
    societyId = prefs.getString(constant.Session.SocietyId);
    mobileNo = prefs.getString(constant.Session.mobileNo);
    _speech = stt.SpeechToText();
    controller.init();
    initOneSignalNotification();
    getWingsId(societyId);
    _getDirectoryListing(societyId);
    _getInsideVisitor(societyId);
    initPlatformState();
  }

  Future scan() async {
    String defaultType = "Visitor";
    try {
      String barcode = await BarcodeScanner.scan();
      print(barcode);
      var data = barcode.split(",");
      if (data[0].split("-")[0] == "GUEST")
        _getVisitorData(data[0].split("-")[1], WatchManId, true);
      else
        _getVisitorData(data[0], WatchManId, false);
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
                   */ /* Row(
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
                    )*/ /*
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: Row(
                  children: <Widget>[
                   */ /* Column(
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
                    ),*/ /*
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

  _addVehicleDetailOfGuest(String guestId, String vehicleNo) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // pr.show();
        var data = {"guestEntryId": guestId, "vehicleNo": vehicleNo};
        Services.responseHandler(
                apiName: "watchman/addGuestVehicle", body: data)
            .then((data) async {
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
                            _addVehicleDetailOfGuest(
                                data[0]["_id"], txtvehicle.text);
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
  // var _text = 'Tap the button and start speaking';
  // bool spoke = false;
  stt.SpeechToText _speech;
  bool _isListening = false;
  VoiceController controller = FlutterTextToSpeech.instance.voiceController();
  speak(String name) {
    spoke = true;
    controller.speak("${name}");
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
      );
      print("available");
      print(available);
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _isListening = false;
            _text = val.recognizedWords;
            print("_text");
            print(_text);
            // bool isVisitorSpoken = false;
            if (_text.replaceAll(" ", "").toUpperCase().contains("VIDEOCALL") ||
                _text.replaceAll(" ", "").toUpperCase().contains("AUDIOCALL") ||
                _text.replaceAll(" ", "").toUpperCase().contains("CALL")) {
              print("printed");
              print(_text.toUpperCase().replaceAll(" ", ""));
              for (int i = 0; i < memberData.length; i++) {
                print( memberData[i]["Name"]
                    .toString()
                    .toUpperCase()
                    .replaceAll(" ", ""));
                if (_text.toUpperCase().replaceAll(" ", "").contains(
                    memberData[i]["Name"]
                        .toString()
                        .toUpperCase()
                        .replaceAll(" ", ""))
                //     || _text.toUpperCase().replaceAll(" ","").
                // contains(memberData[i]["Name"].toString().split(" ")[1].toUpperCase().replaceAll(" ",""))
                ) {
                  print("memberData");
                  print(memberData[i]);
                  speak("call kar rahi hu ${memberData[i]["Name"]} ko");
                  if (_text
                      .replaceAll(" ", "")
                      .toUpperCase()
                      .contains("AUDIOCALL") ||
                      _text
                          .replaceAll(" ", "")
                          .toUpperCase()
                          .contains("CALL")) {
                    callingToMemberFromWatchmen(false, memberData[i]);
                  } else {
                    callingToMemberFromWatchmen(true, memberData[i]);
                  }
                }
              }
            } else {
              // for(int i=0;i<_visitorList.length;i++){
              //   if(_text.replaceAll(" ", "").toUpperCase().contains("VISITOR")) {
              //     if (_text.replaceAll(" ", "").toUpperCase().contains(
              //         _visitorList[i]["Name"]
              //             .toString().toUpperCase()) ||
              //         _text.replaceAll(" ", "").toUpperCase().contains(
              //             _visitorList[i]["Name"]
              //                 .toString().toUpperCase())) {
              //
              //     }
              //     isVisitorSpoken = true;
              //   }
              // }

              _text = _text.replaceAll(" ", "");
              if (_text.length == 4 &&
                  !_text.toString().contains(new RegExp(r'[A-Z]'))) {
                for (int i = 0; i < wingList.length; i++) {
                  if (_text[0].toUpperCase() == wingList[i]["wingName"]) {
                    selectedWingId = wingList[i]["_id"];
                    break;
                  }
                }
                print(_text);
                print(_text[1] + _text[2] + _text[3]);
                GetFlatData(selectedWingId,
                    isVoice: true,
                    voiceMessage: _text[1] + _text[2] + _text[3]);
              }
              if (_text.length == 3 &&
                  !_text.toString().contains(new RegExp(r'[A-Z]'))) {
                for (int i = 0; i < wingList.length; i++) {
                  if (_text[0].toUpperCase() ==
                      wingList[i]["wingName"].toString().toUpperCase()) {
                    selectedWingId = wingList[i]["_id"];
                    break;
                  }
                }
                print(_text);
                print(_text[1] + _text[2]);
                GetFlatData(selectedWingId,
                    isVoice: true,
                    voiceMessage: (_text[1] + _text[2]).toUpperCase());
              }
              // else if (_text.length == 6 &&
              //     !_text.toString().contains(new RegExp(r'[A-Z]'))) {
              //   print("6 called");
              //   // inputCode = _firstDigit.toString() +
              //   //     _secondDigit.toString()
              //   //     + _thirdDigit.toString()
              //   //     + _fourthDigit.toString() + _fifthDigit.toString() +
              //   //     _sixthDigit.toString();
              //   // print(inputCode);
              //   // _getVisitorData(inputCode,WatchManId);
              //   setState(() {
              //     _firstDigit = int.parse(_text[0]);
              //     _secondDigit = int.parse(_text[1]);
              //     _thirdDigit = int.parse(_text[2]);
              //     _fourthDigit = int.parse(_text[3]);
              //     _fifthDigit = int.parse(_text[4]);
              //     _sixthDigit = int.parse(_text[5]);
              //   });
              //   _getVisitorDatanew(_text, WatchManId);
              // }
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
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
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
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
            body:
                TabBarView(physics: NeverScrollableScrollPhysics(), children: [
              EnterCodeScanScreen(data,societyName:widget.societyName),
              // FreqVisitorlist(),
              visitorlist(),
            ]),
            // bottomNavigationBar: Container(
            //   height: 60,
            //   child: Row(
            //     children: <Widget>[
            //       Flexible(
            //         child: Container(
            //           width: MediaQuery.of(context).size.width,
            //           child: InkWell(
            //             child: Column(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               crossAxisAlignment: CrossAxisAlignment.center,
            //               children: <Widget>[
            //                 Icon(
            //                   Icons.person_add,
            //                   size: 30,
            //                   color: Colors.grey[600],
            //                 ),
            //                 Text(
            //                     "${AppLocalizations.of(context).tr('AddVisitor')}"
            //                         .toUpperCase(),
            //                     style: TextStyle(
            //                         // fontWeight: FontWeight.bold,
            //                         fontSize: 11))
            //               ],
            //             ),
            //             onTap: () {
            //               Navigator.pushNamed(context, '/AddVisitorForm');
            //             },
            //           ),
            //         ),
            //       ),
            //       Flexible(
            //         child: Container(
            //           width: MediaQuery.of(context).size.width,
            //           child: InkWell(
            //             child: Column(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               crossAxisAlignment: CrossAxisAlignment.center,
            //               children: <Widget>[
            //                 Image.asset(
            //                   'images/scanner.png',
            //                   width: 30,
            //                   height: 30,
            //                   color: Colors.grey[600],
            //                 ),
            //                 Text(
            //                     "${AppLocalizations.of(context).tr('ScanCode')}"
            //                         .toUpperCase(),
            //                     style: TextStyle(
            //                         // fontWeight: FontWeight.bold,
            //                         fontSize: 11))
            //               ],
            //             ),
            //             onTap: () {
            //               scan();
            //             },
            //           ),
            //         ),
            //       ),
            //       Flexible(
            //         child: Container(
            //           width: MediaQuery.of(context).size.width,
            //           child: InkWell(
            //             child: Column(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               crossAxisAlignment: CrossAxisAlignment.center,
            //               children: <Widget>[
            //                 Icon(
            //                   Icons.supervised_user_circle,
            //                   size: 30,
            //                   color: Colors.grey[600],
            //                 ),
            //                 Text(
            //                     "${AppLocalizations.of(context).tr('Staffs')}"
            //                         .toUpperCase(),
            //                     style: TextStyle(
            //                         // fontWeight: FontWeight.bold,
            //                         fontSize: 11))
            //               ],
            //             ),
            //             onTap: () {
            //               Navigator.pushNamed(context, '/StaffList');
            //             },
            //           ),
            //         ),
            //       ),
            //       Flexible(
            //         child: Container(
            //           width: MediaQuery.of(context).size.width,
            //           child: InkWell(
            //             child: Column(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               crossAxisAlignment: CrossAxisAlignment.center,
            //               children: <Widget>[
            //                 Icon(
            //                   Icons.call,
            //                   size: 30,
            //                   color: Colors.grey[600],
            //                 ),
            //                 Text(
            //                     "${AppLocalizations.of(context).tr('Call')}"
            //                         .toUpperCase(),
            //                     style: TextStyle(
            //                         // fontWeight: FontWeight.bold,
            //                         fontSize: 11))
            //               ],
            //             ),
            //             onTap: () {
            //               Navigator.pushNamed(context, '/CallSocietyMembers');
            //             },
            //           ),
            //         ),
            //       )
            //     ],
            //   ),
            // ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SizedBox(
                child: AvatarGlow(
                  animate: _isListening,
                  glowColor: Theme.of(context).primaryColor,
                  endRadius: 25.0,
                  duration: const Duration(milliseconds: 2000),
                  repeatPauseDuration: const Duration(milliseconds: 100),
                  repeat: true,
                  child: FloatingActionButton(
                    heroTag: "",
                    onPressed: _listen,
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                    ),
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: BottomAppBar(
              elevation: 10,
              notchMargin: 12,
              shape: CircularNotchedRectangle(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.075,
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Center(
                        child: InkWell(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.person_add,
                                size: 30,
                                color: Colors.grey[600],
                              ),
                              Text(
                                  "${AppLocalizations.of(context).tr('AddVisitor')}"
                                      .toUpperCase(),
                                  style: TextStyle(
                                      // fontWeight: FontWeight.bold,
                                      fontSize: 10))
                            ],
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/AddVisitorForm');
                          },
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Center(
                        child: InkWell(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Image.asset(
                                'images/scanner.png',
                                width: 30,
                                height: 30,
                                color: Colors.grey[600],
                              ),
                              Text(
                                  "${AppLocalizations.of(context).tr('ScanCode')}"
                                      .toUpperCase(),
                                  style: TextStyle(
                                      // fontWeight: FontWeight.bold,
                                      fontSize: 11))
                            ],
                          ),
                          onTap: () {
                            scan();
                          },
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.2,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Center(
                        child: InkWell(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.supervised_user_circle,
                                size: 30,
                                color: Colors.grey[600],
                              ),
                              Text(
                                  "${AppLocalizations.of(context).tr('Staffs')}"
                                      .toUpperCase(),
                                  style: TextStyle(
                                      // fontWeight: FontWeight.bold,
                                      fontSize: 11))
                            ],
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/StaffList');
                          },
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Center(
                        child: InkWell(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.call,
                                size: 30,
                                color: Colors.grey[600],
                              ),
                              Text(
                                  "${AppLocalizations.of(context).tr('Call')}"
                                      .toUpperCase(),
                                  style: TextStyle(
                                      // fontWeight: FontWeight.bold,
                                      fontSize: 11))
                            ],
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, '/CallSocietyMembers');
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
