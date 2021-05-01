import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:intl/intl.dart';

class StaffOutSideComponent extends StatefulWidget {
  var  _staffOutSideList;
  int index;
  final Function onChange;

  StaffOutSideComponent(this._staffOutSideList,this.index,this.onChange);
  @override
  _StaffOutSideComponentState createState() => _StaffOutSideComponentState();
}

class _StaffOutSideComponentState extends State<StaffOutSideComponent> {


/*
  _CheckOutStatus(String staffId) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        widget.onChange("loading");
        Services.UpdateOutTime(staffId).then(
                (data) async {
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
*/

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top:8.0,left: 8.0,bottom: 8.0),
            child: ClipOval(
                child: widget._staffOutSideList["Image"] == null && widget._staffOutSideList["Image"] == '' ? FadeInImage.assetNetwork(
                    placeholder: 'images/Logo.png',
                    image:
                    "${IMG_URL+widget._staffOutSideList["Image"]}",
                    width: 50,
                    height: 50,
                    fit: BoxFit.fill)
                    :Image.asset('images/user.png',width: 50,height: 50,)
            )
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    '${widget._staffOutSideList["Name"]}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('${widget._staffOutSideList["Work"]}'),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('${widget._staffOutSideList["VehicleNo"]}'),
                ),
              ],
            ),
          ),
          IconButton(icon: Icon(Icons.call,color: Colors.green,), onPressed: (){
            UrlLauncher.launch('tel:${widget._staffOutSideList["ContactNo"]}');

          }),
        ],
      ),
    );
  }
}
