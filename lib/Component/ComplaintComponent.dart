import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as cnst;

class ComplaintComponent extends StatefulWidget {
  var complaintData;
  int index;

  final Function onChange;

  ComplaintComponent(this.complaintData, this.index, this.onChange);

  @override
  _ComplaintComponentState createState() => _ComplaintComponentState();
}

class _ComplaintComponentState extends State<ComplaintComponent> {
  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  String setDate(String date) {
    String final_date = "";
    var tempDate;
    if (date != "" || date != null) {
      tempDate = date.toString().split("-");
      if (tempDate[2].toString().length == 1) {
        tempDate[2] = "0" + tempDate[2].toString();
      }
      if (tempDate[1].toString().length == 1) {
        tempDate[1] = "0" + tempDate[1].toString();
      }
    }
    final_date = date == "" || date == null
        ? ""
        : "${tempDate[2].toString().substring(0, 2)}-${tempDate[1].toString()}\n${tempDate[0].toString()}"
            .toString();

    return final_date;
  }

  _deleteComplaint() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        widget.onChange("loading");
        Services.DeleteComplaint(widget.complaintData["Id"].toString()).then(
            (data) async {
          if (data.Data == "1") {
            widget.onChange("false");
          } else {
            widget.onChange("false");
            showMsg("Complaint Is Not Deleted");
          }
        }, onError: (e) {
          widget.onChange("false");
          showMsg("Something Went Wrong Please Try Again");
          widget.onChange("false");
        });
      }
    } on SocketException catch (_) {
      showMsg("Something Went Wrong");
    }
  }

  _addToSolved() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        widget.onChange("loading");
        Services.AddComplaintToSolve(widget.complaintData["Id"].toString())
            .then((data) async {
          if (data.Data == "1") {
            widget.onChange("false");
          } else {
            widget.onChange("false");
            showMsg("Complaint Is Not Added To Solved");
          }
        }, onError: (e) {
          widget.onChange("false");
          showMsg("Something Went Wrong Please Try Again");
          widget.onChange("false");
        });
      }
    } on SocketException catch (_) {
      showMsg("Something Went Wrong");
    }
  }

  void _showDeleteConfirmDialog(String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("MYJINI"),
          content: new Text(msg),
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
                _deleteComplaint();
              },
            ),
          ],
        );
      },
    );
  }

  void _showUpdateConfirmDialog(String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("MYJINI"),
          content: new Text(msg),
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
                _addToSolved();
              },
            ),
          ],
        );
      },
    );
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
    return AnimationConfiguration.staggeredList(
      position: widget.index,
      duration: const Duration(milliseconds: 475),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Card(
            margin: EdgeInsets.only(top: 7, right: 7, left: 7, bottom: 5),
            child: Container(
              padding: EdgeInsets.all(7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      ClipOval(
                          child: widget.complaintData["MemberImage"] != null &&
                                  widget.complaintData["MemberImage"] != ""
                              ? FadeInImage.assetNetwork(
                                  placeholder: '',
                                  image: "http://smartsociety.itfuturz.com/" +
                                      "${widget.complaintData["MemberImage"]}",
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.fill)
                              : Icon(
                                  Icons.person_outline,
                                  size: 30,
                                )),
                      Padding(padding: EdgeInsets.only(left: 10)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("${widget.complaintData["MemberName"]}",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: cnst.appPrimaryMaterialColor,
                                  fontWeight: FontWeight.w600,
                                )),
                            Text(
                              "${widget.complaintData["WingName"]}-${widget.complaintData["FlatNo"]}",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          launch("tel:" +
                              widget.complaintData["ContactNo"].toString());
                        },
                        child: Icon(
                          Icons.call,
                          color: Colors.green[800],
                        ),
                      ),
                      Container(
                        width: 50,
                        padding: EdgeInsets.all(4),
                        margin: EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.all(Radius.circular(4))),
                        child: Text(
                          "${setDate(widget.complaintData["Date"])}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.grey[400],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, bottom: 4),
                    child: Text(
                      "${widget.complaintData["Title"]}",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 17, bottom: 6),
                    child: Text(
                      "${widget.complaintData["Description"]}",
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: widget.complaintData["Image"] != '' &&
                            widget.complaintData["Image"] != null
                        ? widget.complaintData["Image"]
                                    .toString()
                                    .contains(".jpg") ||
                                widget.complaintData["Image"]
                                    .toString()
                                    .contains(".png") ||
                                widget.complaintData["Image"]
                                    .toString()
                                    .contains(".jpeg")
                            ? FadeInImage.assetNetwork(
                                placeholder: '',
                                image: "http://smartsociety.itfuturz.com/" +
                                    "${widget.complaintData["Image"]}",
                                //width: 200,
                                height: 250,
                                fit: BoxFit.fill)
                            : Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  "http://smartsociety.itfuturz.com/" +
                                      "${widget.complaintData["Image"]}",
                                  style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.blue),
                                ),
                              )
                        : Container(),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      widget.complaintData["Status"].toString() == "0"
                          ? Container(
                              width: MediaQuery.of(context).size.width / 2.4,
                              margin: EdgeInsets.only(top: 10),
                              child: MaterialButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(5.0)),
                                color: Colors.orange,
                                onPressed: () {
                                  _showUpdateConfirmDialog(
                                      "Is This Complaint Is Solved ?");
                                },
                                child: Text(
                                  "Move To Complete",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            )
                          : Container(
                              width: MediaQuery.of(context).size.width / 2.4,
                              margin: EdgeInsets.only(top: 10),
                              height: 35,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Solved",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Padding(padding: EdgeInsets.only(left: 3)),
                                  Icon(
                                    Icons.done_all,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ],
                              ),
                            ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2.4,
                        margin: EdgeInsets.only(top: 10),
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(5.0)),
                          color: Colors.red,
                          onPressed: () {
                            _showDeleteConfirmDialog(
                                "Are You Sure You Want To Delete this Complaint ?");
                          },
                          child: Text(
                            "Delete",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
