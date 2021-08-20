import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as cnst;
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/LoadingComponent.dart';
import 'package:smartsocietystaff/Component/NoDataComponent.dart';
import 'package:smartsocietystaff/Component/amcComponent.dart';

class amcList extends StatefulWidget {
  @override
  _amcListState createState() => _amcListState();
}

class _amcListState extends State<amcList> {
  List _amcData = [];
  bool isLoading = false;

  @override
  void initState() {
    _getAMCData();
  }

  _getAMCData() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Future res = Services.getAMC();
        setState(() {
          isLoading = true;
        });
        res.then((data) async {
          if (data != null && data.length > 0) {
            setState(() {
              _amcData = data;
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
          title: Text("AMC",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/Dashboard");
              }),
        ),
        body: isLoading
            ? LoadingComponent()
            : _amcData.length > 0
                ? Column(
                    children: <Widget>[
                      Expanded(
                          child: AnimationLimiter(
                        child: ListView.builder(
                          padding: EdgeInsets.all(0),
                          itemCount: _amcData.length,
                          itemBuilder: (BuildContext context, int index) {
                            return amcComponent(index, _amcData[index]);
                          },
                        ),
                      )),
                      MaterialButton(
                          height: 45,
                          minWidth: MediaQuery.of(context).size.width,
                          color: cnst.appprimarycolors[600],
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, "/AddAMC");
                          },
                          child: Text(
                            "Add New AMC",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          )),
                    ],
                  )
                : NoDataComponent(),
      ),
    );
  }
}
