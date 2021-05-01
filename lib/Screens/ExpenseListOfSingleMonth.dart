import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/LoadingComponent.dart';
import 'package:smartsocietystaff/Component/NoDataComponent.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as cnst;

class ExpenseListOfSingleMonth extends StatefulWidget {
  String month, monthName, year;

  ExpenseListOfSingleMonth({this.month, this.monthName, this.year});

  @override
  _ExpenseListOfSingleMonthState createState() =>
      _ExpenseListOfSingleMonthState();
}

class _ExpenseListOfSingleMonthState extends State<ExpenseListOfSingleMonth> {
  bool isLoading = false;
  List _monthExpenseData = [];

  @override
  void initState() {
    _getExpense();
  }

  _getExpense() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Future res = Services.getExpense(widget.month, widget.year);
        setState(() {
          isLoading = true;
        });
        res.then((data) async {
          if (data != null && data.length > 0) {
            setState(() {
              _monthExpenseData = data;
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
              _monthExpenseData = data;
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
      appBar: AppBar(
        title: Text("${widget.monthName} Expense",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
      ),
      body: isLoading
          ? LoadingComponent()
          : _monthExpenseData.length > 0
              ? Column(
                  children: <Widget>[
                    Expanded(
                      child: isLoading
                          ? LoadingComponent()
                          : AnimationLimiter(
                              child: ListView.builder(
                              itemCount:
                                  _monthExpenseData[0]["ExpenseData"].length,
                              itemBuilder: (BuildContext context, int index) {
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 450),
                                  child: SlideAnimation(
                                    verticalOffset: 60.0,
                                    child: /*Card(
                                      elevation: 4,
                                      margin: EdgeInsets.only(
                                          top: 9, left: 7, right: 7, bottom: 5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(9.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 5,
                                            right: 8,
                                            top: 6,
                                            bottom: 6),
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(4))),
                                              child: Text(
                                                "${setDate(_monthExpenseData[0]["ExpenseData"][index]["Date"])}",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey[600]),
                                              ),
                                            ),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10)),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    "${_monthExpenseData[0]["ExpenseData"][index]["PaymentType"]}",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.grey[800],
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                  Text(
                                                    "Ref No: ${_monthExpenseData[0]["ExpenseData"][index]["RefNo"]}",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Colors.grey[600]),
                                                  ),
                                                  Text(
                                                    "${_monthExpenseData[0]["ExpenseData"][index]["Notes"]}",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Colors.grey[600]),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              "${cnst.Inr_Rupee} ${double.parse(_monthExpenseData[0]["ExpenseData"][index]["Amount"].toString()).toStringAsFixed(2)}",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.red[700],
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )*/ Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9.0),
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.only(left: 7, top: 10, bottom: 10, right: 7),
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              width: 50,
                                              padding: EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius: BorderRadius.all(Radius.circular(4))),
                                              child: Text(
                                                "${setDate(_monthExpenseData[0]["ExpenseData"][index]["Date"])}",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey[600]),
                                              ),
                                            ),
                                            Padding(padding: EdgeInsets.only(left: 10)),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    "${_monthExpenseData[0]["ExpenseData"][index]["ExpenseName"]}",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.grey[800],
                                                        fontWeight: FontWeight.w600),
                                                  ),
                                                  _monthExpenseData[0]["ExpenseData"][index]["PaymentType"].toString().toLowerCase() ==
                                                      "cash"
                                                      ? Text(
                                                    "${_monthExpenseData[0]["ExpenseData"][index]["PaymentType"]}",
                                                    style: TextStyle(
                                                        fontSize: 14, color: Colors.grey[600]),
                                                  )
                                                      : _monthExpenseData[0]["ExpenseData"][index]["RefNo"] != ""
                                                      ? Text(
                                                    "Ref No: ${_monthExpenseData[0]["ExpenseData"][index]["RefNo"]}",
                                                    style: TextStyle(
                                                        fontSize: 14, color: Colors.grey[600]),
                                                  )
                                                      : Container(),
                                                  Text(
                                                    "${_monthExpenseData[0]["ExpenseData"][index]["Notes"]}",
                                                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              "- ${cnst.Inr_Rupee}${double.parse(_monthExpenseData[0]["ExpenseData"][index]["Amount"].toString()).toStringAsFixed(2)}",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.red[700],
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )),
                    ),
                    Container(
                      height: 50,
                      padding: EdgeInsets.only(left: 10, right: 15),
                      decoration: BoxDecoration(
                        border:
                            Border(top: BorderSide(color: Colors.grey[300])),
                        color: Colors.grey[200],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Text(
                              "${cnst.Inr_Rupee}${double.parse(_monthExpenseData[0]["ExpenseTotal"]["Total"].toString()).toStringAsFixed(2)}",
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              : NoDataComponent(),
    );
  }
}
