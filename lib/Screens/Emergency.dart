import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/LoadingComponent.dart';
import 'package:smartsocietystaff/Component/NoDataComponent.dart';
import 'package:url_launcher/url_launcher.dart';

class Emergency extends StatefulWidget {
  @override
  _EmergencyState createState() => _EmergencyState();
}

class _EmergencyState extends State<Emergency> {
  List _EmergencyData = [];
  bool isLoading = false;

  @override
  void initState() {
    _getEmergencyData();
  }

  _getEmergencyData() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Future res = Services.getEmergencyData();
        setState(() {
          isLoading = true;
        });
        res.then((data) async {
          if (data != null && data.length > 0) {
            setState(() {
              _EmergencyData = data;
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
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, "/Dashboard");
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Emergency Contacts"),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/Dashboard");
            },
          ),
        ),
        body: isLoading
            ? LoadingComponent()
            : _EmergencyData.length > 0
                ? Container(
                    color: Colors.grey[100],
                    child: ListView.builder(
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          elevation: 2,
                          child: Container(
                            padding: EdgeInsets.all(7),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Image.asset("images/emergency.png",
                                    width: 22,
                                    height: 22,
                                    fit: BoxFit.fill),
                                Padding(padding: EdgeInsets.only(left: 13)),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                          "${_EmergencyData[index]["Title"]}",
                                          softWrap: true,
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15)),
                                      Text(
                                          "${_EmergencyData[index]["ContactNo"]}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15))
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    launch(
                                        'tel:${_EmergencyData[index]["ContactNo"]}');
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: Icon(
                                      Icons.call,
                                      size: 30,
                                      color: Colors.green,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: _EmergencyData.length,
                    ),
                  )
                : NoDataComponent(),
      ),
    );
  }
}
