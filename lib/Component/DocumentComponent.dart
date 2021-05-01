import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as cnst;

class DocumentComponent extends StatefulWidget {
  var documentData;

  final Function onChange;
  int index;

  DocumentComponent(this.documentData, this.index, this.onChange);

  @override
  _DocumentComponentState createState() => _DocumentComponentState();
}

class _DocumentComponentState extends State<DocumentComponent> {
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
        : "${tempDate[2].toString().substring(0, 2)}-${tempDate[1].toString()}-${tempDate[0].toString()}"
            .toString();

    return final_date;
  }

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _deleteDocument() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        widget.onChange("loading");
        Services.DeleteDocument(widget.documentData["Id"].toString()).then(
            (data) async {
          if (data.Data == "1" && data.IsSuccess == true) {
            widget.onChange("false");
          } else {
            widget.onChange("false");
            showMsg("Notice Is Not Delete");
          }
        }, onError: (e) {
          widget.onChange("false");
          print("Error : on Delete Notice $e");
          showMsg("Something Went Wrong Please Try Again");
          widget.onChange("false");
        });
      }
    } on SocketException catch (_) {
      showMsg("Something Went Wrong");
    }
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("MYJINI"),
          content: new Text("Are You Sure You Want To Delete this Document ?"),
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
                _deleteDocument();
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
      duration: const Duration(milliseconds: 450),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            padding: EdgeInsets.only(top: 3, left: 6, right: 6),
            child: Card(
                child: Padding(
              padding: const EdgeInsets.only(
                  top: 8.0, bottom: 10, left: 7, right: 10),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Image.asset("images/document_icon.png",
                          width: 24, height: 24, fit: BoxFit.fill),
                      Padding(padding: EdgeInsets.only(left: 4)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "${widget.documentData["Title"]}",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            Text("${setDate(widget.documentData["Date"])}",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[700])),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _showConfirmDialog();
                        },
                        child: Image.asset("images/delete_icon.png",
                            width: 24, height: 24, fit: BoxFit.fill),
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  GestureDetector(
                      onTap: () {
                        _launchURL("http://smartsociety.itfuturz.com/" +
                            "${widget.documentData["File"]}");
                      },
                      child: widget.documentData["File"]
                                  .toString()
                                  .contains(".jpg") ||
                              widget.documentData["File"]
                                  .toString()
                                  .contains(".png") ||
                              widget.documentData["File"]
                                  .toString()
                                  .contains(".jpeg")
                          ? FadeInImage.assetNetwork(
                              placeholder: '',
                              image: "http://smartsociety.itfuturz.com/" +
                                  "${widget.documentData["File"]}",
                              width: 200,
                              height: 300,
                              fit: BoxFit.fill)
                          : Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "View Document",
                                style: TextStyle(
                                    color: cnst.appPrimaryMaterialColor,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold),
                              ),
                            ))
                ],
              ),
            )),
          ),
        ),
      ),
    );
  }
}
