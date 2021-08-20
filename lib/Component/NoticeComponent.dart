import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as cnst;
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Screens/EditNotice.dart';
import 'package:smartsocietystaff/Screens/NoticeDetail.dart';

class NoticeComponent extends StatefulWidget {
  var noticeData;
  int index;

  final Function onChange;

  NoticeComponent(this.noticeData, this.index, this.onChange);

  @override
  _NoticeComponentState createState() => _NoticeComponentState();
}

class _NoticeComponentState extends State<NoticeComponent> {
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

  _deleteNotice() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        widget.onChange("loading");
        Services.DeleteNotice(widget.noticeData["Id"].toString()).then(
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
          content: new Text("Are You Sure You Want To Delete this Notice ?"),
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
                _deleteNotice();
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
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoticeDetail(widget.noticeData),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(1.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Container(
                  height: 100,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Image.asset(
                                    "images/notification_icon.png",
                                    width: 17,
                                    height: 15,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text("${widget.noticeData["Title"]}",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600)),
                                        Text(
                                            "${setDate(widget.noticeData["Date"])}",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700])),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                endIndent: 20,
                              ),
                              Text("${widget.noticeData["Description"]}",
                                  maxLines: 3,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.grey[900])),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 100,
                        width: 0.4,
                        color: Colors.grey,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, right: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditNotice(widget.noticeData),
                                  ),
                                );
                              },
                              child: Image.asset(
                                "images/edit_icon.png",
                                width: 23,
                                height: 23,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _showConfirmDialog();
                              },
                              child: Image.asset(
                                "images/delete_icon.png",
                                width: 23,
                                height: 23,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
