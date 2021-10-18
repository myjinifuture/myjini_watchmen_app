import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'FromMemberScreen.dart';
class MemberComponent extends StatefulWidget {
  var MemberData;

  MemberComponent(this.MemberData);

  @override
  _MemberComponentState createState() => _MemberComponentState();
}

/*
_openWhatsapp(mobile) {
  String whatsAppLink = constant.whatsAppLink;
  String urlwithmobile = whatsAppLink.replaceAll("#mobile", "91$mobile");
  String urlwithmsg = urlwithmobile.replaceAll("#msg", "");
  launch(urlwithmsg);
}
*/

class _MemberComponentState extends State<MemberComponent> {
/*
  shareFile(String ImgUrl) async {
    ImgUrl = ImgUrl.replaceAll(" ", "%20");
    if (ImgUrl.toString() != "null" && ImgUrl.toString() != "") {
      var request = await HttpClient()
          .getUrl(Uri.parse("http://smartsociety.itfuturz.com/${ImgUrl}"));
      var response = await request.close();
      Uint8List bytes = await consolidateHttpClientResponseBytes(response);
      await Share.files('Share Profile', {'eyes.vcf': bytes}, 'image/pdf');
    }
  }
*/

  bool isLoading = false;
  String Data = "";

/*
  callingToMember() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        FormData formData = new FormData.fromMap({
          "ToName": widget.MemberData["Name"],
          "FromWingId" : prefs.getString(constant.Session.WingId),
          "FromFlatId" : prefs.getString(constant.Session.FlatNo),
          "FromName" : prefs.getString(constant.Session.Name),
          "SocietyId": widget.MemberData["SocietyId"].toString(),
          "ContactNo": widget.MemberData["ContactNo"].toString(),
          "MSId":  prefs.getString(constant.Session.Member_Id),
          "ToCallId" : widget.MemberData["Id"].toString(),
          "WingId":widget.MemberData["WingId"].toString(),
          "FlatId": widget.MemberData["FlatNo"].toString(),
          "AddedBy": "Member",
        });

        print("CallingToMember Data = ${formData.fields}");
        Services.CallingToMember(formData).then((data) async {
          print("data12345");
          print(data.Data);

          if (data.Data != "0" && data.IsSuccess == true) {
            SharedPreferences preferences =
            await SharedPreferences.getInstance();
            await preferences.setString('data', data.Data);
            // await for camera and mic permissions before pushing video page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FromMemberScreen(fromMemberData: widget.MemberData,),
              ),
            );
            */
/*Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JoinPage(),
                    ),
                  );*//*

          } else {

          }
        }, onError: (e) {
          showHHMsg("Try Again.","MyJini");
        });
      } else
        showHHMsg("No Internet Connection.","MyJini");
    } on SocketException catch (_) {
      showHHMsg("No Internet Connection.","MyJini");
    }
  }
*/

/*
  GetVcard() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          isLoading = true;
        });

        Services.GetVcardofMember(
            widget.MemberData["Id"].toString())
            .then((data) async {
          setState(() {
            isLoading = false;
          });
          if (data != null) {
            setState(() {
              Data = data;
            });
            shareFile('${Data}');
          } else {
            setState(() {
              isLoading = false;
            });
          }
        }, onError: (e) {
          setState(() {
            isLoading = false;
          });
          showHHMsg("Try Again.", "");
        });
      }
    } on SocketException catch (_) {
      showHHMsg("No Internet Connection.", "");
    }
  }
*/

