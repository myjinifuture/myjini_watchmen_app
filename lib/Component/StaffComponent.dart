import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as constant;
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Screens/StaffProfile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smartsocietystaff/Common/Services.dart';

ProgressDialog pr;

class StaffComponent extends StatefulWidget {
  var index, staffData;
  Function staffAdded;

  StaffComponent({this.index, this.staffData,this.staffAdded});

  @override
  _StaffComponentState createState() => _StaffComponentState();
}

class _StaffComponentState extends State<StaffComponent> {
  @override
  void initState() {
    getLocalData();
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
  }

  String societyId;

  getLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    societyId = prefs.getString(Session.SocietyId);
    allWingsAndFlats();
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

  bool scanned = false;

    _addStaffDetails(String staffId, String entryNo) async {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          // pr.show();
          var data = {
            "staffId": staffId,
            "entryNo": entryNo,
            "societyId": societyId,
            "type" : 0,
          };
          Services.responseHandler(
                  apiName: "watchman/addStaffEntryNo", body: data)
              .then((data) async {
                print(data.Message);
            // pr.hide();
            if (data.Data != null && data.Data == 1) {
              setState(() {
                scanned = true;
              });
              Fluttertoast.showToast(
                  msg: "Staff Mapped Successfully!!",
                  backgroundColor: Colors.green,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.white);
              // ignore: unnecessary_statements
              widget.staffAdded();
            } else {
              //showMsg("Data Not Found");
              Fluttertoast.showToast(
                  msg: "This Card already exists!!",
                  backgroundColor: Colors.red,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.white);
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

  Future scan(String staffId) async {
    String defaultType = "Staff";
    try {
      String barcode = await BarcodeScanner.scan();
      print(barcode);
      var data = barcode.split(",");
      print("data in qrcode");
      print(data);
      if (barcode != null) {
        _addStaffDetails(staffId, "STAFF-" + data[0].toString());
      } else
        showMsg("Try Again..");
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          // this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        // setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      // setState(() => this.barcode =
      // 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      // setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  List<Widget> wingsAndFlats = [];

  allWingsAndFlats(){
    print("called");
    wingsAndFlats.clear();
    for(int j=0;j<widget.staffData["WingData"].length;j++) {
      for (int i = 0; i < widget.staffData["FlatData"].length; i++) {
        if (i == widget.staffData["FlatData"].length - 1) {
          wingsAndFlats.add(Text(
            "${widget.staffData["WingData"][j]["wingName"]}-${widget
                .staffData["FlatData"][i]["flatNo"]}",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),);
        }
        else {
          wingsAndFlats.add(Text(
            "${widget.staffData["WingData"][j]["wingName"]}-${widget
                .staffData["FlatData"][i]["flatNo"]}" + ",",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ));
        }
      }
    }
    return wingsAndFlats;
  }

  @override
  Widget build(BuildContext context) {
    allWingsAndFlats();
    print("widget.staffData");
    print(widget.staffData["WingData"]);
    return AnimationConfiguration.staggeredList(
      position: widget.index,
      duration: const Duration(milliseconds: 450),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Card(
            margin: EdgeInsets.all(6),
            child: Container(
              padding: EdgeInsets.all(5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  widget.staffData["staffImage"] != '' &&
                          widget.staffData["staffImage"] != null
                      ? FadeInImage.assetNetwork(
                          placeholder: '',
                          image: "${constant.IMG_URL}" +
                              "${widget.staffData["staffImage"]}",
                          width: 60,
                          height: 60,
                          fit: BoxFit.fill)
                      : Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: constant.appPrimaryMaterialColor,
                          ),
                          child: Center(
                            child: Text(
                              "${widget.staffData["Name"].toString().substring(0, 1).toUpperCase()}",
                              style:
                                  TextStyle(fontSize: 25, color: Colors.white),
                            ),
                          ),
                        ),
                  Padding(padding: EdgeInsets.only(left: 8)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "${widget.staffData["Name"]}",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: constant.appPrimaryMaterialColor),
                        ),
                        Text(
                          "${widget.staffData["ContactNo1"]}",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.grey[600]),
                        ),
                        Text(
                          "${widget.staffData["Work"]}",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.grey),
                        ),
                        widget.staffData["WingData"].length != 0 ?
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: wingsAndFlats,
                          ),
                        ):Container(),
                        // widget.staffData["WingData"].length != 0 ?Text(
                        //   "${widget.staffData["WingData"][0]["wingName"]}",
                        //   style: TextStyle(
                        //     fontSize: 13,
                        //     fontWeight: FontWeight.w600,
                        //     color: Colors.grey[600],
                        //   ),
                        // ):Container(),
                      ],
                    ),
                  ),
                  widget.staffData["isMapped"] == true
                      ? IconButton(
                          icon: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            print('check clicked');
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: new Text("MYJINI"),
                                  content:
                                  new Text("Are You Sure You Want To UnMap ?"),
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
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },)
                      : IconButton(
                          icon: Icon(
                            Icons.qr_code_scanner,
                            color: Colors.green[700],
                          ),
                          onPressed: () {
                            scan(widget.staffData["_id"]);
                          }),
                  IconButton(
                      icon: Icon(
                        Icons.call,
                        color: Colors.green[700],
                      ),
                      onPressed: () {
                        launch("tel:" + widget.staffData["ContactNo1"]);
                      }),
                  IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StaffProfile(
                                      staffData: widget.staffData,
                                    )));
                        //Navigator.pushNamed(context, '/EditStaff');
                      })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
