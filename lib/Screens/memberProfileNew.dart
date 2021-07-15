import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/LoadingComponent.dart';


class MemberProfile extends StatefulWidget {
  var memberData;
  Function onAdminUpdate;
  String isContactNumberPrivate;

  MemberProfile({this.memberData,this.isContactNumberPrivate,this.onAdminUpdate});

  @override
  _MemberProfileState createState() => _MemberProfileState();
}

class _MemberProfileState extends State<MemberProfile> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List _visitorData = [];
  List _familyMemberData = [];
  List _vehicleData = [];
  bool isLoading = false;
  bool isMemberLoading = false;
  bool isAdmin;
  List memberRoleDetails=[];
  ProgressDialog pr;

  bool madeAdmin = false;
  String ResidanceType = "";
  String MemberId = "";
  String ContactNo = "";
  String SocietyId, FlatId, WingId;

  @override
  void initState() {
    print("memberData");
    print(widget.memberData);
    if( widget.memberData["FlatData"][0]["residenceType"].toString()=="0"){
      ResidanceType = "Owner";
    }
    else if( widget.memberData["FlatData"][0]["residenceType"].toString()=="1"){
      ResidanceType = "Closed";
    }
    else if( widget.memberData["FlatData"][0]["residenceType"].toString()=="2"){
      ResidanceType = "Rent";
    }
    else{
      ResidanceType = "Dead";
    }
    // print("widget.isCONTACTPRIVATE");
    // print(widget.isContactNumberPrivate);
    _getLocaldata();
    pr = new ProgressDialog(context, type: ProgressDialogType.Normal);
    pr.style(
        message: "Please Wait",
        borderRadius: 10.0,
        progressWidget: Container(
          padding: EdgeInsets.all(15),
          child: CircularProgressIndicator(),
        ),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.w600));
  }

  _getLocaldata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    MemberId = widget.memberData["_id"];
    ContactNo = widget.memberData["society"]["ContactNo"];
    SocietyId = widget.memberData["society"]["societyId"];
    FlatId = widget.memberData["society"]["flatId"];
    WingId = widget.memberData["society"]["wingId"];
    getMemberRole(widget.memberData["_id"], widget.memberData["society"]["societyId"]);
  }

  _getVisitor() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String societyId = widget.memberData["society"]["societyId"];
        String flatId = widget.memberData["society"]["flatId"];
        String wingId = widget.memberData["society"]["wingId"];
        var data = {
          "societyId": societyId,
          "flatId": flatId,
          "wingId": wingId,
        };
        setState(() {
          isLoading = true;
        });
        Services.responseHandler(
            apiName: "member/getMemberVisitor_V1", body: data)
            .then((data) async {
          if (data.Data != null && data.Data.length > 0) {
            setState(() {
              _visitorData = data.Data;
              isLoading = false;
            });
          } else {
            setState(() {
              _visitorData = data.Data;
              isLoading = false;
            });
          }
          if (data.Data.length > 0) {
            _showVisitor(context);
          } else
            showMsg("No Visitor Found");
        }, onError: (e) {
          showMsg("Something Went Wrong Please Try Again");
          setState(() {
            isLoading = false;
          });
        });
      }
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
    }
  }

  _getVehicle(String id) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          isLoading = true;
        });
        var data = {"memberId": id};
        Services.responseHandler(
            apiName: "member/getMemberVehicles", body: data)
            .then((data) async {
          setState(() {
            isLoading = false;
          });
          if (data.Data != null && data.Data.length > 0) {
            setState(() {
              _vehicleData = data.Data[0]["Vehicles"];
              isLoading = false;
            });
          } else {
            setState(() {
              _vehicleData = data.Data[0]["Vehicles"];
              isLoading = false;
            });
          }
          if (data.Data.length > 0) {
            _showVehicle(context);
          } else
            showMsg("No Vehicle Data Found");
        }, onError: (e) {
          showMsg("Something Went Wrong Please Try Again");
          setState(() {
            isLoading = false;
          });
        });
      }
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
    }
  }

  _getFamilyMemberData() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {"societyId": SocietyId, "wingId": WingId, "flatId": FlatId};

        Services.responseHandler(apiName: "member/getFamilyMembers", body: data)
            .then((data) async {
          if (data.Data != null && data.Data.length > 0) {
            setState(() {
              _familyMemberData = data.Data;
              isLoading = false;
            });
          } else {
            setState(() {
              _familyMemberData = data.Data;
              isLoading = false;
            });
          }
          if (data.Data.length > 0) {
            _showFamilyMembers(context);
          } else
            showMsg("No Family Member Found");
        }, onError: (e) {
          showMsg("Something Went Wrong Please Try Again");

        });
      }
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
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
            new FlatButton(
              child: new Text("Okay"),
              onPressed: () {
                Navigator.of(context).pop();;
              },
            ),
          ],
        );
      },
    );
  }

  void _showVisitor(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            alignment: Alignment.topLeft,
            height: 350,
            padding: EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.person_pin_circle,
                      size: 25,
                      color: Colors.grey[700],
                    ),
                    Padding(padding: EdgeInsets.only(left: 5)),
                    Text(
                      "Visitor Details",
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700]),
                    ),
                  ],
                ),
                Divider(
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(4),
                    itemCount: _visitorData.length,
                    itemBuilder: (BuildContext context, int index) {
                      // String date;
                      // String time;
                      // List dateTime =
                      //     _visitorData[index]['Date'].toString().split(' ');
                      // date = dateTime[0];
                      // time = dateTime[1];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: <Widget>[
                            ClipOval(
                                child: _visitorData[index]["Image"] != null &&
                                    _visitorData[index]["Image"] != ""
                                    ? FadeInImage.assetNetwork(
                                    placeholder: '',
                                    image: IMG_URL +
                                        "${_visitorData[index]["Image"]}",
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.fill)
                                    : Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: appPrimaryMaterialColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(50))),
                                  child: Center(
                                    child: Text(
                                      "${_visitorData[index]["Name"].toString().substring(0, 1).toUpperCase()}",
                                      style: TextStyle(
                                          fontSize: 26,
                                          color: Colors.white),
                                    ),
                                  ),
                                )),
                            Padding(padding: EdgeInsets.only(left: 10)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "${_visitorData[index]["Name"]}",
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Color.fromRGBO(81, 92, 111, 1)),
                                  ),
                                  Text("${_visitorData[index]["ContactNo"]}",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13)),
                                ],
                              ),
                            ),
                            Container(
                              width: 100,
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(4))),
                              child: Column(
                                children: [
                                  // date != null || date != ''
                                  //     ? Text(
                                  //         "${date}",
                                  //         textAlign: TextAlign.center,
                                  //         style: TextStyle(
                                  //             fontSize: 16,
                                  //             fontWeight: FontWeight.w600,
                                  //             color: Colors.grey[600]),
                                  //       )
                                  //     : Container(),
                                  // time != null || time != ''
                                  //     ? Text(
                                  //         "${time}",
                                  //         textAlign: TextAlign.center,
                                  //         style: TextStyle(
                                  //             fontSize: 16,
                                  //             fontWeight: FontWeight.w600,
                                  //             color: Colors.grey[600]),
                                  //       )
                                  //     : Container(),
                                  _visitorData[index]['inDateTime'].length == 0
                                      ? Text("No Intime")
                                      : Text(
                                    '${_visitorData[index]['inDateTime'][0].toString()}',
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _showVehicle(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            alignment: Alignment.topLeft,
            height: 350,
            padding: EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.directions_bike,
                      size: 25,
                      color: Colors.grey[700],
                    ),
                    Padding(padding: EdgeInsets.only(left: 5)),
                    Text(
                      "Vehicle Details",
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700]),
                    ),
                  ],
                ),
                Divider(
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(4),
                    itemCount: _vehicleData.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              child: Text(
                                "${_vehicleData[index]["vehicleNo"]}",
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(81, 92, 111, 1)),
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.yellow[100],
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(3))),
                              padding: EdgeInsets.only(
                                  left: 8, top: 5, bottom: 5, right: 8),
                            ),
                            Text("${_vehicleData[index]["vehicleType"]}",
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _showFamilyMembers(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return _familyMemberData.length > 0
              ? Container(
            alignment: Alignment.topLeft,
            height: 350,
            padding: EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.supervised_user_circle,
                      size: 25,
                      color: Colors.grey[700],
                    ),
                    Padding(padding: EdgeInsets.only(left: 5)),
                    Text(
                      "Family Members Details",
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700]),
                    ),
                  ],
                ),
                Divider(
                  color: Colors.grey[300],
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(4),
                    itemCount: _familyMemberData.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: <Widget>[
                            ClipOval(
                                child: _familyMemberData[index][
                                "Image"] !=
                                    null &&
                                    _familyMemberData[index][
                                    "Image"] !=
                                        ""
                                    ? FadeInImage.assetNetwork(
                                    placeholder: '',
                                    image: IMG_URL +
                                        "${_familyMemberData[index]["Image"]}",
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.fill)
                                    : Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                      color: appPrimaryMaterialColor,
                                      borderRadius:
                                      BorderRadius.all(
                                          Radius.circular(50))),
                                  child: Center(
                                    child: Text(
                                      "${_familyMemberData[index]["Name"].toString().substring(0, 1).toUpperCase()}",
                                      style: TextStyle(
                                          fontSize: 26,
                                          color: Colors.white),
                                    ),
                                  ),
                                )),
                            Padding(padding: EdgeInsets.only(left: 10)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "${_familyMemberData[index]["Name"]}",
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Color.fromRGBO(
                                            81, 92, 111, 1)),
                                  ),
                                  widget.isContactNumberPrivate == "true" ?
                                  Text("********"+"${_familyMemberData[index]["ContactNo"]}".substring(8,10),
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple
                                    ),
                                  ): Text("${_familyMemberData[index]["ContactNo"]}"),
                                  // _familyMemberData[index]["IsPrivate"]
                                  //     .toString()
                                  //     .toLowerCase() ==
                                  //     "true"
                                  //     ? Text(
                                  //     "${_familyMemberData[index]["ContactNo"].toString().replaceRange(0, 7, "*")}")
                                  //     : Text(
                                  //     "${_familyMemberData[index]["ContactNo"]}",
                                  //     style: TextStyle(
                                  //         color: Colors.grey[600],
                                  //         fontSize: 13)),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                  top: 4, left: 5, right: 5, bottom: 4),
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(4))),
                              child: Text(
                                "${_familyMemberData[index]["Relation"]}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600]),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )
              : Center(child: Text('No Data Found'),);
        });
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
        : "${tempDate[2].toString().substring(0, 2)}\n${setMonth(DateTime.parse(date))}"
        .toString();

    return final_date;
  }

  setMonth(DateTime date) {
    switch (date.month) {
      case 1:
        return "Jan";
        break;
      case 2:
        return "Feb";
        break;
      case 3:
        return "Mar";
        break;
      case 4:
        return "Apr";
        break;
      case 5:
        return "May";
        break;
      case 6:
        return "Jun";
        break;
      case 7:
        return "Jul";
        break;
      case 8:
        return "Aug";
        break;
      case 9:
        return "Sep";
        break;
      case 10:
        return "Oct";
        break;
      case 11:
        return "Nov";
        break;
      case 12:
        return "Dec";
        break;
    }
  }

  getMemberRole(String memberId, String societyId) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {"memberId": memberId, "societyId": societyId};
        setState(() {
          isMemberLoading = true;
        });
        Services.responseHandler(apiName: "member/getMemberRole", body: data)
            .then((data) async {
          if (data.Data.length>0&&data.IsSuccess==true) {
            setState(() {
              // Profile = data.Data[0]["Image"];
              memberRoleDetails=data.Data;
              isMemberLoading = false;
              if(memberRoleDetails[0]["society"]["isAdmin"].toString()=='1'){
                isAdmin=true;
              }
              else{
                isAdmin=false;
              }
            });
          } else {
            setState(() {
              // Profile = data.Data[0]["Image"];
              isMemberLoading = false;
              // _advertisementData = data;
            });
          }
        }, onError: (e) {
          showMsg("Something Went Wrong.\nPlease Try Again");
          setState(() {
            isMemberLoading = false;
          });
        });
      }
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
    }
  }

  _makeAdmin() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // pr.show();
        var data = {
          "societyId": widget.memberData["society"]["societyId"].toString(),
          "memberId": widget.memberData["_id"].toString(),
          "makeAdmin":widget.memberData["society"]["isAdmin"]==0?1:0,
          "adminId" : MemberId
        };
        print("data");
        print(data);
        Services.responseHandler(apiName: "admin/assignAdminRole", body: data)
            .then((data) async {
          print("data displayed");
          print(data.Data);
          if (data.toString() == "1") {
            setState(() {
              Fluttertoast.showToast(
                  msg: "Made Admin Successfully",
                  backgroundColor: Colors.green,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.red);
            });
          }
          else if (data.toString() == "2") {
            setState(() {
              Fluttertoast.showToast(
                  msg: "Admin Revoked Successfully",
                  backgroundColor: Colors.green,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.red);
            });
          }
          else {
            setState(() {
              isLoading = false;
            });
          }
        }, onError: (e) {
          showMsg("Something Went Wrong Please Try Again");
          setState(() {
            isLoading = false;
          });
        });
      }
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
    }
  }

  @override
  Widget build(BuildContext context) {
    print('widget.memberData');
    print(widget.memberData);
    // print("memberRoleDetails");
    // print(memberRoleDetails);
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Member Profile",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        // actions: [
        //   widget.memberData["ContactNo"]!=ContactNo?Padding(
        //     padding: const EdgeInsets.all(10.0),
        //     child: isMemberLoading==false?OutlineButton(
        //       onPressed: () {
        //         print("function called");
        //         _makeAdmin();
        //         // Navigator.pushNamedAndRemoveUntil(context, '/HomeScreen', (route) => false);
        //         // Navigator.pushReplacementNamed(context, '/MemberProfile');// ask monil to make makeadmin api 17 - number
        //       },
        //       child: widget.memberData["society"]["isAdmin"]!=0?Text(
        //         "Revoke Admin",
        //         style: TextStyle(color: Colors.white),
        //       ):Text(
        //         "Make Admin",
        //         style: TextStyle(color: Colors.white),
        //       ),
        //       shape: RoundedRectangleBorder(
        //         side: new BorderSide(color: Colors.blue),
        //         //the outline color
        //         borderRadius: new BorderRadius.all(
        //           new Radius.circular(4),
        //         ),
        //       ),
        //     ):Container(),
        //   ):Container(),
        // ],
      ),
      body: isLoading
          ? LoadingComponent()
          : SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Padding(
                    padding: const EdgeInsets.only(top: 30),
                    child: ClipOval(
                      child: widget.memberData["Image"] != "" &&
                          widget.memberData["Image"] != null
                          ? FadeInImage.assetNetwork(
                          placeholder: '',
                          image: IMG_URL +
                              "${widget.memberData["Image"]}",
                          width: 90,
                          height: 90,
                          fit: BoxFit.fill)
                          : Container(
                        width: 70,
                        height: 70,
                        color: appPrimaryMaterialColor,
                        child: Center(
                          child: Text(
                            "${widget.memberData["Name"].toString().substring(0, 1).toUpperCase()}",
                                // .checkForNull(),
                            style: TextStyle(
                                fontSize: 25, color: Colors.white),
                          ),
                        ),
                      ),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("${widget.memberData["Name"]}",
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 13),
                child: Text(
                    "${widget.memberData["WingData"][0]["wingName"]} Wing",
                    style: TextStyle(
                      color: Colors.grey[800],
                    )),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, right: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                            ResidanceType,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            )),
                        Text(
                          "Resident Type",
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w300,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 9.0, left: 8.0, right: 8.0),
                    child: Container(
                      color: Colors.grey[300],
                      width: 1,
                      height: 25,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                            "${widget.memberData["FlatData"][0]["flatNo"]}",
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            )),
                        Text("Flat Number",
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  color: Colors.grey[200],
                  height: 1,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.call,
                  color: Colors.grey[500],
                  size: 22,
                ),
                title:widget.isContactNumberPrivate == "true" ?
                Text("********"+"${widget.memberData["ContactNo"]}".substring(8,10),
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple
                  ),
                ): Text("${widget.memberData["ContactNo"]}"),
                subtitle: Text("Mobile No"),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: Container(
                  color: Colors.grey[200],
                  height: 1,
                  width: MediaQuery.of(context).size.width / 1.4,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.mail,
                  color: Colors.grey[500],
                  size: 22,
                ),
                title: Text(
                    "${widget.memberData["EmailId"]}"),
                subtitle: Text("email"),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: Container(
                  color: Colors.grey[200],
                  height: 1,
                  width: MediaQuery.of(context).size.width / 1.5,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.account_balance,
                  color: Colors.grey[500],
                  size: 22,
                ),
                title: Text(
                    "${widget.memberData["CompanyName"]}"),
                subtitle: Text("Company Name"),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: Container(
                  color: Colors.grey[200],
                  height: 1,
                  width: MediaQuery.of(context).size.width / 1.5,
                ),
              ),
              ListTile(
                leading: Icon(Icons.location_on,
                    color: Colors.grey[500], size: 22),
                subtitle: Text("Business Description"),
                title: Text("${widget.memberData["BusinessDescription"]}"
                    ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: Container(
                  color: Colors.grey[200],
                  height: 1,
                  width: MediaQuery.of(context).size.width / 1.4,
                ),
              ),
              ListTile(
                leading: Image.asset('images/Blood.png',
                    width: 22, height: 22, color: Colors.grey[500]),
                title: Text(
                    "${widget.memberData["BloodGroup"]}"),
                subtitle: Text("Blood Group"),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: Container(
                  color: Colors.grey[200],
                  height: 1,
                  width: MediaQuery.of(context).size.width / 1.4,
                ),
              ),
              ListTile(
                leading: Image.asset('images/gender.png',
                    width: 22, height: 22, color: Colors.grey[500]),
                title: Text("${widget.memberData["Gender"]}"),
                subtitle: Text("Gender"),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(
              //       top: 8.0, left: 5, right: 5, bottom: 15),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: <Widget>[
              //       Flexible(
              //         child: GestureDetector(
              //           onTap: () {
              //             _getVisitor();
              //           },
              //           child: Container(
              //             width: MediaQuery.of(context).size.width,
              //             height: 50,
              //             margin: EdgeInsets.only(left: 6, right: 6),
              //             decoration: BoxDecoration(
              //                 color: Colors.green,
              //                 borderRadius:
              //                     BorderRadius.all(Radius.circular(4))),
              //             child: Column(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: <Widget>[
              //                 Icon(
              //                   Icons.person_pin_circle,
              //                   size: 20,
              //                   color: Colors.white,
              //                 ),
              //                 Text("Visitors",
              //                     style: TextStyle(
              //                         color: Colors.white, fontSize: 13)),
              //               ],
              //             ),
              //           ),
              //         ),
              //       ),
              //       Flexible(
              //         child: GestureDetector(
              //           onTap: () {
              //             _getFamilyMemberData();
              //           },
              //           child: Container(
              //             width: MediaQuery.of(context).size.width,
              //             height: 50,
              //             margin: EdgeInsets.only(left: 6, right: 6),
              //             decoration: BoxDecoration(
              //                 color: Colors.blue,
              //                 borderRadius:
              //                     BorderRadius.all(Radius.circular(4))),
              //             child: Column(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: <Widget>[
              //                 Icon(
              //                   Icons.supervised_user_circle,
              //                   size: 20,
              //                   color: Colors.white,
              //                 ),
              //                 Text("Family Member",
              //                     style: TextStyle(
              //                         color: Colors.white, fontSize: 13)),
              //               ],
              //             ),
              //           ),
              //         ),
              //       ),
              //       Flexible(
              //         child: GestureDetector(
              //           onTap: () {
              //             _getVehicle();
              //           },
              //           child: Container(
              //             width: MediaQuery.of(context).size.width,
              //             height: 50,
              //             margin: EdgeInsets.only(left: 6, right: 6),
              //             decoration: BoxDecoration(
              //                 color: Colors.deepPurpleAccent,
              //                 borderRadius:
              //                     BorderRadius.all(Radius.circular(4))),
              //             child: Column(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               children: <Widget>[
              //                 Icon(
              //                   Icons.directions_bike,
              //                   size: 20,
              //                   color: Colors.white,
              //                 ),
              //                 Text("Vehicles",
              //                     style: TextStyle(
              //                         color: Colors.white, fontSize: 13)),
              //               ],
              //             ),
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: GestureDetector(
                onTap: () {
                  // print('${widget.memberData}');
                  _getVisitor();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  margin: EdgeInsets.only(left: 6, right: 6),
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(Radius.circular(4))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.person_pin_circle,
                        size: 20,
                        color: Colors.white,
                      ),
                      Text("Visitors",
                          style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
            Flexible(
              child: GestureDetector(
                onTap: () {
                  _getFamilyMemberData();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  margin: EdgeInsets.only(left: 6, right: 6),
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(4))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.supervised_user_circle,
                        size: 20,
                        color: Colors.white,
                      ),
                      Text("Family Member",
                          style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
            Flexible(
              child: GestureDetector(
                onTap: () {
                  _getVehicle(widget.memberData["_id"]);
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 50,
                  margin: EdgeInsets.only(left: 6, right: 6),
                  decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      borderRadius: BorderRadius.all(Radius.circular(4))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.directions_bike,
                        size: 20,
                        color: Colors.white,
                      ),
                      Text("Vehicles",
                          style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
