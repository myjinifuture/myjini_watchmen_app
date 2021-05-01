import 'dart:async';
import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:easy_permission_validator/easy_permission_validator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as cnst;
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/LoadingComponent.dart';
import 'package:smartsocietystaff/Screens/MemberProfile.dart';
import 'package:url_launcher/url_launcher.dart';

ProgressDialog pr;

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String memberType = "";
  String barcode = "";
  bool isLoading = false;

  Widget appBarTitle = new Text("MYJINI");

  List searchMemberData = new List();
  List memberData = [];
  bool _isSearching = false;
  DateTime currentBackPressTime;
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  StreamSubscription iosSubscription;
  String fcmToken = "";

  TextEditingController _controller = TextEditingController();

  Icon icon = new Icon(
    Icons.search,
    color: Colors.white,
  );

  var _AdminMenuList = [
    {
      "image": "images/notice_dashboard.png",
      "count": "0",
      "title": "Notice",
      "screen": "Notice"
    },
    {
      "image": "images/document_dashboard.png",
      "count": "0",
      "title": "Document",
      "screen": "Document"
    },
    {
      "image": "images/directory_dashboard.png",
      "count": "0",
      "title": "Directory",
      "screen": "Directory"
    },
    {
      "image": "images/visitor_icon.png",
      "count": "0",
      "title": "Visitors",
      "screen": "Visitor"
    },
    {
      "image": "images/Staff.png",
      "count": "0",
      "title": "Staffs",
      "screen": "Staff"
    },
    {
      "image": "images/complaint_icon.png",
      "count": "0",
      "title": "Complaints",
      "screen": "Complaints"
    },
    {
      "image": "images/rules_icon.png",
      "count": "0",
      "title": "Rules & Regulations",
      "screen": "RulesAndRegulations"
    },
    {
      "image": "images/event.png",
      "count": "0",
      "title": "Events",
      "screen": "Events"
    },
    {
      "image": "images/income.png",
      "count": "0",
      "title": "Income",
      "screen": "Income"
    },
    {
      "image": "images/expense.png",
      "count": "0",
      "title": "Expense",
      "screen": "Expense"
    },
    {
      "image": "images/balance_sheet.png",
      "count": "0",
      "title": "Balance Sheet",
      "screen": "BalanceSheet"
    },
    {
      "image": "images/polling.png",
      "count": "0",
      "title": "Polling",
      "screen": "Polling"
    },
    {
      "image": "images/amc_icon.png",
      "count": "0",
      "title": "AMCs",
      "screen": "amcList"
    }
  ];

  @override
  void initState() {
    pr = new ProgressDialog(context, type: ProgressDialogType.Normal);
    pr.style(
        message: "Please Wait",
        borderRadius: 10.0,
        progressWidget: Container(
          padding: EdgeInsets.all(15),
          child: CircularProgressIndicator(
              //backgroundColor: cnst.appPrimaryMaterialColor,
              ),
        ),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.w600));
    _getLocalData();
    _getMembers();
    _getDashboardCount();

    if (Platform.isIOS) {
      iosSubscription =
          _firebaseMessaging.onIosSettingsRegistered.listen((data) {
        print("FFFFFFFF" + data.toString());
        saveDeviceToken();
      });
      _firebaseMessaging
          .requestNotificationPermissions(IosNotificationSettings());
    } else {
      saveDeviceToken();
    }
    final permissionValidator = EasyPermissionValidator(
      context: context,
      appName: 'Easy Permission Validator',
    );
    permissionValidator.camera();
  }

  saveDeviceToken() async {
    _firebaseMessaging.getToken().then((String token) {
      print("Original Token:$token");
      var tokendata = token.split(':');
      setState(() {
        fcmToken = token;
        sendFCMTokan(token);
      });
      print("FCM Token : $fcmToken");
    });
  }

  sendFCMTokan(var FcmToken) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Future res = Services.SendTokanToServer(FcmToken);
        res.then((data) async {}, onError: (e) {
          print("Error : on Login Call");
        });
      }
    } on SocketException catch (_) {}
  }

  _getLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      memberType = prefs.getString(Session.Role);
    });
  }

  _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.pushReplacementNamed(context, "/Login");
  }

  _getMembers() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Future res = Services.getMembersAllData();
        setState(() {
          isLoading = true;
        });
        res.then((data) async {
          if (data != null && data.length > 0) {
            setState(() {
              memberData = data;
            });
          } else {
            setState(() {});
          }
        }, onError: (e) {
          showMsg("Something Went Wrong Please Try Again");
          setState(() {});
        });
      } else {
        showMsg("No Internet Connection.");
        setState(() {});
      }
    } on SocketException catch (_) {
      showMsg("No Internet Connection.");
      setState(() {});
    }
  }

  _getDashboardCount() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Future res = Services.getDashBoardCount();
        setState(() {
          isLoading = true;
        });
        res.then((data) async {
          if (data != null && data.length > 0) {
            setDashboardData(data);
            setState(() {
              isLoading = false;
            });
          } else {
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

  setDashboardData(data) {
    for (int i = 0; i < _AdminMenuList.length; i++) {
      if (_AdminMenuList[i]["title"] == "Notice")
        setState(() {
          _AdminMenuList[i]["count"] = data[0]["NoticeCount"].toString();
        });
      if (_AdminMenuList[i]["title"] == "Document")
        setState(() {
          _AdminMenuList[i]["count"] = data[0]["DocumentCount"].toString();
        });
      if (_AdminMenuList[i]["title"] == "Directory")
        setState(() {
          _AdminMenuList[i]["count"] = data[0]["Directory"].toString();
        });
      if (_AdminMenuList[i]["title"] == "Visitors")
        setState(() {
          _AdminMenuList[i]["count"] = data[0]["VisitorCount"].toString();
        });
      if (_AdminMenuList[i]["title"] == "Complaints")
        setState(() {
          _AdminMenuList[i]["count"] = data[0]["ComplaintCount"].toString();
        });
      if (_AdminMenuList[i]["title"] == "Rules & Regulations")
        setState(() {
          _AdminMenuList[i]["count"] = data[0]["RulesCount"].toString();
        });
      if (_AdminMenuList[i]["title"] == "Events")
        setState(() {
          _AdminMenuList[i]["count"] = data[0]["EventCount"].toString();
        });
      if (_AdminMenuList[i]["title"] == "Income") {
        if (data[0]["IncomeTotal"].toString() != "null" &&
            data[0]["IncomeTotal"].toString() != "") {
          setState(() {
            _AdminMenuList[i]["count"] =
                double.parse(data[0]["IncomeTotal"].toString())
                    .toStringAsFixed(2)
                    .toString();
          });
        }
      }
      if (_AdminMenuList[i]["title"] == "Expense") {
        if (data[0]["ExpenseTotal"].toString() != "null" &&
            data[0]["ExpenseTotal"].toString() != "") {
          setState(() {
            _AdminMenuList[i]["count"] =
                double.parse(data[0]["ExpenseTotal"].toString())
                    .toStringAsFixed(2)
                    .toString();
          });
        }
      }
      if (_AdminMenuList[i]["title"] == "Balance Sheet")
        setState(() {
          _AdminMenuList[i]["count"] =
              double.parse(data[0]["Balance"].toString())
                  .toStringAsFixed(2)
                  .toString();
        });
      if (_AdminMenuList[i]["title"] == "Polling")
        setState(() {
          _AdminMenuList[i]["count"] = data[0]["PollingCount"].toString();
        });
    }
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      print(barcode);
      if (barcode != null) {
        _addVisitor(barcode);
      } else
        showMsg("Try Again..");
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.barcode =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
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

  _addVisitor(String barcode) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // pr.show();
        Services.AddVisitorByScan(barcode).then((data) async {
          if (data.Data == "1") {
            // pr.hide();
            showMsg("Visitor Verified Successfully");
          } else {
            // pr.hide();
            showMsg("Visitor Is Not Verified");
          }
        }, onError: (e) {
          // pr.hide();
          print("Error : on Delete Notice $e");
          showMsg("Something Went Wrong Please Try Again");
          // pr.hide();
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
          content: new Text("Are You Sure You Want To Logout ?"),
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
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  _openWhatsapp(mobile) {
    String whatsAppLink = cnst.whatsAppLink;
    String urlwithmobile = whatsAppLink.replaceAll("#mobile", "91$mobile");
    String urlwithmsg = urlwithmobile.replaceAll("#msg", "");
    launch(urlwithmsg);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (_isSearching)
          _handleSearchEnd();
        else {
          DateTime now = DateTime.now();
          if (currentBackPressTime == null ||
              now.difference(currentBackPressTime) > Duration(seconds: 2)) {
            currentBackPressTime = now;
            Fluttertoast.showToast(msg: "Double Tap To Exit App");
            return Future.value(false);
          }
          return Future.value(true);
        }
        //return Future.value(true);
      },
      child: Scaffold(
        appBar: buildAppBar(context),
        body: _isSearching
            ? ListView.builder(
                itemCount: searchMemberData.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    color: Colors.white,
                    child: ExpansionTile(
                      title: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 1.0, top: 1, bottom: 1),
                                child: searchMemberData[index]["Image"] != '' &&
                                        searchMemberData[index]["Image"] != null
                                    ? FadeInImage.assetNetwork(
                                        placeholder: '',
                                        image: "http://smartsociety.itfuturz.com/" +
                                            "${searchMemberData[index]["Image"]}",
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.fill)
                                    : Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          color: cnst.appPrimaryMaterialColor,
                                        ),
                                        child: Center(
                                          child: Text(
                                            "${searchMemberData[index]["Name"].toString().substring(0, 1).toUpperCase()}",
                                            style: TextStyle(
                                                fontSize: 25,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, bottom: 6.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text("${searchMemberData[index]["Name"]}",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[700])),
                                      Row(
                                        children: <Widget>[
                                          Text("Flat No:"),
                                          Text(
                                              "${searchMemberData[index]["FlatNo"]}")
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              IconButton(
                                icon: Image.asset("images/whatsapp_icon.png",
                                    width: 30, height: 30),
                                onPressed: () {
                                  _openWhatsapp(
                                      searchMemberData[index]["ContactNo"]);
                                },
                              ),
                              IconButton(
                                  icon: Icon(Icons.call, color: Colors.brown),
                                  onPressed: () {
                                    launch("tel:" +
                                        searchMemberData[index]["ContactNo"]);
                                  }),
                              IconButton(
                                  icon: Icon(Icons.remove_red_eye,
                                      color: cnst.appPrimaryMaterialColor),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MemberProfile(
                                                  memberData:
                                                      searchMemberData[index],
                                                )));
                                  }),
                              IconButton(
                                  icon: Icon(Icons.share), onPressed: () {}),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                },
              )
            : isLoading
                ? LoadingComponent()
                : Container(
                    color: Colors.grey[200],
                    padding: EdgeInsets.only(top: 15, left: 10, right: 10),
                    child: AnimationLimiter(
                      child: GridView.builder(
                          itemCount: _AdminMenuList.length,
                          gridDelegate:
                              new SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio:
                                      MediaQuery.of(context).size.width /
                                          (MediaQuery.of(context).size.height /
                                              4.2),
                                  crossAxisCount: 2),
                          itemBuilder: (BuildContext context, int index) {
                            return AnimationConfiguration.staggeredGrid(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              columnCount: 2,
                              child: ScaleAnimation(
                                child: FadeInAnimation(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacementNamed(context,
                                          "/${_AdminMenuList[index]["screen"]}");
                                    },
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                      child: Container(
                                        margin: EdgeInsets.all(6),
                                        child: Row(
                                          children: <Widget>[
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(left: 7)),
                                            Image.asset(
                                                "${_AdminMenuList[index]["image"]}",
                                                width: 37,
                                                height: 37,
                                                fit: BoxFit.fill),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10)),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                      "${_AdminMenuList[index]["count"]}",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                  Text(
                                                    "${_AdminMenuList[index]["title"]}",
                                                    textAlign: TextAlign.start,
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                            Colors.grey[600]),
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
                            );
                          }),
                    )),
      ),
    );
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: appBarTitle,
      actions: <Widget>[
        new IconButton(
          icon: icon,
          onPressed: () {
            if (this.icon.icon == Icons.search) {
              this.icon = new Icon(
                Icons.close,
                color: Colors.white,
              );
              this.appBarTitle = new TextField(
                controller: _controller,
                style: new TextStyle(
                  color: Colors.white,
                ),
                decoration: new InputDecoration(
                    prefixIcon: new Icon(Icons.search, color: Colors.white),
                    hintText: "Search...",
                    hintStyle: new TextStyle(color: Colors.white)),
                onChanged: searchOperation,
              );
              _handleSearchStart();
            } else {
              _handleSearchEnd();
            }
          },
        ),
        IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              _showConfirmDialog();
            })
      ],
    );
  }

  void _handleSearchStart() {
    setState(() {
      _isSearching = true;
    });
  }

  void _handleSearchEnd() {
    setState(() {
      this.icon = new Icon(
        Icons.search,
        color: Colors.white,
      );
      setState(() {});
      this.appBarTitle = Text("MYJINI");
      _isSearching = false;
      searchMemberData.clear();
      _controller.clear();
    });
  }

  void searchOperation(String searchText) {
    searchMemberData.clear();
    if (_isSearching != null) {
      if (searchText != "") {
        for (int i = 0; i < memberData.length; i++) {
          String name = memberData[i]["Name"];
          String flat = memberData[i]["FlatNo"].toString();
          if (name.toLowerCase().contains(searchText.toLowerCase()) ||
              flat.toLowerCase().contains(searchText.toLowerCase())) {
            searchMemberData.add(memberData[i]);
          }
        }
      } else
        searchMemberData.clear();
    }
    setState(() {});
  }
}
