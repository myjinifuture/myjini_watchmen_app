import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class VisitorInsideComponent extends StatefulWidget {
  var _visitorInsideList;
  int index;
  final Function onChange;

  VisitorInsideComponent(this._visitorInsideList, this.index, this.onChange);

  @override
  _VisitorInsideComponentState createState() => _VisitorInsideComponentState();
}

class _VisitorInsideComponentState extends State<VisitorInsideComponent> {
  String hour, minites;
  int day = 0;
  var insideTime;
  String formattedInTime;
  String hourInFormat;
  DateTime fInTime;

  @override
  void initState() {

    // DateTime time = DateTime.parse(widget._visitorInsideList["inDateTime"][1]);
    // var finalDate = DateTime.now().difference(time).toString().split(":");
    if(widget._visitorInsideList["inDateTime"].length!=0) {
      setState(() {
        minites =
        widget._visitorInsideList["inDateTime"][1].toString().split(" ")[0]
            .split(":")[1];
      });
      int tempHour = int.parse(
          widget._visitorInsideList["inDateTime"][1].toString().split(" ")[0]
              .split(":")[0]);
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
          hour =
          widget._visitorInsideList["inDateTime"][1].toString().split(" ")[0]
              .split(":")[0];
        });
      }
    }
    // var birthday = DateTime(int.parse(widget._visitorInsideList["inDateTime"][0].toString().split("/")[2]),
    //     int.parse(widget._visitorInsideList["inDateTime"][0].toString().split("/")[2],
    // int.parse(widget._visitorInsideList["inDateTime"][0].toString().split("/")[2]);
    // var today = DateTime.now();
    // insideTime =
    formatInTimeConversion();
  }

  formatInTimeConversion() {
    if (widget._visitorInsideList["inDateTime"][1]
        .toString()
        .split(' ')[1]
        .toString() !=
        "am") {
      hourInFormat = (int.parse(widget._visitorInsideList["inDateTime"][1]
          .toString()
          .split(' ')[0]
          .split(':')[0]) +
          12)
          .toString() +
          ":" +
          widget._visitorInsideList["inDateTime"][1]
              .toString()
              .split(' ')[0]
              .split(':')[1]
              .toString() +
          ":" +
          widget._visitorInsideList["inDateTime"][1]
              .toString()
              .split(' ')[0]
              .split(':')[2]
              .toString();
      formattedInTime = widget._visitorInsideList["inDateTime"][0]
          .toString()
          .split('/')[2]
          .toString() +
          "-" +
          widget._visitorInsideList["inDateTime"][0]
              .toString()
              .split('/')[1]
              .toString() +
          "-" +
          widget._visitorInsideList["inDateTime"][0]
              .toString()
              .split('/')[0]
              .toString() +
          " " +
          hourInFormat;
    } else {
      hourInFormat = int.parse(widget._visitorInsideList["inDateTime"][1]
          .toString()
          .split(' ')[0]
          .toString()
          .split(":")[0]) >=
          10
          ? widget._visitorInsideList["inDateTime"][1]
          .toString()
          .split(' ')[0]
          .toString()
          : "0" +
          widget._visitorInsideList["inDateTime"][1]
              .toString()
              .split(' ')[0]
              .toString();
      formattedInTime = widget._visitorInsideList["inDateTime"][0]
          .toString()
          .split('/')[2]
          .toString() +
          "-" +
          widget._visitorInsideList["inDateTime"][0]
              .toString()
              .split('/')[1]
              .toString() +
          "-" +
          widget._visitorInsideList["inDateTime"][0]
              .toString()
              .split('/')[0]
              .toString() +
          " " +
          hourInFormat;
    }

  }


  _CheckOutStatus(String visitorId) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        widget.onChange("loading");
        var data = {
          "entryId" : visitorId
        };
        Services.responseHandler(apiName:"watchman/updateOutTime",body: data).then((data) async {
          if (data.Data == "1" && data.IsSuccess == true) {
            widget.onChange("false");
          } else {
            widget.onChange("false");
            // showMsg(" Is Not Update");
          }
        }, onError: (e) {
          widget.onChange("false");
          print("Error : on Out  $e");
          // showMsg("Something Went Wrong Please Try Again");
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
    print(formattedInTime);
    print(hourInFormat);
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, bottom: 8.0),
            child: ClipOval(
                child: widget._visitorInsideList["guestImage"] == null &&
                        widget._visitorInsideList["guestImage"] == ''
                    ? FadeInImage.assetNetwork(
                        placeholder: 'images/Logo.png',
                        image:
                            "${IMG_URL + widget._visitorInsideList["guestImage"]}",
                        width: 50,
                        height: 50,
                        fit: BoxFit.fill)
                    : Image.asset(
                        'images/user.png',
                        width: 50,
                        height: 50,
                      )),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '${widget._visitorInsideList["Name"]}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(widget._visitorInsideList["CompanyName"] != "" &&
                          widget._visitorInsideList["CompanyName"] != null
                      ? '${widget._visitorInsideList["CompanyName"]}'
                      : '${widget._visitorInsideList["ContactNo"]}'),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                      "${widget._visitorInsideList["WingData"][0]["wingName"]}- ${widget._visitorInsideList["FlatData"][0]["flatNo"]}"),
                )
              ],
            ),
          ),
          Expanded(
            child:           Column(
              children: [
                // widget._visitorInsideList["outDateTime"].length==0 ? Padding(
                //   padding: const EdgeInsets.only(right:35.0),
                //   child: Text("No Date Found",
                //     style: TextStyle(
                //         color: Colors.red
                //
                //   ),
                // ):Padding(
                //   padding: const EdgeInsets.only(right:35.0),
                //   child: Text("$newDt",
                //     style: TextStyle(
                //         color: appPrimaryMaterialColor
                //     ),
                //   ),
                // ),
                widget._visitorInsideList["inDateTime"].length==0 ? Padding(
                  padding: const EdgeInsets.only(right:35.0),
                  child: Text("No inTime Found",
                    style: TextStyle(
                        color:appPrimaryMaterialColor
                    ),
                  ),
                ):Padding(
                  padding: const EdgeInsets.only(right:35.0),
                  child: Text(widget._visitorInsideList["inDateTime"][0],
                    style: TextStyle(
                        color: appPrimaryMaterialColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                widget._visitorInsideList["inDateTime"].length==0 ? Padding(
                  padding: const EdgeInsets.only(right:35.0),
                  child: Text("No inTime Found",
                    style: TextStyle(
                        color: Colors.red
                    ),
                  ),
                ):Padding(
                  padding: const EdgeInsets.only(right:35.0),
                  child: Text(widget._visitorInsideList["inDateTime"][1],
                    style: TextStyle(
                        color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                widget._visitorInsideList["inDateTime"].length==0 ? Padding(
                  padding: const EdgeInsets.only(right:35.0),
                  child: Text("No inTime Found",
                    style: TextStyle(
                        color: Colors.red
                    ),
                  ),
                ):Padding(
                  padding: const EdgeInsets.only(right:35.0),
                  child: Text("${(DateTime.now().difference(DateTime.parse(formattedInTime))).toString().split('.')[0]}",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                    'tel:${widget._visitorInsideList["ContactNo"]}');
              }),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Padding(
              //   padding: const EdgeInsets.only(top: 8.0, right: 5),
              //   child: widget._visitorInsideList["inDateTime"].length!=0 ?Text(
              //     day != 0
              //         ? "${day} Day ${hour} hour $minites Min"
              //         : hour != "-0" && hour != "0"
              //             ? "${hour} : $minites Min"
              //             : "" + minites + " Min",
              //     style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              //   ):Text("No InTime Found"),
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(top: 8.0, right: 5),
              //   child: widget._visitorInsideList["inDateTime"].length!=0 ?
              //       Text((DateTime.now())):Text("No InTime Found"),
              // ),
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
                          '${widget._visitorInsideList["_id"].toString()}');
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
