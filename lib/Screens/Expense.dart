import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import 'package:smartsocietystaff/Common/Constants.dart' as cnst;
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/ExpenseComponent.dart';
import 'package:smartsocietystaff/Component/LoadingComponent.dart';
import 'package:smartsocietystaff/Component/NoDataComponent.dart';

class Expense extends StatefulWidget {
  @override
  _ExpenseState createState() => _ExpenseState();
}

class _ExpenseState extends State<Expense> {
  String month = "";

  DateTime selectedDate = DateTime.now();

  List _expenseData = [];
  bool isLoading = false;

  @override
  void initState() {
    _getExpenseData(
        selectedDate.month.toString(), selectedDate.year.toString());
    setMonth(DateTime.now());
  }

  _getExpenseData(String month, String year) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Future res = Services.getExpense(month, year);
        setState(() {
          isLoading = true;
        });
        res.then((data) async {
          if (data != null && data.length > 0) {
            setState(() {
              _expenseData = data;
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
              _expenseData = data;
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
        : "${tempDate[2].toString().substring(0, 2)}-${tempDate[1].toString()}-${tempDate[0].toString()}"
            .toString();

    return final_date;
  }

  setMonth(DateTime date) {
    switch (date.month) {
      case 1:
        setState(() {
          month = "Jan";
        });
        break;
      case 2:
        setState(() {
          month = "Feb";
        });
        break;
      case 3:
        setState(() {
          month = "Mar";
        });
        break;
      case 4:
        setState(() {
          month = "Apr";
        });
        break;
      case 5:
        setState(() {
          month = "May";
        });
        break;
      case 6:
        setState(() {
          month = "Jun";
        });
        break;
      case 7:
        setState(() {
          month = "Jul";
        });
        break;
      case 8:
        setState(() {
          month = "Aug";
        });
        break;
      case 9:
        setState(() {
          month = "Sep";
        });
        break;
      case 10:
        setState(() {
          month = "Oct";
        });
        break;
      case 11:
        setState(() {
          month = "Nov";
        });
        break;
      case 12:
        setState(() {
          month = "Dec";
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, "/Dashboard");
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Expenses",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/Dashboard");
            },
          ),
          actions: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, "/AddExpense");
              },
              child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                      width: 90,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 3, right: 3, top: 2, bottom: 2),
                        child: Text(
                          "Add\nExpense",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ))),
            )
          ],
        ),
        body: isLoading
            ? LoadingComponent()
            : _expenseData.length > 0
                ? Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 10.0, left: 8, bottom: 10, right: 10),
                          child: Container(
                            width: 180,
                            height: 45,
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: Text(
                                    "${month} - ${selectedDate.year}",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showMonthPicker(
                                            context: context,
                                            firstDate: DateTime(
                                                DateTime.now().year - 10),
                                            lastDate: DateTime.now(),
                                            initialDate: selectedDate)
                                        .then((date) {
                                      print("selected Date" + date.toString());
                                      if (date != null) {
                                        setState(() {
                                          selectedDate = date;
                                        });
                                        setMonth(date);
                                        _getExpenseData(date.month.toString(),
                                            date.year.toString());
                                      }
                                    });
                                    print("date " +
                                        selectedDate.month.toString());
                                  },
                                  child: Container(
                                    width: 50,
                                    height: 55,
                                    decoration: BoxDecoration(
                                        color: cnst.appPrimaryMaterialColor,
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(5),
                                            bottomRight: Radius.circular(5))),
                                    child: Icon(
                                      Icons.date_range,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Divider(),
                      _expenseData[0]["ExpenseData"].length > 0
                          ? Expanded(
                              child: AnimationLimiter(
                                child: ListView.builder(
                                  padding: EdgeInsets.all(0),
                                  itemCount:
                                      _expenseData[0]["ExpenseData"].length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return ExpenseComponent(
                                        _expenseData[0]["ExpenseData"][index],
                                        index);
                                  },
                                ),
                              ),
                            )
                          : NoDataComponent(),
                      _expenseData[0]["ExpenseData"].length > 0
                          ? Container(
                              height: 50,
                              padding: EdgeInsets.only(left: 10, right: 15),
                              decoration: BoxDecoration(
                                border: Border(
                                    top: BorderSide(color: Colors.grey[300])),
                                color: Colors.grey[200],
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "TOTAL EXPENSE",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: cnst.appPrimaryMaterialColor,
                                        fontSize: 15),
                                  ),
                                  Container(
                                    height: 35,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(6)),
                                      color: Colors.red,
                                    ),
                                    alignment: Alignment.center,
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: Text(
                                      "${cnst.Inr_Rupee}${double.parse(_expenseData[0]["ExpenseTotal"]["Total"].toString()).toStringAsFixed(2)}",
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                    ],
                  )
                : NoDataComponent(),
      ),
    );
  }
}
