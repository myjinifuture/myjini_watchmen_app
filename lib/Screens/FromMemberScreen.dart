import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:vibration/vibration.dart';

class FromMemberScreen extends StatefulWidget {

  Map fromMemberData = {};
  String rejected="",CallingType="";

  FromMemberScreen({this.fromMemberData,this.rejected,this.CallingType});

  @override
  _FromMemberScreenState createState() => _FromMemberScreenState();
}

class _FromMemberScreenState extends State<FromMemberScreen> {

  AudioCache audioCache;
  AudioPlayer audioPlayer;
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
    Vibration.cancel();
    audioPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: audioPlayer);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    audioPlayer.pause();
    print("widget.rejected");
    print(widget.rejected);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        audioPlayer.stop();
        Navigator.pushReplacementNamed(context, "/WatchmanDashboard");
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
                      widget.CallingType == "false" ? Text("Audio Calling....",
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
                      ):FadeInImage.assetNetwork(
                           placeholder: '',
                           image: IMG_URL +
                               "${widget.fromMemberData["Image"]}",
                           width: 200,
                           height: 200,
                           fit: BoxFit.fill),
                      SizedBox(
                        height: MediaQuery.of(context).size.height*0.1,
                      ),
                      widget.rejected=="Rejected"? Container() : widget.fromMemberData == null ? Container() : Text(
                        widget.fromMemberData["Name"],
                        textScaleFactor: 1.5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          widget.rejected=="Rejected"? Container() : widget.fromMemberData == null ? Container() : new Text(
                            widget.fromMemberData["WingData"][0]["wingName"],
                            textScaleFactor: 1.5,
                          ),
                          new Text(
                            "-",
                            textScaleFactor: 1.5,
                          ),
                           widget.rejected=="Rejected"? Container() : widget.fromMemberData == null ? Container() :Text(
                            widget.fromMemberData["FlatData"][0]["flatNo"],
                            textScaleFactor: 1.5,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width*0.2,
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
