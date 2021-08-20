import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:smartsocietystaff/Common/Constants.dart' as cnst;
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/LoadingComponent.dart';
import 'package:smartsocietystaff/Component/NoDataComponent.dart';

class BalanceSheet extends StatefulWidget {
  @override
  _BalanceSheetState createState() => _BalanceSheetState();
}

class _BalanceSheetState extends State<BalanceSheet> {
  List _balaceSheetData = [];
  bool isLoading = false;

  @override
  void initState() {
    _getBalanceSheetData();
  }

  _getBalanceSheetData() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Future res = Services.getBalanceSheet();
        setState(() {
          isLoading = true;
        });
        res.then((data) async {
          if (data != null && data.length > 0) {
            setState(() {
              _balaceSheetData = data;
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
              _balaceSheetData = data;
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, "/Dashboard");
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Balance Sheet",
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
        ),
        body: isLoading
            ? LoadingComponent()
            : _balaceSheetData.length > 0
                ? Container(
                    padding: EdgeInsets.only(top: 11, left: 6, right: 6),
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 50,
                          padding: EdgeInsets.only(
                              left: 5, right: 10, top: 5, bottom: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            color: Colors.grey[200],
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.account_balance_wallet,
                                color: Colors.grey,
                              ),
                              Padding(padding: EdgeInsets.only(left: 10)),
                              Expanded(
                                child: Text(
                                  "OPENING BALANCE",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                      fontSize: 15),
                                ),
                              ),
                              Text(
                                "${cnst.Inr_Rupee} ${double.parse(_balaceSheetData[0]["OpeningBalance"].toString()).toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimationLimiter(
                          child: AnimationConfiguration.staggeredList(
                            position: 1,
                            duration: const Duration(milliseconds: 550),
                            child: SlideAnimation(
                              horizontalOffset: 400.0,
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding:
                                    EdgeInsets.only(top: 15, left: 4, right: 4),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, "/IncomeByMonth");
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 7, bottom: 7),
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Text(
                                                    "Total Income",
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: cnst
                                                            .appPrimaryMaterialColor),
                                                  ),
                                                ),
                                                Text(
                                                  "+ ${cnst.Inr_Rupee} ${double.parse(_balaceSheetData[0]["Income"].toString()).toStringAsFixed(2)}",
                                                  style: TextStyle(
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.green[700]),
                                                ),
                                                Icon(
                                                  Icons.arrow_right,
                                                  color: Colors.grey,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Divider(),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, "/ExpenseByMonth");
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                top: 7, bottom: 7),
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Text(
                                                    "Total Expense",
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: cnst
                                                            .appPrimaryMaterialColor),
                                                  ),
                                                ),
                                                Text(
                                                    "- ${cnst.Inr_Rupee} ${double.parse(_balaceSheetData[0]["Expense"].toString()).toStringAsFixed(2)}",
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Colors.red[700])),
                                                Icon(
                                                  Icons.arrow_right,
                                                  color: Colors.grey,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 1, right: 1, top: 15),
                          child: Container(
                            height: 50,
                            padding: EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              color: _balaceSheetData[0]["Expense"] <
                                      _balaceSheetData[0]["Income"] +
                                          _balaceSheetData[0]["OpeningBalance"]
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            child: Row(
                              children: <Widget>[
                                Image.asset(
                                  "images/give-money.png",
                                  width: 25,
                                  height: 25,
                                  color: Colors.white,
                                ),
                                Padding(padding: EdgeInsets.only(left: 15)),
                                Expanded(
                                  child: Text(
                                    "On Hand Balance",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        fontSize: 15),
                                  ),
                                ),
                                Text(
                                  "${cnst.Inr_Rupee} ${double.parse(_balaceSheetData[0]["Balance"].toString()).toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : NoDataComponent(),
      ),
    );
  }
}
