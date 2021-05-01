import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/NoDataComponent.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as constant;
import 'package:smartsocietystaff/Component/StaffInSideComponent.dart';
import 'package:smartsocietystaff/Component/VisitorInsideComponent.dart';

class StaffInSideList extends StatefulWidget {
  @override
  _StaffInSideListState createState() => _StaffInSideListState();
}

class _StaffInSideListState extends State<StaffInSideList> {
  List _visitorInsideList = [];
  bool isLoading = false;

  @override
  void initState() {
    _getInsideVisitor();
  }

  _getInsideVisitor() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Future res = Services.getInsideStaffData();
        setState(() {
          isLoading = true;
        });
        res.then((data) async {
          if (data != null && data.length > 0) {
            setState(() {
              _visitorInsideList = data;
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
              _visitorInsideList = data;
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

  showMsg(String msg, {String title = 'MYJINI'}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {

        return AlertDialog(
          title: new Text(title),
          content: new Text(msg),
          actions: <Widget>[
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          body: isLoading
              ? Container(child: Center(child: CircularProgressIndicator()))
              : _visitorInsideList.length > 0
                  ? ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        return StaffInSideComponent(_visitorInsideList[index],index, (type) {
                          if (type == "false")
                            setState(() {
                              _getInsideVisitor();
                            });
                          else if (type == "loading")
                            setState(() {
                              isLoading = true;
                            });
                        });
                      },
                      itemCount: _visitorInsideList.length,
                    )
                  : NoDataComponent()),
    );
  }
}
