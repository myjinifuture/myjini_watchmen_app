import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:smartsocietystaff/Common/Constants.dart' as cnst;
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/LoadingComponent.dart';
import 'package:smartsocietystaff/Component/NoDataComponent.dart';

class MemberProfile extends StatefulWidget {
  var memberData;

  MemberProfile({this.memberData});

  @override
  _MemberProfileState createState() => _MemberProfileState();
}

class _MemberProfileState extends State<MemberProfile> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List _visitorData = [];
  List _familyMemberData = [];
  List _vehicleData = [];
  bool isLoading = false;

  _getVisitor() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Future res =
            Services.getVisitorByMemberId(widget.memberData["Id"].toString());
        setState(() {
          isLoading = true;
        });
        res.then((data) async {
          if (data != null && data.length > 0) {
            setState(() {
              _visitorData = data;
              isLoading = false;
            });
          } else {
            setState(() {
              _visitorData = data;
              isLoading = false;
            });
          }
          if (data.length > 0) {
            _showVisitor(context);
          } else
            showMsg("No Visitor Found");
        }, onError: (e) {
          showMsg("Something Went Wrong Please Try Again");
          setState(() {
            isLoading = false;
          });
        });
      } else {
        showMsg("No Internet Connection.");
        setState(() {
          isLoading = false;
        });
      }
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
      setState(() {
        isLoading = false;
      });
    }
  }

  _getVehicle() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Future res =
            Services.getVehicleByMember(widget.memberData["Id"].toString());
        setState(() {
          isLoading = true;
        });
        res.then((data) async {
          if (data != null && data.length > 0) {
            setState(() {
              _vehicleData = data;
              isLoading = false;
            });
          } else {
            setState(() {
              _vehicleData = data;
              isLoading = false;
            });
          }
          if (data.length > 0) {
            _showVehicle(context);
          } else
            showMsg("No Vehicle Data Found");
        }, onError: (e) {
          showMsg("Something Went Wrong Please Try Again");
          setState(() {
            isLoading = false;
          });
        });
      } else {
        showMsg("No Internet Connection.");
        setState(() {
          isLoading = false;
        });
      }
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
      setState(() {
        isLoading = false;
      });
    }
  }

  _getFamilyMemberData() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Future res =
            Services.getFamilyByMember(widget.memberData["Id"].toString());
        setState(() {
          isLoading = true;
        });
        res.then((data) async {
          if (data != null && data.length > 0) {
            setState(() {
              _familyMemberData = data;
              isLoading = false;
            });
          } else {
            setState(() {
              _familyMemberData = data;
              isLoading = false;
            });
          }
          if (data.length > 0) {
            _showFamilyMembers(context);
          } else
            showMsg("No Family Member Found");
        }, onError: (e) {
          showMsg("Something Went Wrong Please Try Again");
          setState(() {
            isLoading = false;
          });
        });
      } else {
        showMsg("No Internet Connection.");
        setState(() {
          isLoading = false;
        });
      }
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
      setState(() {
        isLoading = false;
      });
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
                Navigator.of(context).pop();
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
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: <Widget>[
                            ClipOval(
                                child: _visitorData[index]["Image"] != null &&
                                        _visitorData[index]["Image"] != ""
                                    ? FadeInImage.assetNetwork(
                                        placeholder: '',
                                        image:
                                            "http://smartsociety.itfuturz.com/" +
                                                "${_visitorData[index]["Image"]}",
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.fill)
                                    : Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                            color: cnst.appPrimaryMaterialColor,
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
                              width: 50,
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4))),
                              child: Text(
                                "${setDate(_visitorData[index]["Date"])}",
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
                                "${_vehicleData[index]["VehicleNo"]}",
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
                            Text("${_vehicleData[index]["Type"]}",
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
                                      child: _familyMemberData[index]
                                                      ["Image"] !=
                                                  null &&
                                              _familyMemberData[index]
                                                      ["Image"] !=
                                                  ""
                                          ? FadeInImage.assetNetwork(
                                              placeholder: '',
                                              image: "http://smartsociety.itfuturz.com/" +
                                                  "${_familyMemberData[index]["Image"]}",
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.fill)
                                          : Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                  color: cnst
                                                      .appPrimaryMaterialColor,
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
                                        _familyMemberData[index]["IsPrivate"]
                                                    .toString()
                                                    .toLowerCase() ==
                                                "true"
                                            ? Text(
                                                "${_familyMemberData[index]["ContactNo"].toString().replaceRange(0, 7, "*")}")
                                            : Text(
                                                "${_familyMemberData[index]["ContactNo"]}",
                                                style: TextStyle(
                                                    color: Colors.grey[600],
                                                    fontSize: 13)),
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
              : NoDataComponent();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Member Profile",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
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
                                    image: "http://smartsociety.itfuturz.com/" +
                                        "${widget.memberData["Image"]}",
                                    width: 90,
                                    height: 90,
                                    fit: BoxFit.fill)
                                : Container(
                                    width: 70,
                                    height: 70,
                                    color: cnst.appPrimaryMaterialColor,
                                    child: Center(
                                      child: Text(
                                        "${widget.memberData["Name"].toString().substring(0, 1).toUpperCase()}",
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
                      child: Text("${widget.memberData["Wing"]} Wing",
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
                              Text("${widget.memberData["ResidenceType"]}",
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  )),
                              Text("Resident Type",
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.w300,
                                    fontSize: 12,
                                  )),
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
                              Text("${widget.memberData["FlatNo"]}",
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
                      title: Text("${widget.memberData["ContactNo"]}"),
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
                      title: Text("${widget.memberData["EmailId"]}"),
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
                      title: Text("${widget.memberData["CompanyName"]}"),
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
                      title:
                          Text("${widget.memberData["BusinessDescription"]}"),
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
                      title: Text("${widget.memberData["BloodGroup"]}"),
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
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 8.0, left: 5, right: 5, bottom: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            child: GestureDetector(
                              onTap: () {
                                _getVisitor();
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 50,
                                margin: EdgeInsets.only(left: 6, right: 6),
                                decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4))),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.person_pin_circle,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    Text("Visitors",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 13)),
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4))),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.supervised_user_circle,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    Text("Family Member",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: GestureDetector(
                              onTap: () {
                                _getVehicle();
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                height: 50,
                                margin: EdgeInsets.only(left: 6, right: 6),
                                decoration: BoxDecoration(
                                    color: Colors.deepPurpleAccent,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4))),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.directions_bike,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    Text("Vehicles",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