  showHHMsg(String title, String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(title),
          content: new Text(msg),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
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
  void initState() {
    // TODO: implement initState
    super.initState();
    // localData();
    print(widget.MemberData["IsPrivate"]);
    print("memberData");
    print(widget.MemberData);
  }

/*  String Id ;
  localData() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Id = prefs.getString(constant.Session.Member_Id);
  }*/

  var wingId = "";
  callingToMemberFromWatchmen(bool CallingType) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if(prefs.getString(Session.WingId).length > 0){
          wingId = prefs.getString(Session.WingId).replaceAll("[", "")
              .replaceAll("]", "").split(",")[0];
        }
        else{
          wingId = prefs.getString(Session.WingId);
        }
        var data = {
          // "FromName": prefs.getString(Session.Name),
          // "ToName" : widget.MemberData["Name"].toString(),
          "watchmanId": prefs.getString(Session.MemberId),
          "callerWingId" : wingId,
          "receiverMemberId" : widget.MemberData["_id"].toString(),
          "receiverWingId":widget.MemberData["WingData"][0]["_id"].toString(),
          "receiverFlatId": widget.MemberData["FlatData"][0]["_id"].toString(),
          "contactNo": widget.MemberData["ContactNo"].toString(),
          "AddedBy" : "Member",
          "societyId" : prefs.getString(Session.SocietyId),
          "isVideoCall" : CallingType,
          "callFor" : 2,
          // "deviceType" : Platform.isAndroid ? "Android" : "IOS"
        };
        print("data2323");
        print(data);
        print(prefs.getString(Session.WingId));


        Services.responseHandler(apiName: "member/memberCalling",body: data).then((data) async {
          // if(data.Data.length==0){
          //   Fluttertoast.showToast(
          //       msg: 'busy hai',
          //       backgroundColor: Colors.red,
          //       gravity: ToastGravity.TOP,
          //       textColor: Colors.white);
          // }
          // else
            if (data.Data != "0" && data.IsSuccess == true && data.Data.length > 0) {
            print("data.Data");
            print(data.Data);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FromMemberScreen(fromMemberData: widget.MemberData,CallingType: "${CallingType}",unknown: false,id:data.Data[0]["_id"]),
              ),
            );
          } else {
              Fluttertoast.showToast(
                msg: "User is busy on another call",
                backgroundColor: Colors.red,
                gravity: ToastGravity.TOP,
                textColor: Colors.white,
              );
          }
        }, onError: (e) {
          showHHMsg("Try Again.","MyJini");
        });
      } else
        showHHMsg("No Internet Connection.","MyJini");
    } on SocketException catch (_) {
      showHHMsg("No Internet Connection.","MyJini");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipOval(
                  child: widget.MemberData["Image"] != '' &&
                      widget.MemberData["Image"] != null
                      ? FadeInImage.assetNetwork(
                      placeholder: '',
                      image: IMG_URL +
                          "${widget.MemberData["Image"]}",
                      width: 50,
                      height: 50,
                      fit: BoxFit.fill)
                      : Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: appPrimaryMaterialColor,
                    ),
                    child: Center(
                      child: Text(
                        "${widget.MemberData["Name"].toString().substring(0, 1).toUpperCase()}",
                        style: TextStyle(
                            fontSize: 25, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width*0.5,
                        child: Text(
                          "${widget.MemberData["Name"]}",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                            ),
                        ),
                      ),
                      widget.MemberData["IsPrivate"] ==
                          false ||
                          widget.MemberData
                          ["IsPrivate"] ==
                              null
                          ? Text(
                          '${widget.MemberData["ContactNo"]}')
                          : Text(
                          '${widget.MemberData["ContactNo"]}'
                              .replaceRange(0, 8, "********")),
                      Text(
                        "${widget.MemberData["WingData"][0]["wingName"]} - ${widget.MemberData["FlatData"][0]["flatNo"]}",
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 13),
                      ),
                      /*Text(
                        "${widget.MemberData["ResidenceType"]}"
                            .checkForNull(),
                        style: TextStyle(
                            color: constant.appPrimaryMaterialColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      )*/
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right:16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: (){
                            /*!widget.MemberData["IsPrivate"] == true
                                ? Fluttertoast.showToast(
                              msg: "Profile is Private",
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            )
                                :*/
// launch("tel:${widget.MemberData["ContactNo"]}");
                            callingToMemberFromWatchmen(true);
                        },
                        child: Icon(
                          Icons.video_call,
                          color: Colors.red,
                          size: 31,
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: (){
                          /*!widget.MemberData["IsPrivate"] == true
                                ? Fluttertoast.showToast(
                              msg: "Profile is Private",
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            )
                                :*/
// launch("tel:${widget.MemberData["ContactNo"]}");
                          callingToMemberFromWatchmen(false);
                        },
                        child: Icon(
                          Icons.call_end,
                          color: Colors.green,
                          size: 31,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
/*
        child: ExpansionTile(
          title: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("${widget.MemberData["Name"]}",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700])),
                          widget.MemberData["IsPrivate"] ==
                              false ||
                              widget.MemberData
                              ["IsPrivate"] ==
                                  null
                              ? Text(
                              '${widget.MemberData["ContactNo"]}')
                              : Text(
                              '${widget.MemberData["ContactNo"]}'
                                  .replaceRange(0, 6, "******")),
                          Text(
                            "Flat No: ${widget.MemberData["FlatNo"]}",
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13),
                          ),
                          */
/*Text(
                            "${widget.MemberData["ResidenceType"]}"
                                .checkForNull(),
                            style: TextStyle(
                                color: constant.appPrimaryMaterialColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          )*//*

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width - 10,
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.all(Radius.circular(3.0))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  */
/*IconButton(
                    icon: Image.asset("images/whatsapp.png",
                        width: 30, height: 30),
                    onPressed: () {
                      widget.MemberData["IsPrivate"] == true
                          ? Fluttertoast.showToast(
                          msg: "Profile is Private",
                          backgroundColor: Colors.red,
                          textColor: Colors.white)
                          : _openWhatsapp(
                          widget.MemberData["ContactNo"]);
                    },
                  ),*//*

                  GestureDetector(
                    onTap: (){
                     */
/* if(widget.MemberData["Id"].toString() == Id.toString()){
                        Fluttertoast.showToast(
                            msg: "You cannot call to yourself",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0);
                      }*//*

                     */
/* else {
                        !widget.MemberData["IsPrivate"] == true
                            ? Fluttertoast.showToast(
                          msg: "Profile is Private",
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                        )
                            :
// launch("tel:${widget.MemberData["ContactNo"]}");
                        callingToMember();
                      }*//*

                    },
                    child: Icon(
                      Icons.video_call,
                      color: Colors.red,
                      size: 31,
                    ),
                  ),
*/
/*
                  IconButton(
                      icon: Image.asset('images/call.png',
                          width: 20, height: 20, color: Colors.green),
                      onPressed: () {
                        if(widget.MemberData["Id"].toString() == Id.toString()){
                          Fluttertoast.showToast(
                              msg: "You cannot call to yourself",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                        else {
                          !widget.MemberData["IsPrivate"] == true
                              ? Fluttertoast.showToast(
                              msg: "Profile is Private",
                              backgroundColor: Colors.red,
                              textColor: Colors.white)
                              :
*//*

*/
/*launch(
                                "tel:${widget.MemberData["ContactNo"]}");*//*
*/
/*

                          callingToMember();
                        }
                      }),
*//*


                 */
/* IconButton(
                      icon: Icon(Icons.remove_red_eye, color: Colors.black54),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MemberProfile(
                              widget.MemberData,
                            ),
                          ),
                        );
                      }),
                  IconButton(
                      icon: Icon(
                        Icons.share,
                        color: Colors.black54,
                      ),
                      onPressed: () {
                        widget.MemberData["IsPrivate"] == true
                            ? Fluttertoast.showToast(
                            msg: "Profile is Private",
                            backgroundColor: Colors.red,
                            textColor: Colors.white)
                            : GetVcard();
                      })*//*

                ],
              ),
            )
          ],
        ),
*/
      ),
    );
  }
}
