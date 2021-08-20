import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartsocietystaff/Common/ClassList.dart';
import 'package:smartsocietystaff/Common/ClassList.dart';

import 'package:smartsocietystaff/Common/Constants.dart' as cnst;
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/LoadingComponent.dart';

class AddIncome extends StatefulWidget {
  @override
  _AddIncomeState createState() => _AddIncomeState();
}

class _AddIncomeState extends State<AddIncome> {
  TextEditingController txtRefNo = new TextEditingController();
  TextEditingController txtNotes = new TextEditingController();
  TextEditingController txtAmount = new TextEditingController();
  TextEditingController txtIncomeSourceName = new TextEditingController();

  List<incomeSource> _incomeSourceList = [];
  List<paymentTypeClass> _paymentTypeList = [];
  bool isLoading = false;

  incomeSource _incomeSource;
  paymentTypeClass _paymentType;
  String currentMode = "";

  @override
  void initState() {
    _getIncomeSource();
    _getPaymentType();
  }

  _getIncomeSource() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Future res = Services.getIncomeSource();
        setState(() {
          isLoading = true;
        });
        res.then((data) async {
          if (data != null && data.length > 0) {
            setState(() {
              _incomeSourceList = data;
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
              _incomeSourceList = data;
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

  _getPaymentType() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Future res = Services.getPaymentMode();
        setState(() {
          isLoading = true;
        });
        res.then((data) async {
          if (data != null && data.length > 0) {
            setState(() {
              _paymentTypeList = data;
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
              _paymentTypeList = data;
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

  _onSourceSelect(val) {
    setState(() {
      print(val.sourceName);
      _incomeSource = val;
      currentMode = val.sourceName;
    });
  }

  _onPaymentModeSelect(val) {
    setState(() {
      print(val.name);
      _paymentType = val;
    });
  }

  _addIncome() async {
    if (txtNotes.text != "" && txtAmount.text != "") {
      if (_incomeSource != null && _paymentType != null) {
        try {
          final result = await InternetAddress.lookup('google.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            String SocietyId = preferences.getString(Session.SocietyId);

            setState(() {
              isLoading = true;
            });

            var formData = {
              "Id": "0",
              "IncomeSourceId": _incomeSource.id,
              "SocietyId": SocietyId,
              "Date": DateTime.now().toString(),
              "RefNo": txtRefNo.text,
              "Type": _paymentType.name,
              "Notes": txtNotes.text,
              "Amount": txtAmount.text
            };

            Services.AddIncome(formData).then((data) async {
              if (data.Data != "0" && data.IsSuccess == true) {
                setState(() {
                  isLoading = false;
                });
                Fluttertoast.showToast(
                    msg: "Income Added Successfully",
                    backgroundColor: Colors.green,
                    gravity: ToastGravity.TOP,
                    textColor: Colors.white);
                Navigator.pushReplacementNamed(context, "/Income");
              } else {
                setState(() {
                  isLoading = false;
                });
                showMsg(data.Message, title: "Error");
              }
            }, onError: (e) {
              setState(() {
                isLoading = false;
              });
              showMsg("Try Again.");
            });
          }
        } on SocketException catch (_) {
          showMsg("No Internet Connection.");
        }
      } else
        Fluttertoast.showToast(
            msg: "Please Select All Fields",
            backgroundColor: Colors.red,
            gravity: ToastGravity.TOP,
            textColor: Colors.white);
    } else
      Fluttertoast.showToast(
          msg: "Please Fill All Details",
          backgroundColor: Colors.red,
          gravity: ToastGravity.TOP,
          textColor: Colors.white);
  }

  void _showIncomeSourceDailog() {
    setState(() {
      txtIncomeSourceName.text = "";
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Add Income Source"),
          content: TextFormField(
            controller: txtIncomeSourceName,
            scrollPadding: EdgeInsets.all(0),
            decoration: InputDecoration(
                hintText: "Income Source Name"),
            keyboardType: TextInputType.text,
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Cancel",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Add",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600)),
              onPressed: () {
                Navigator.of(context).pop();
                _addIncomeSource();
              },
            ),
          ],
        );
      },
    );
  }

  void _showConfirmDialog(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("MYJINI"),
          content:
              new Text("Are You Sure You Want To Delete this Income Source ?"),
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
                _deleteIncomeSource(id);
              },
            ),
          ],
        );
      },
    );
  }

