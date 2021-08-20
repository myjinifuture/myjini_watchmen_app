import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/LoadingComponent.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as cnst;

class AddPolling extends StatefulWidget {
  @override
  _AddPollingState createState() => _AddPollingState();
}

class _AddPollingState extends State<AddPolling> {
  TextEditingController txtQuestion = new TextEditingController();
  TextEditingController txtOptionCount = new TextEditingController();

  bool isLoading = false;

  String _pollingId = "";

  ProgressDialog pr;

  int _enteredCount = 0;

  List<TextEditingController> _optionList = [];

  @override
  void initState() {
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

  _createPollingQuation() async {
    if (txtQuestion.text != "") {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          String SocietyId = preferences.getString(Session.SocietyId);

          var formData = {
            "Id": "0",
            "Title": txtQuestion.text,
            "SocietyId": SocietyId,
          };

          // pr.show();
          Services.AddPollingQuation(formData).then((data) async {
            // pr.hide();
            if (data.Data != "0" && data.IsSuccess == true) {
              setState(() {
                _pollingId = data.Data;
              });
              Fluttertoast.showToast(
                  msg: "Create Your Options", gravity: ToastGravity.TOP);
            } else {
              // pr.hide();
              showMsg(data.Message, title: "Error");
            }
          }, onError: (e) {
            // pr.hide();
            showMsg("Try Again.");
          });
        }
      } on SocketException catch (_) {
        // pr.hide();
        showMsg("No Internet Connection.");
      }
    } else
      Fluttertoast.showToast(
          msg: "Please Select All Fields",
          backgroundColor: Colors.red,
          gravity: ToastGravity.TOP,
          textColor: Colors.white);
  }

  _createPolling() async {
    if (txtQuestion.text != "") {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          var formData = [];

          for (int i = 0; i < _enteredCount; i++) {
            formData.add({
              "Id": "0",
              "Title": "${_optionList[i].text}",
              "PollingId": "$_pollingId"
            });
          }

          print("Final Data" + formData.toString());

          // pr.show();
          Services.AddPollingAnswer(formData).then((data) async {
            // pr.hide();
            if (data.Data != "0" && data.IsSuccess == true) {
              Fluttertoast.showToast(
                  msg: "Polling Saved Successfully",
                  backgroundColor: Colors.green,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.white);
              Navigator.pushReplacementNamed(context, "/Polling");
            } else {
              // pr.hide();
              showMsg(data.Message, title: "Error");
            }
          }, onError: (e) {
            // pr.hide();
            showMsg("Try Again.");
          });
        }
      } on SocketException catch (_) {
        // pr.hide();
        showMsg("No Internet Connection.");
      }
    } else
      Fluttertoast.showToast(
          msg: "Please Select All Fields",
          backgroundColor: Colors.red,
          gravity: ToastGravity.TOP,
          textColor: Colors.white);
  }

  _editPolling() async {
    if (txtQuestion.text != "") {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          var formData = {
            "Id": "$_pollingId",
            "Title": txtQuestion.text,
          };

          // pr.show();
          Services.UpdatePolling(formData).then((data) async {
            // pr.hide();
            if (data.Data != "0" && data.IsSuccess == true) {
              setState(() {
                _pollingId = data.Data;
              });
              Fluttertoast.showToast(
                  msg: "Create Your Options", gravity: ToastGravity.TOP);
            } else {
              // pr.hide();
              showMsg(data.Message, title: "Error");
            }
          }, onError: (e) {
            // pr.hide();
            showMsg("Try Again.");
          });
        }
      } on SocketException catch (_) {
        // pr.hide();
        showMsg("No Internet Connection.");
      }
    } else
      Fluttertoast.showToast(
          msg: "Please Select All Fields",
          backgroundColor: Colors.red,
          gravity: ToastGravity.TOP,
          textColor: Colors.white);
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
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, "/Polling");
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add Polling",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/Polling");
            },
          ),
        ),
        body: isLoading
            ? LoadingComponent()
            : SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.all(8),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: TextFormField(
                              controller: txtQuestion,
                              scrollPadding: EdgeInsets.all(0),
                              decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                      borderSide:
                                          new BorderSide(color: Colors.black),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  prefixIcon: Icon(
                                    Icons.title,
                                  ),
                                  hintText: "Ask Question"),
                              keyboardType: TextInputType.text,
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(left: 5)),
                          _pollingId != ""
                              ? Container(
                                  height: 40,
                                  width: 70,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: MaterialButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            new BorderRadius.circular(10.0)),
                                    color: cnst.appPrimaryMaterialColor,
                                    onPressed: () {
                                      _editPolling();
                                    },
                                    child: Text(
                                      "Edit",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                      _pollingId != ""
                          ? Card(
                              margin: EdgeInsets.only(top: 8),
                              child: Container(
                                padding: EdgeInsets.all(7),
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    Text(
                                      "How many Options ?",
                                      style: TextStyle(
                                          color: cnst.appPrimaryMaterialColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          width: 200,
                                          height: 50,
                                          margin: EdgeInsets.only(top: 8),
                                          child: TextFormField(
                                            controller: txtOptionCount,
                                            scrollPadding: EdgeInsets.all(0),
                                            decoration: InputDecoration(
                                                border: new OutlineInputBorder(
                                                    borderSide: new BorderSide(
                                                        color: Colors.black),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                5))),
                                                prefixIcon: Icon(
                                                  Icons.equalizer,
                                                ),
                                                hintText: "Enter Numbers",
                                                hintStyle:
                                                    TextStyle(fontSize: 12)),
                                            keyboardType: TextInputType.number,
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        _enteredCount > 0
                                            ? Container(
                                                height: 40,
                                                width: 70,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                child: MaterialButton(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          new BorderRadius
                                                              .circular(10.0)),
                                                  color: cnst
                                                      .appPrimaryMaterialColor,
                                                  onPressed: () {
                                                    setState(() {
                                                      _enteredCount = int.parse(
                                                          txtOptionCount.text);
                                                    });
                                                    print(_enteredCount);
                                                    for (int i = 0;i < _enteredCount; i++) {
                                                      TextEditingController
                                                          txtOption =
                                                          new TextEditingController();
                                                      _optionList
                                                          .add(txtOption);
                                                    }
                                                  },
                                                  child: Text(
                                                    "Edit",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14.0,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                              )
                                            : Container()
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      _enteredCount > 0
                          ? Container(
                              height: 50.0 * _enteredCount,
                              child: ListView.builder(
                                padding: EdgeInsets.all(0),
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: _enteredCount,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    height: 45,
                                    margin: EdgeInsets.only(
                                        top: 5, left: 5, right: 5),
                                    child: TextFormField(
                                      controller: _optionList[index],
                                      scrollPadding: EdgeInsets.all(0),
                                      decoration: InputDecoration(
                                          border: new OutlineInputBorder(
                                              borderSide: new BorderSide(
                                                  color: Colors.black),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          hintText: "Option ${index + 1}",
                                          hintStyle: TextStyle(
                                            fontSize: 13,
                                          )),
                                      keyboardType: TextInputType.text,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(),
                      _pollingId == ""
                          ? Padding(
                              padding: EdgeInsets.only(top: 20),
                              child: RaisedButton(
                                onPressed: () {
                                  _createPollingQuation();
                                  /*setState(() {
                                    _pollingId = "1";
                                  });*/
                                },
                                color: appPrimaryMaterialColor[700],
                                textColor: Colors.white,
                                shape: StadiumBorder(),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.save,
                                      size: 25,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        "Create Polling",
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            )
                          : _enteredCount == 0
                              ? Padding(
                                  padding: EdgeInsets.only(top: 20),
                                  child: RaisedButton(
                                    onPressed: () {
                                      setState(() {
                                        _enteredCount =
                                            int.parse(txtOptionCount.text);
                                      });
                                      print(_enteredCount);
                                      for (int i = 0; i < _enteredCount; i++) {
                                        TextEditingController txtOption =
                                            new TextEditingController();
                                        _optionList.add(txtOption);
                                      }
                                    },
                                    color: appPrimaryMaterialColor[700],
                                    textColor: Colors.white,
                                    shape: StadiumBorder(),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.save,
                                          size: 25,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Text(
                                            "Create Options",
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                              : Padding(
                                  padding: EdgeInsets.only(top: 20),
                                  child: RaisedButton(
                                    onPressed: () {
                                      bool isRight = true;
                                      for (int i = 0; i < _enteredCount; i++) {
                                        if (_optionList[i].text == "") {
                                          isRight = false;
                                        }
                                      }
                                      if (isRight)
                                        _createPolling();
                                      else
                                        Fluttertoast.showToast(
                                            msg: "Please Fill All The Options",
                                            gravity: ToastGravity.TOP);
                                    },
                                    color: appPrimaryMaterialColor[700],
                                    textColor: Colors.white,
                                    shape: StadiumBorder(),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.save,
                                          size: 25,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Text(
                                            "Submit Polling",
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
