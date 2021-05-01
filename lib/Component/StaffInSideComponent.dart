import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class StaffInSideComponent extends StatefulWidget {
  var _staffInSideList;
  int index;
  final Function onChange;

  StaffInSideComponent(this._staffInSideList, this.index, this.onChange);

  @override
  _StaffInSideComponentState createState() => _StaffInSideComponentState();
}

class _StaffInSideComponentState extends State<StaffInSideComponent> {
  String hour, minites;
  int day = 0;

  @override
  void initState() {
    DateTime time = DateTime.parse(widget._staffInSideList["InTime"]);
    var finalDate = DateTime.now().difference(time).toString().split(":");
    setState(() {
      minites = finalDate[1];
    });
    int tempHour = int.parse(finalDate[0]);
    if (tempHour >= 24) {
      do {
        day++;
        tempHour = tempHour - 24;
      } while (tempHour >= 24);
      setState(() {
        hour = tempHour.toString();
      });
    } else {
      setState(() {
        hour = finalDate[0];
      });
    }
  }

  _CheckOutStatus(String staffId) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        widget.onChange("loading");
        Services.UpdateOutTime(staffId).then((data) async {
          if (data.Data == "1" && data.IsSuccess == true) {
            widget.onChange("false");
          } else {
            widget.onChange("false");
            showMsg(" Is Not Update");
          }
        }, onError: (e) {
          widget.onChange("false");
          print("Error : on Out  $e");
          showMsg("Something Went Wrong Please Try Again");
          widget.onChange("false");
        });
      }
    } on SocketException catch (_) {
      showMsg("Something Went Wrong");
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
    return Card(
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, bottom: 8.0),
            child: ClipOval(
              child: widget._staffInSideList["Image"] == null &&
                      widget._staffInSideList["Image"] == ''
                  ? FadeInImage.assetNetwork(
                      placeholder: 'images/Logo.png',
                      image: "${IMG_URL + widget._staffInSideList["Image"]}",
                      width: 50,
                      height: 50,
                      fit: BoxFit.fill)
                  : Image.asset(
                      'images/user.png',
                      width: 50,
                      height: 50,
                    ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '${widget._staffInSideList["Name"]}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('${widget._staffInSideList["Work"]}'),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('${widget._staffInSideList["VehicleNo"]}'),
                ),
              ],
            ),
          ),
          IconButton(
              icon: Icon(
                Icons.call,
                color: Colors.green,
              ),
              onPressed: () {
                UrlLauncher.launch(
                    'tel:${widget._staffInSideList["ContactNo"]}');
              }),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 5),
                child: Text(
                  day != 0
                      ? "${day} Day ${hour} hour $minites Min"
                      : hour != "-0" && hour != "0"
                          ? "${hour} : $minites Min"
                          : "" + minites + " Min",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: FlatButton(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(8.0),
                        side: BorderSide(color: Colors.red, width: 2)),
                    color: Colors.white,
                    textColor: Colors.red,
                    padding: EdgeInsets.all(8.0),
                    onPressed: () {
                      _CheckOutStatus(
                          '${widget._staffInSideList["EntryId"].toString()}');
                    },
                    child: Text(
                      "OUT".toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
