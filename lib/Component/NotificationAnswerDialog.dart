import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as constant;
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationAnswerDialog extends StatefulWidget {
  var data;
  String VisitorAccepted="";

  NotificationAnswerDialog(this.data,{this.VisitorAccepted});

  @override
  _NotificationAnswerDialogState createState() =>
      _NotificationAnswerDialogState();
}

class _NotificationAnswerDialogState extends State<NotificationAnswerDialog> {
  List NoticeData = new List();
  bool isLoading = false;
  String SocietyId;
  AudioPlayer advancedPlayer;
  AudioCache audioCache;
  Duration _duration = new Duration();
  Duration _position = new Duration();

  @override
  void initState() {
    initPlayer();
    print( widget.data );
    if(widget.data["notificationType"] == "UnknownVisitor" || widget.data["NotificationType"] == "InstantWatchmanMessage"){
      print("divyan");
    }else{
      print("hello");
      setState(() {
        audioCache.play('CallRinging.mp3');
      });

    }
  }
  void initPlayer() {
    advancedPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: advancedPlayer);

    advancedPlayer.durationHandler = (d) => setState(() {
      _duration = d;
    });

    advancedPlayer.positionHandler = (p) => setState(() {
      _position = p;
    });
  }
  @override
  Widget build(BuildContext context) {
    print("widget.data");
    print(widget.data);
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
      },
      child: Container(
        color: Colors.black54,
        child: Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              widget.data["NotificationType"]!='VisitorAccepted'?(widget.data["Message"] == "APPROVED"
                  ? Padding(
                padding: const EdgeInsets.all( 8.0 ),
                child: Image.asset( 'images/success.png',
                    height: 50, width: 50 ),
              )
                  : widget.data["Message"] == 'DENY'
                  ? Padding(
                padding: const EdgeInsets.all( 8.0 ),
                child: Image.asset( 'images/error.png',
                    height: 50, width: 50 ),
              )
                  : widget.data["NotificationType"] == "VisitorRejected" ? Container() : Padding(
                padding: const EdgeInsets.only( top: 15.0, bottom: 8.0 ),
                child: widget.data["notificationType"] == "UnknownVisitor"|| widget.data["NotificationType"] == "InstantWatchmanMessage" ? Container() : Image.asset(
                    'images/SOSwatchman.png', height: 70, width: 70 ),
              )):Container(),
              widget.data["NotificationType"] == "InstantWatchmanMessage" ?  Padding(
                padding: const EdgeInsets.only( top: 8.0 ),
                child: Column(
                  children: <Widget>[
                    // Padding(
                    //   padding: const EdgeInsets.only( top: 15.0 ),
                    //   child: Text( '${widget.data["Name"]}',
                    //       style: TextStyle(
                    //           fontSize: 16, fontWeight: FontWeight.bold ) ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.only( top: 15.0,left: 25 ),
                      child: Text( '${widget.data["Message"]}',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600 ) ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only( bottom: 20.0 ),
                      child: Text(
                          '${widget.data["Wing"]}'
                              '-'
                              '${widget.data["Flat"]}',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold ) ),
                    ),
                  ],
                ),
              ):Container(),
              widget.data["Message"] == "APPROVED"
                  ? Padding(
                padding: const EdgeInsets.only( top: 8.0 ),
                child: Column(
                  children: <Widget>[
                    Text( "APPROVED BY",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600 ) ),
                    Padding(
                      padding: const EdgeInsets.only( top: 15.0 ),
                      child: Text( '${widget.data["Name"]}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold ) ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only( bottom: 20.0 ),
                      child: widget.data["NotificationType"] == "InstantWatchmanMessage" ? Text(
                          '${widget.data["Wing"]}'
                              '-'
                              '${widget.data["Flat"]}',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold ) ): Text(
                          '${widget.data["WingName"]}'
                              '-'
                              '${widget.data["FlatNo"]}',
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold ) ),
                    ),
                  ],
                ),
              )
                  : widget.data["Message"] == 'DENY'
                  ? Padding(
                padding: const EdgeInsets.all( 8.0 ),
                child: Column(
                  children: <Widget>[
                    Text( "DENY BY",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600 ) ),
                    Padding(
                      padding: const EdgeInsets.only( top: 15.0 ),
                      child: Text(
                          widget.data["Message"],
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold ) ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only( bottom: 20.0 ),
                    //   child: Text(
                    //       '${widget.data["data"]["WingName"]}' // ask monil to give me this detail
                    //           '-'
                    //           '${widget.data["data"]["FlatNo"]}',
                    //       style: TextStyle(
                    //           fontSize: 17,
                    //           fontWeight: FontWeight.bold ) ),
                    // ),
                  ],
                ),
              )
                  : Padding(
                  padding: const EdgeInsets.all( 8.0 ),
                  child: Column(
                    children: <Widget>[
                      // Text( "Leave My Parcel \n At Gate",
                      //     textAlign: TextAlign.center,
                      //     style: TextStyle(
                      //         fontSize: 18, fontWeight: FontWeight.w600 ) ),
                      widget.VisitorAccepted == "VisitorAccepted" ? Text( "Visitor Accepted",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600 ) ):widget.VisitorAccepted=="VisitorRejected" ?
                      Text( "Visitor Rejected",

                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 18, fontWeight: FontWeight.w600 ) ):
                      widget.data["notificationType"] == "UnknownVisitor" || widget.data["NotificationType"] == "InstantWatchmanMessage"? Container() : Text( "Emergency Message",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600 ) ),
                      Divider( ),
                      widget.data["NotificationType"] == "InstantWatchmanMessage" ? Container() :widget.data["Message"] == "Response Regarding Visitor Entry" ? Padding(
                        padding: const EdgeInsets.only( top: 15.0,left: 25 ),
                        child: Text( 'Rejected Dont Let them come inside',
                            style: TextStyle(
                              color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.w600 ) ),
                      ): Padding(
                        padding: const EdgeInsets.only( top: 15.0,left: 25 ),
                        child: Text( '${widget.data["Message"]}',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600 ) ),
                      ),
                      Column(
                        children: [
                          SizedBox(height: 20,),
                          widget.data["notificationType"] == "UnknownVisitor" || widget.data["NotificationType"] == "InstantWatchmanMessage"? Container() :  widget.data["NotificationType"]!='SOS'?Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Text("Accepted By ${widget.data["data"]["memberName"]}",
                              //   style: TextStyle(
                              //     fontWeight: FontWeight.bold,
                              //     fontSize: 20,
                              //   ),
                              // ),
                              Text("Responded By",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ):SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("${widget.data["Name"]}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          widget.data["notificationType"] == "UnknownVisitor" || widget.data["NotificationType"] == "InstantWatchmanMessage"? Container() : widget.data["NotificationType"]!='SOS'?Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${widget.data["Wing"]}" + " - "
                                  + "${widget.data["Flat"]}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                              ),
                            ],
                          ):widget.data["notificationType"] == "UnknownVisitor" ? Container() : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${widget.data["SenderWing"]}" + " - "
                                  + "${widget.data["SenderFlat"]}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                      // Column(
                      //   children: [
                      //     GestureDetector(
                      //       onTap: () {
                      //         launch("tel:" +
                      //             widget.data["data"]["ContactNo"].toString());
                      //       },
                      //       child: Icon(
                      //         Icons.call,
                      //         color: Colors.green[800],
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      widget.VisitorAccepted == "VisitorAccepted" ? Padding(
                        padding: const EdgeInsets.only( bottom: 20.0 ),
                        // child: Text(
                        //     '${widget.data["data"]["WingName"]}'
                        //         '-'
                        //         '${widget.data["data"]["FlatNo"]}',
                        //     style: TextStyle(
                        //         fontSize: 17,
                        //         fontWeight: FontWeight.bold ) ),
                      ):Container(),
                    ],
                  )
              ),
              widget.data["NotificationType"] == "InstantWatchmanMessage" ? Container() :RaisedButton(
                color: Colors.white,
                child:  Text('Check Location',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                onPressed: (){
                  launch(widget.data["GoogleMap"]);
                },
              ),
              Padding(
                padding: const EdgeInsets.all( 8.0 ),
                child: MaterialButton(
                  color: Colors.grey[200],
                  onPressed: () {
                    // Get.back();
                    // Navigator.pop(context);
                    advancedPlayer.stop();
                    Navigator.pop(context);
                  },
                  child: Text( "OK",
                      style:
                      TextStyle( fontSize: 16, fontWeight: FontWeight.bold ) ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
 }