import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/NoDataComponent.dart';
import 'package:smartsocietystaff/Component/VisitorInsideComponent.dart';

class VisitorInsideList extends StatefulWidget {
  @override
  _VisitorInsideListState createState() => _VisitorInsideListState();
}

class _VisitorInsideListState extends State<VisitorInsideList> {
  List _visitorInsideList = [];
  bool isLoading = false;

  @override
  void initState() {
    _getInsideVisitor();
    getLocalData();
  }

  String societyId;
  getLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
      societyId = prefs.getString(Session.SocietyId);
  }
  _getInsideVisitor() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          "societyId" : societyId
        };

        setState(() {
          isLoading = true;
        });
        Services.responseHandler(apiName: "watchman/getAllVisitorEntry",body: data).then((data) async {
          _visitorInsideList.clear();
          if (data.Data != null && data.Data.length > 0) {
            setState(() {
              // _visitorInsideList = data.Data;
              isLoading = false;
              for(int i=0;i<data.Data.length;i++){
                if(data.Data[i]["outDateTime"].length == 0){
                  print("deleted");
                  _visitorInsideList.add(data.Data[i]);
                  // _visitorInsideList.length--;
                }
              }
              _visitorInsideList = _visitorInsideList.reversed.toList();
            });
          } else {
            setState(() {
              _visitorInsideList = data.Data;
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
    print(_visitorInsideList.length);
    return WillPopScope(
      onWillPop: () => Navigator.pushReplacementNamed(context, "/visitorlist"),
      child: Scaffold(
          body: isLoading
              ? Center(child: CircularProgressIndicator())
              : _visitorInsideList.length > 0
                  ? ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        return VisitorInsideComponent(
                            _visitorInsideList[index], index, (type) {
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
