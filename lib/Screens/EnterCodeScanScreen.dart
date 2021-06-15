import 'dart:async';
import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:dio/dio.dart';
import 'package:easy_permission_validator/easy_permission_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_text_to_speech/flutter_text_to_speech.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as constant;
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Common/join.dart';
import 'package:smartsocietystaff/Component/masktext.dart';

import 'FromMemberScreen.dart';
import 'SOSpage.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class EnterCodeScanScreen extends StatefulWidget {
  var data;
  String societyName=  "";

  EnterCodeScanScreen(this.data,{this.societyName});

  @override
  _EnterCodeScanScreenState createState() => new _EnterCodeScanScreenState();
}

class _EnterCodeScanScreenState extends State<EnterCodeScanScreen>
    with SingleTickerProviderStateMixin {
  // Constants
  final int time = 30;

  ProgressDialog pr;

  // Variables
  Size _screenSize;
  int _currentDigit;
  int _firstDigit;
  int _secondDigit;
  int _thirdDigit;
  int _fourthDigit;
  int _fifthDigit;
  int _sixthDigit;

  bool isLoading = false;
  List _visitordata = [];

  String userName = "";
  bool didReadNotifications = false;
  int unReadNotificationsCount = 0;
  TextEditingController txtvehicle = new TextEditingController();
  TextEditingController txtpurpose = new TextEditingController();

  // final List<String> _visitorType = ["Visitor", "Staff"];

  //video call..............................
  final _channelController = TextEditingController();
  bool _validateError = false;

  // ClientRole _role = ClientRole.Broadcaster;
  //
  stt.SpeechToText _speech;
  bool _isListening = false;
  VoiceController controller = FlutterTextToSpeech.instance.voiceController();

  @override
  void initState() {
    _speech = stt.SpeechToText();
    controller.init();
    _getLocaldata();
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
          color: Colors.black,
          fontSize: 17.0,
          fontWeight: FontWeight.w600,
        ));
    super.initState();
    final permissionValidator = EasyPermissionValidator(
      context: context,
      appName: 'Easy Permission Validator',
    );
    permissionValidator.camera();
  }

  String WatchManId;
  String societyId;
  List _visitorList = [];

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
    getWingsId(societyId);
    _getDirectoryListing(societyId);
    _getInsideVisitor(societyId);
  }

  List memberData = [];

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

  callingToMemberFromWatchmen(bool CallingType, var dataofMember) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          // "FromName": prefs.getString(Session.Name),
          // "ToName" : widget.MemberData["Name"].toString(),
          "watchmanId": prefs.getString(Session.MemberId),
          "callerWingId": prefs.getString(Session.WingId),
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

  void dispose() {
    // dispose input controller
    _channelController.dispose();
    super.dispose();
  }

  get _getInputField {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _otpTextField(_firstDigit),
        _otpTextField(_secondDigit),
        _otpTextField(_thirdDigit),
        _otpTextField(_fourthDigit),
        _otpTextField(_fifthDigit),
        _otpTextField(_sixthDigit),
      ],
    );
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("MYJINI"),
          content: new Text("Are You Sure You Want To Logout ?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("No",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Yes",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600)),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var body = {
          "watchmanId": WatchManId,
          "playerId": prefs.getString('playerId')
        };
        print("body");
        print(body);
        Future res = Services.responseHandler(apiName: 'watchman/logout',body: body);
        res.then((data) async {
          prefs.clear();
          Navigator.pushReplacementNamed(context, "/Login");
        }, onError: (e) {
          showMsg("Something Went Wrong Please Try Again");
          setState(() {});
        });
      } else {
        showMsg("No Internet Connection.");
        setState(() {});
      }
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
      setState(() {});
    }
  }

  String inputCode;

  get _getOtpKeyboard {
    return new Container(
      height: _screenSize.width - 80,
      child: new Column(
        children: <Widget>[
          new Expanded(
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _otpKeyboardInputButton(
                    label: "1",
                    onPressed: () {
                      _setCurrentDigit(1);
                    }),
                _otpKeyboardInputButton(
                    label: "2",
                    onPressed: () {
                      _setCurrentDigit(2);
                    }),
                _otpKeyboardInputButton(
                    label: "3",
                    onPressed: () {
                      _setCurrentDigit(3);
                    }),
              ],
            ),
          ),
          new Expanded(
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _otpKeyboardInputButton(
                    label: "4",
                    onPressed: () {
                      _setCurrentDigit(4);
                    }),
                _otpKeyboardInputButton(
                    label: "5",
                    onPressed: () {
                      _setCurrentDigit(5);
                    }),
                _otpKeyboardInputButton(
                    label: "6",
                    onPressed: () {
                      _setCurrentDigit(6);
                    }),
              ],
            ),
          ),
          new Expanded(
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _otpKeyboardInputButton(
                    label: "7",
                    onPressed: () {
                      _setCurrentDigit(7);
                    }),
                _otpKeyboardInputButton(
                    label: "8",
                    onPressed: () {
                      _setCurrentDigit(8);
                    }),
                _otpKeyboardInputButton(
                    label: "9",
                    onPressed: () {
                      _setCurrentDigit(9);
                    }),
              ],
            ),
          ),
          new Expanded(
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: GestureDetector(
                    onTap: onJoin,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          width: 80,
                        ),
                        FloatingActionButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SOSpage()));
                          },
                          backgroundColor: Colors.red[200],
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.red[400],
                                  borderRadius: BorderRadius.circular(100.0)),
                              width: 40,
                              height: 40,
                              child: Center(
                                  child: Text(
                                "SOS",
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ))),
                        ),
                      ],
                    ),
                  ),
                ),
                _otpKeyboardInputButton(
                    label: "0",
                    onPressed: () {
                      _setCurrentDigit(0);
                    }),
                _otpKeyboardActionButton(
                    label: new Icon(
                      Icons.backspace,
                      size: 40,
                      color: constant.appPrimaryMaterialColor,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_sixthDigit != null) {
                          _sixthDigit = null;
                        } else if (_fifthDigit != null) {
                          _fifthDigit = null;
                        } else if (_fourthDigit != null) {
                          _fourthDigit = null;
                        } else if (_thirdDigit != null) {
                          _thirdDigit = null;
                        } else if (_secondDigit != null) {
                          _secondDigit = null;
                        } else if (_firstDigit != null) {
                          _firstDigit = null;
                        }
                      });
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  get _VerifyButton {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 45,
          width: 150,
          child: RaisedButton(
              color: Colors.green,
              child: Text(
                "Verify",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18),
              ),
              onPressed: () {
                inputCode = _firstDigit.toString() +
                    _secondDigit.toString() +
                    _thirdDigit.toString() +
                    _fourthDigit.toString() +
                    _fifthDigit.toString() +
                    _sixthDigit.toString();
                print(inputCode);
                // _getVisitorData(inputCode,WatchManId);
                _getVisitorData(inputCode, WatchManId);
              }),
        )
      ],
    );
  }

  String entryNo;

  _getVisitorData(String entryNo, String watchmenId, {String vehicleNo}) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // // pr.show();
        entryNo = entryNo;
        FormData formData = new FormData.fromMap({
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
            } else if (data.Message.split(" ")[0] == "Guest" &&
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
              setState(() {
                _firstDigit = null;
                _secondDigit = null;
                _thirdDigit = null;
                _fourthDigit = null;
                _fifthDigit = null;
                _sixthDigit = null;
              });
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
            setState(() {
              _firstDigit = null;
              _secondDigit = null;
              _thirdDigit = null;
              _fourthDigit = null;
              _fifthDigit = null;
              _sixthDigit = null;
            });
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
    print("data");
    print(data);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 8,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipOval(
                    child: data[0]["guestImage"] != "" &&
                            data[0]["guestImage"] != null
                        ? FadeInImage.assetNetwork(
                            placeholder: 'images/user.png',
                            image: "${IMG_URL + data[0]["guestImage"]}",
                            width: 100,
                            height: 100,
                            fit: BoxFit.fill)
                        : Image.asset("images/user.png",
                            width: 100, height: 100, fit: BoxFit.fill),
                  ),
                ),
                Text(
                  "${data[0]["Name"]}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700]),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    // Text(
                    //   "Visit At :  ",
                    //   style: TextStyle(
                    //       fontSize: 13,
                    //       fontWeight: FontWeight.w600,
                    //       color: Colors.grey[800]),
                    // ),
                    // Text(
                    //   "${data[0]["worklist"][0]["WingName"]} - ${data[0]["worklist"][0]["FlatId"]}",
                    //   style: TextStyle(
                    //       fontSize: 13,
                    //       fontWeight: FontWeight.w600,
                    //       color: Colors.grey[800]),
                    // ),
                  ],
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
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // void _showStaffData(data) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         elevation: 8,
  //         shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.all(Radius.circular(10))),
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
  //                           style: TextStyle(
  //                               color: Colors.white,
  //                               fontWeight: FontWeight.w600),
  //                         ),
  //                         color: Colors.red[600],
  //                         onPressed: () {
  //                           Navigator.pop(context);
  //                         }),
  //                     RaisedButton(
  //                         child: Text(
  //                           "Check In",
  //                           style: TextStyle(
  //                               color: Colors.white,
  //                               fontWeight: FontWeight.w600),
  //                         ),
  //                         color: Colors.green,
  //                         onPressed: () {
  //                           Navigator.pop(context);
  //                           _getVisitorData(inputCode,WatchManId);
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

  List wingclasslist = [];
  String selectedWingId;
  String selectedFlatId;
  String selectedWing;
  String _FlateNo;
  List FlatData = [];

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
                  builder: (context) => FromMemberScreen(fromMemberData: data.Data[0],unknown : true,id:data.Data[0]["EntryId"]),
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

  var _text = 'Tap the button and start speaking';
  bool spoke = false;

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
              for (int i = 0; i < memberData.length; i++) {
                if (_text.toUpperCase().replaceAll(" ", "").contains(
                        memberData[i]["Name"]
                            .toString()
                            .toUpperCase()
                            .replaceAll(" ", ""))
                    //     || _text.toUpperCase().replaceAll(" ","").
                    // contains(memberData[i]["Name"].toString().split(" ")[1].toUpperCase().replaceAll(" ",""))
                    ) {
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
              } else if (_text.length == 6 &&
                  !_text.toString().contains(new RegExp(r'[A-Z]'))) {
                // inputCode = _firstDigit.toString() +
                //     _secondDigit.toString()
                //     + _thirdDigit.toString()
                //     + _fourthDigit.toString() + _fifthDigit.toString() +
                //     _sixthDigit.toString();
                // print(inputCode);
                // _getVisitorData(inputCode,WatchManId);
                setState(() {
                  _firstDigit = int.parse(_text[0]);
                  _secondDigit = int.parse(_text[1]);
                  _thirdDigit = int.parse(_text[2]);
                  _fourthDigit = int.parse(_text[3]);
                  _fifthDigit = int.parse(_text[4]);
                  _sixthDigit = int.parse(_text[5]);
                });
                _getVisitorData(_text, WatchManId);
              }
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    print(wingList);
    _screenSize = MediaQuery.of(context).size;
    return new Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: new Container(
        width: _screenSize.width,
        child: SingleChildScrollView(
          child: new Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: InkWell(
                          child:
                          Center(
                            child: SingleChildScrollView(
                              child: Text("".toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        height: 45,
                        decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.0))),
                      ),
                    ),
                  ),
                  GestureDetector(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Center(
                            child: Icon(Icons.exit_to_app, color: Colors.red),
                          ),
                          decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(80.0))),
                          height: 45,
                          width: 45,
                        ),
                        Text("Logout",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 10))
                      ],
                    ),
                    onTap: () {
                      _showConfirmDialog();
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: PopupMenuButton<String>(
                      onSelected: (String value) {
                        if (value == "Hindi") {
                          setState(() {
                            widget.data.changeLocale(Locale("hi", "IN"));
                          });
                        } else if (value == "English") {
                          setState(() {
                            widget.data.changeLocale(Locale("en", "US"));
                          });
                        } else if (value == "Gujrati") {
                          setState(() {
                            widget.data.changeLocale(Locale("gu", "IN"));
                          });
                        } else if (value == "Marathi") {
                          setState(() {
                            widget.data.changeLocale(Locale("mr", "IN"));
                          });
                        }
                      },
                      tooltip: "Change Language",
                      child: Icon(
                        Icons.more_horiz,
                        size: 30,
                        color: constant.appPrimaryMaterialColor,
                      ),
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'Hindi',
                          child: Text(
                            'हिंदी',
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Gujrati',
                          child: Text(
                            'ગુજરાતી',
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'English',
                          child: Text(
                            'English',
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'Marathi',
                          child: Text(
                            'मराठी',
                            style: TextStyle(
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  // Expanded(
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(8.0),
                  //     child: TextField(
                  //       controller: _channelController,
                  //       decoration: InputDecoration(
                  //         errorText: _validateError
                  //             ? 'Channel name is mandatory'
                  //             : null,
                  //         border: UnderlineInputBorder(
                  //           borderSide: BorderSide(width: 1),
                  //         ),
                  //         hintText: 'Channel name',
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: GestureDetector(
                  //     onTap: onJoin,
                  //     child: Column(
                  //       children: <Widget>[
                  //         Image.asset('images/video_call.png',
                  //             width: 40, height: 40),
                  //         Text(
                  //           "VIDEO CALL",
                  //           style: TextStyle(
                  //               fontWeight: FontWeight.w600, fontSize: 12),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              Padding(padding: EdgeInsets.only(top: 25)),
              _getInputField,
              // Padding(
              //   padding: const EdgeInsets.only(top: 15.0),
              //   child: Wrap(
              //     spacing: 10,
              //     children: List.generate(_visitorType.length, (index) {
              //       return ChoiceChip(
              //         backgroundColor: Colors.grey[200],
              //         label: Text(
              //           _visitorType[index],
              //           style: TextStyle(fontWeight: FontWeight.w600),
              //         ),
              //         selected: selected_Index == index,
              //         onSelected: (selected) {
              //           setState(() {
              //             _firstDigit = null;
              //             _secondDigit = null;
              //             _thirdDigit = null;
              //             _fourthDigit = null;
              //             _fifthDigit = null;
              //             _sixthDigit = null;
              //
              //           });
              //           if (selected) {
              //             setState(() {
              //               selected_Index = index;
              //               print(_visitorType[index]);
              //             });
              //           }
              //         },
              //       );
              //     }),
              //   ),
              // ),
              Padding(padding: EdgeInsets.only(top: 25)),
              _getOtpKeyboard,
              Padding(padding: EdgeInsets.only(top: 2)),
              _firstDigit!=null
                  && _secondDigit!=null
                  && _thirdDigit!=null
                  && _fourthDigit!=null
                  && _fifthDigit!=null
                  && _sixthDigit!=null ? _VerifyButton : Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 10.0),
                          child: Text(
                            "Select Wing",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2.3,
                            height: 40,
                            decoration: BoxDecoration(
                                border: Border.all(width: 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6.0))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: DropdownButtonHideUnderline(
                                  child: DropdownButton<dynamic>(
                                icon: Icon(
                                  Icons.chevron_right,
                                  size: 20,
                                ),
                                hint: wingList != null &&
                                        wingList != "" &&
                                        wingList.length > 0
                                    ? Text(
                                        "Select Wing",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    : Text(
                                        "Wing Not Found",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                value: selectedWing,
                                onChanged: (val) {
                                  selectedWing = val;
                                  for (int i = 0; i < wingList.length; i++) {
                                    if (val == wingList[i]["wingName"]) {
                                      selectedWingId = wingList[i]["_id"];
                                      break;
                                    }
                                  }
                                  // Fluttertoast.showToast(
                                  //     msg: "Coming Soon!!!",
                                  //     backgroundColor: Colors.red,
                                  //     gravity: ToastGravity.TOP,
                                  //     textColor: Colors.white);
                                  print("selectedWingId");
                                  print(selectedWingId);
                                  GetFlatData(selectedWingId, isVoice: false);
                                },
                                items: wingList.map((dynamic val) {
                                  return new DropdownMenuItem<dynamic>(
                                    value: val["wingName"],
                                    child: Text(
                                      val["wingName"],
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  );
                                }).toList(),
                              )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 10.0),
                        child: Text(
                          "Select Flat",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            border: Border.all(color: Colors.black)),
                        width: 120,
                        height: 40,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  _FlateNo == "" || _FlateNo == null
                                      ? 'Flat No'
                                      : _FlateNo,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                size: 18,
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.only(bottom: 8.0),
      //   child: SizedBox(
      //     child: AvatarGlow(
      //       animate: _isListening,
      //       glowColor: Theme.of(context).primaryColor,
      //       endRadius: 25.0,
      //       duration: const Duration(milliseconds: 2000),
      //       repeatPauseDuration: const Duration(milliseconds: 100),
      //       repeat: true,
      //       child: FloatingActionButton(
      //         heroTag: "",
      //         onPressed: _listen,
      //         child: Icon(
      //           _isListening ? Icons.mic : Icons.mic_none,
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // Returns "Otp custom text field"
  Widget _otpTextField(int digit) {
    return new Container(
      width: 35.0,
      height: 45.0,
      alignment: Alignment.center,
      child: new Text(
        digit != null ? digit.toString() : "",
        style: new TextStyle(
          fontSize: 30.0,
          color: Colors.black,
        ),
      ),
      decoration: BoxDecoration(
//            color: Colors.grey.withOpacity(0.4),
          border: Border(
              bottom: BorderSide(
        width: 2.0,
        color: Colors.black,
      ))),
    );
  }

  // Returns "Otp keyboard input Button"
  Widget _otpKeyboardInputButton({String label, VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: new Material(
        color: Colors.grey[100],
        child: new InkWell(
          onTap: onPressed,
          borderRadius: new BorderRadius.circular(40.0),
          child: new Container(
            height: 80.0,
            width: 80.0,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: new Center(
              child: new Text(
                label,
                style: new TextStyle(
                  fontSize: 30.0,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Returns "Otp keyboard action Button"
  _otpKeyboardActionButton({Widget label, VoidCallback onPressed}) {
    return new InkWell(
      onTap: onPressed,
      borderRadius: new BorderRadius.circular(40.0),
      child: new Container(
        height: 80.0,
        width: 80.0,
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: new Center(
          child: label,
        ),
      ),
    );
  }

  // Current digit
  void _setCurrentDigit(int i) {
    setState(() {
      if (_firstDigit != null &&
          _secondDigit != null &&
          _thirdDigit != null &&
          _fourthDigit != null &&
          _fifthDigit != null &&
          _sixthDigit != null) {
        _getVisitorData(
            _firstDigit.toString() +
                _secondDigit.toString() +
                _thirdDigit.toString() +
                _fourthDigit.toString() +
                _fifthDigit.toString() +
                _sixthDigit.toString(),
            WatchManId);
      }
      _currentDigit = i;
      if (_firstDigit == null) {
        _firstDigit = _currentDigit;
      } else if (_secondDigit == null) {
        _secondDigit = _currentDigit;
      } else if (_thirdDigit == null) {
        _thirdDigit = _currentDigit;
      } else if (_fourthDigit == null) {
        _fourthDigit = _currentDigit;
      } else if (_fifthDigit == null) {
        _fifthDigit = _currentDigit;
      } else if (_sixthDigit == null) {
        _sixthDigit = _currentDigit;
      }
    });
  }

  void clearOtp() {
    _fourthDigit = null;
    _thirdDigit = null;
    _secondDigit = null;
    _firstDigit = null;
    _fifthDigit = null;
    _sixthDigit = null;

    setState(() {});
  }

  Future<void> onJoin() async {
    // update input validation
    // setState(() {
    //   _channelController.text.isEmpty
    //       ? _validateError = true
    //       : _validateError = false;
    // });
    // if (_channelController.text.isNotEmpty) {
    // await for camera and mic permissions before pushing video page
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JoinPage(),
      ),
    );
    // }
  }

//for video call setings........................

// Future<void> onJoin() async {
//   // update input validation
//   setState(() {
//     _channelController.text.isEmpty
//         ? _validateError = true
//         : _validateError = false;
//   });
//   if (_channelController.text.isNotEmpty) {
//     // await for camera and mic permissions before pushing video page
//     await _handleCameraAndMic();
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => CallPage(
//           channelName: _channelController.text,
//           role: _role,
//         ),
//       ),
//     );
//   }
// }

// Future<void> _handleCameraAndMic() async {
//   await PermissionHandler().requestPermissions(
//     [PermissionGroup.camera, PermissionGroup.microphone],
//   );
// }
}
