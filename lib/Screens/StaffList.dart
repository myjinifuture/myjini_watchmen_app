import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartsocietystaff/Common/ClassList.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as constant;
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/LoadingComponent.dart';
import 'package:smartsocietystaff/Component/NoDataComponent.dart';
import 'package:smartsocietystaff/Component/StaffComponent.dart';

class StaffList extends StatefulWidget {
  @override
  _StaffListState createState() => _StaffListState();
}

class _StaffListState extends State<StaffList> {
  List staffData = [];
  bool isLoading = true;

  @override
  void initState() {
    _getStaffs();
    getLocalData();
  }

  String societyId = "";
  getLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
      societyId = prefs.getString(Session.SocietyId);
  }

  _getStaffs() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          "societyId" : societyId
        };
        setState(() {
          isLoading = true;
        });
        Services.responseHandler(apiName: "watchman/getAllStaff",body: data).then((data) async {
          if (data.Data != null && data.Data.length > 0) {
            setState(() {
              staffData = data.Data;
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
          }
        }, onError: (e) {
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
      showMsg("No Internet Connection.");
      setState(() {});
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

  @override
  Widget build(BuildContext context) {
    print(staffData);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Staff List",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      body: Column(
        children: <Widget>[
          isLoading
              ? Expanded(child: LoadingComponent())
              : staffData.length > 0
                  ? Expanded(
                      child: Container(
                        child: AnimationLimiter(
                            child: ListView.builder(
                          itemCount: staffData.length,
                          itemBuilder: (BuildContext context, int index) {
                            return StaffComponent(
                                index: index, staffData: staffData[index],
                            staffAdded:_getStaffs ,
                            );
                          },
                        )),
                      ),
                    )
                  : NoDataComponent(),
          MaterialButton(
              height: 48,
              minWidth: MediaQuery.of(context).size.width,
              color: constant.appprimarycolors[600],
              onPressed: () {
                Navigator.pushNamed(context, '/AddStaff');
              },
              child: Text(
                "Add Staff",
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              )),
        ],
      ),
    );
  }
}