  _addIncomeSource() async {
    if (txtIncomeSourceName.text != "") {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          String SocietyId = preferences.getString(Session.SocietyId);

          setState(() {
            isLoading = true;
          });

          var formData = {
            "Id": "0",
            "SocietyId": SocietyId,
            "Title": txtIncomeSourceName.text
          };

          Services.AddIncomeSource(formData).then((data) async {
            if (data.Data != "0" && data.IsSuccess == true) {
              setState(() {
                isLoading = false;
              });
              Fluttertoast.showToast(
                  msg: "Income Source Added Successfully",
                  backgroundColor: Colors.green,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.white);
              _getIncomeSource();
            } else {
              setState(() {
                isLoading = false;
              });
              showMsg(data.Message, title: "Error");
            }
          }, onError: (e) {
            setState(() {
              isLoading = false;
            });
            showMsg("Try Again.");
          });
        }
      } on SocketException catch (_) {
        showMsg("No Internet Connection.");
      }
    } else
      Fluttertoast.showToast(
          msg: "Enter Income Source Name",
          backgroundColor: Colors.red,
          gravity: ToastGravity.TOP,
          textColor: Colors.white);
  }

  _deleteIncomeSource(String id) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          isLoading = true;
        });
        Services.DeleteIncomeSource(id).then((data) async {
          if (data.Data == "1" && data.IsSuccess == true) {
            setState(() {
              isLoading = false;
            });
            _getIncomeSource();
          } else {
            setState(() {
              isLoading = false;
            });
            showMsg("Income Source Is Not Delete");
          }
        }, onError: (e) {
          setState(() {
            isLoading = false;
          });
          showMsg("Something Went Wrong Please Try Again");
        });
      }
    } on SocketException catch (_) {
      showMsg("Something Went Wrong");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, "/Income");
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add Income",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/Income");
            },
          ),
        ),
        body: isLoading
            ? LoadingComponent()
            : Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 15, left: 15),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _incomeSourceList.length > 0
                                ? SizedBox(
                                    height: 60,
                                    child: InputDecorator(
                                      decoration: new InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          fillColor: Colors.white,
                                          border: new OutlineInputBorder(
                                            borderRadius:
                                                new BorderRadius.circular(10),
                                          )),
                                      child: DropdownButtonHideUnderline(
                                          child: DropdownButton<incomeSource>(
                                        hint: _incomeSourceList != null &&
                                                _incomeSourceList != "" &&
                                                _incomeSourceList.length > 0
                                            ? Text("Select Income Source")
                                            : Text(
                                                "Income Source Not Found",
                                                style: TextStyle(fontSize: 14),
                                              ),
                                        value: _incomeSource,
                                        onChanged: (val) {
                                          _onSourceSelect(val);
                                        },
                                        items: _incomeSourceList
                                            .map((incomeSource Source) {
                                          return DropdownMenuItem<incomeSource>(
                                            value: Source,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  Source.sourceName,
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ),
                                                currentMode != Source.sourceName
                                                    ? IconButton(
                                                        icon: Icon(
                                                          Icons.clear,
                                                          color: Colors.grey,
                                                          size: 22,
                                                        ),
                                                        onPressed: () {
                                                          _showConfirmDialog(
                                                              Source.id);
                                                        })
                                                    : Container()
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      )),
                                    ),
                                  )
                                : Container(),
                          ),
                          IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                _showIncomeSourceDailog();
                              })
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      SizedBox(
                        height: 60,
                        child: InputDecorator(
                          decoration: new InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              fillColor: Colors.white,
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(10),
                                //borderSide: new BorderSide(),
                              )),
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton<paymentTypeClass>(
                            hint: _paymentTypeList != null &&
                                    _paymentTypeList != "" &&
                                    _paymentTypeList.length > 0
                                ? Text("Select Income Type")
                                : Text(
                                    "Income Type Not Found",
                                    style: TextStyle(fontSize: 14),
                                  ),
                            value: _paymentType,
                            onChanged: (val) {
                              _onPaymentModeSelect(val);
                            },
                            items:
                                _paymentTypeList.map((paymentTypeClass Source) {
                              return new DropdownMenuItem<paymentTypeClass>(
                                value: Source,
                                child: Text(
                                  Source.name,
                                  style: TextStyle(color: Colors.black),
                                ),
                              );
                            }).toList(),
                          )),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      _paymentType == null
                          ? Container(
                              margin: EdgeInsets.only(bottom: 10),
                              child: TextFormField(
                                controller: txtRefNo,
                                scrollPadding: EdgeInsets.all(0),
                                decoration: InputDecoration(
                                    border: new OutlineInputBorder(
                                        borderSide:
                                            new BorderSide(color: Colors.black),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    prefixIcon: Icon(
                                      Icons.info,
                                    ),
                                    counterText: "",
                                    hintText: "Reference Number"),
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: Colors.black),
                              ),
                            )
                          : _paymentType.name.toLowerCase() != "cash"
                              ? Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: TextFormField(
                                    controller: txtRefNo,
                                    scrollPadding: EdgeInsets.all(0),
                                    decoration: InputDecoration(
                                        border: new OutlineInputBorder(
                                            borderSide: new BorderSide(
                                                color: Colors.black),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        prefixIcon: Icon(
                                          Icons.info,
                                        ),
                                        counterText: "",
                                        hintText: "Reference Number"),
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                )
                              : Container(),
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: TextFormField(
                          controller: txtNotes,
                          scrollPadding: EdgeInsets.all(0),
                          decoration: InputDecoration(
                              border: new OutlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.black),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              prefixIcon: Icon(
                                Icons.sms_failed,
                              ),
                              hintText: "Description"),
                          keyboardType: TextInputType.text,
                          maxLines: 2,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: TextFormField(
                          controller: txtAmount,
                          scrollPadding: EdgeInsets.all(0),
                          decoration: InputDecoration(
                              border: new OutlineInputBorder(
                                  borderSide:
                                      new BorderSide(color: Colors.black),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              prefixIcon: Icon(
                                Icons.attach_money,
                              ),
                              hintText: "Amount"),
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(top: 10),
                        height: 45,
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          color: cnst.appPrimaryMaterialColor,
                          minWidth: MediaQuery.of(context).size.width - 20,
                          onPressed: () {
                            _addIncome();
                          },
                          child: Text(
                            "Submit",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17.0,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
