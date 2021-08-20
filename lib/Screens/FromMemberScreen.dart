import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:vibration/vibration.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as constant;

class FromMemberScreen extends StatefulWidget {

  Map fromMemberData = {};
  String rejected="",CallingType="",id="";
  bool unknown = false,isAudioCall = false;

  FromMemberScreen({this.fromMemberData,this.rejected,this.CallingType,this.unknown,this.id,this.isAudioCall});

  @override
  _FromMemberScreenState createState() => _FromMemberScreenState();
}

class _FromMemberScreenState extends State<FromMemberScreen> {

  Duration _duration = new Duration();
  Duration _position = new Duration();
  Duration _slider = new Duration(seconds: 0);
  double durationvalue;
  bool issongplaying = false;

  @override
  void initState() {
    print("widget.memberdata");
    print(widget.fromMemberData);
    super.initState();
    _getLocaldata();
  }

  String WatchManId = "";
  _getLocaldata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    WatchManId = prefs.getString(constant.Session.MemberId);
  }

  onRejectCall() async {
    try {
      print("widget.fromMemberData");
      print(widget.fromMemberData);
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {

          var data = {
            "watchmanId": WatchManId,
            "callingId": widget.id
          };
          print("data");
          print(data);
          Services.responseHandler(apiName: "watchman/rejectCallByWatchmanForUnknownVisitorEntry", body: data)
              .then(
                  (data) async {
                if (data.Data.toString() == '1') {
                  print('call declined successfully');
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/WatchmanDashboard', (Route<dynamic> route) => false);                } else {
                  // setState(() {
                  //   isLoading = false;
                  // });
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/WatchmanDashboard', (Route<dynamic> route) => false);
                }
              }, onError: (e) {
          });

      }
    } on SocketException catch (_) {
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
      },
      child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(top:50.0),
            child: new Center(
                child: SingleChildScrollView(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Image.asset('images/Logo.png',
                          width: 90, height: 90),
                      Text(
                        "MYJINI",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width*0.05,
                      ),
                      widget.isAudioCall ? Text("Audio Calling....",
                        style: TextStyle(
                            fontSize: 20,
                        ),
                      ):widget.rejected=="Rejected" ? Container() : Text(
                        "Video Calling....",
                        style: TextStyle(
                            fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height*0.1,
                      ),
                          widget.fromMemberData == null
                          ? Container(
                          width: MediaQuery.of(context).size.width*0.3,
                          height: MediaQuery.of(context).size.height*0.3,
                        child : Image.asset('images/Logo.png',
                            width: 90, height: 90,
                        ),
                      ):widget.unknown ? FadeInImage.assetNetwork(
                              placeholder: 'images/Logo.png',
                              image: IMG_URL +
                                  "${widget.fromMemberData["MemberImage"]}",
                              width: 140,
                              height: 140,
                              fit: BoxFit.fill)  : FadeInImage.assetNetwork(
                           placeholder: '',
                           image: IMG_URL +
                               "${widget.fromMemberData["Image"]}",
                           width: 200,
                           height: 200,
                           fit: BoxFit.fill),
                      SizedBox(
                        height: MediaQuery.of(context).size.height*0.01,
                      ),
                      widget.unknown ? Text(
                        widget.fromMemberData["MemberName"],
                        textScaleFactor: 1.5,
                      ) : widget.rejected=="Rejected"? Container() : widget.fromMemberData == null ? Container() :
                      Text(
                        widget.fromMemberData["Name"],
                        textScaleFactor: 1.5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          widget.unknown ? Text(
                            widget.fromMemberData["Wing"],
                            textScaleFactor: 1.5,
                          ) : widget.rejected=="Rejected"? Container() : widget.fromMemberData == null ? Container() : new Text(
                            widget.fromMemberData["WingData"][0]["wingName"],
                            textScaleFactor: 1.5,
                          ),
                          new Text(
                            "-",
                            textScaleFactor: 1.5,
                          ),
                          widget.unknown ? Text(
                            widget.fromMemberData["Flat"],
                            textScaleFactor: 1.5,
                          ) : widget.rejected=="Rejected"? Container() : widget.fromMemberData == null ? Container() :Text(
                            widget.fromMemberData["FlatData"][0]["flatNo"],
                            textScaleFactor: 1.5,
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right:30.0,top:10),
                        child: GestureDetector(
                          onTap: () {
                            // _timer.cancel();
                            onRejectCall();
                          },
                          child: Stack(
                            children: [
                              Center(
                                child: Container(
                                  width: 60.0,
                                  height: 60.0,
                                  decoration: new BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Center(
                                child:Padding(
                                  padding: const EdgeInsets.all(18.0,
                                  ),
                                  child: Icon(
                                    Icons.call_end,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      widget.rejected=="Rejected"?Text(
                        "Rejected......",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                        ),
                      ):Text(
                        "Ringing......",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                        ),
                      )
                    ],
                  ),
                )),
          )
/*
        body: Center(
          child: Column(
            children: [
              SizedBox(
                height: 400,
              ),
              new RaisedButton(
                onPressed: () => sendVideoCallStatus("Accepted",
                    widget.fromMemberData["EntryId"],
                    widget.fromMemberData["SocietyId"],
                    widget.fromMemberData["EntryId"],
                    widget.fromMemberData["EntryId"],
                    "Accepted"),
                  */
/*Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JoinPage(),
                    ),
                  );*//*

                child: new Text("Accept"),
              ),
              new RaisedButton(

                onPressed: () => sendVideoCallStatus("Rejected",
                  widget.fromMemberData["EntryId"],
                  widget.fromMemberData["SocietyId"],
                  widget.fromMemberData["EntryId"],
                  widget.fromMemberData["EntryId"],
                  "Rejected"),
                child: new Text("Reject"),
              ),
            ],
          ),
        ),
*/
      ),
    );
  }
}
