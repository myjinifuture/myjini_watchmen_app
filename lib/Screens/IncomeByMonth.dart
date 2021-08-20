import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:smartsocietystaff/Common/Constants.dart' as cnst;
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/LoadingComponent.dart';
import 'package:smartsocietystaff/Component/NoDataComponent.dart';
import 'package:smartsocietystaff/Screens/IncomeListOfSingleMonth.dart';

class IncomeByMonth extends StatefulWidget {
  @override
  _IncomeByMonthState createState() => _IncomeByMonthState();
}

class _IncomeByMonthState extends State<IncomeByMonth> {
  List yearList = [];

  List _incomeData = [];
  bool isLoading = false;

  String yearValue = DateTime.now().year.toString();

  double incomeOfYear = 0;

  @override
  void initState() {
    _getBalanceSheetData(yearValue);
    setYearList();
  }

  setYearList() {
    for (int i = 2019; i <= DateTime.now().year; i++) {
      yearList.add(i.toString());
    }
  }

  _getBalanceSheetData(yearValue) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Future res = Services.getIncomeYearly(yearValue);
        setState(() {
          isLoading = true;
        });
        res.then((data) async {
          if (data != null && data.length > 0) {
            setState(() {
              _incomeData = data;
              isLoading = false;
            });
            setIncomeOfYear(data);
          } else {
            setState(() {
              isLoading = false;
              _incomeData = data;
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

  setIncomeOfYear(data) {
    setState(() {
      incomeOfYear = 0;
    });
    for (int i = 0; i < data.length; i++) {
      setState(() {
        incomeOfYear = incomeOfYear + data[i]["Amount"];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Income Report",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
      ),
      body: isLoading
          ? LoadingComponent()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 10),
                  child: SizedBox(
                    width: 90,
                    child: DropdownButton(
                      hint: Text('$yearValue'),
                      value: yearValue,
                      style: TextStyle(
                          fontSize: 17,
                          color: cnst.appPrimaryMaterialColor,
                          fontWeight: FontWeight.w600),
                      onChanged: (newValue) {
                        setState(() {
                          yearValue = newValue;
                        });
                        _getBalanceSheetData(newValue);
                      },
                      isExpanded: true,
                      items: yearList.map((year) {
                        return DropdownMenuItem(
                          child: Text(year),
                          value: year,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                _incomeData.length > 0
                    ? Expanded(
                        child: AnimationLimiter(
                          child: ListView.builder(
                            itemCount: _incomeData.length,
                            itemBuilder: (BuildContext context, int index) {
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 450),
                                child: SlideAnimation(
                                  horizontalOffset: 200.0,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  IncomeListOfSingleMonth(
                                                    month:
                                                        "${_incomeData[index]["MonthNo"]}",
                                                    monthName:
                                                        "${_incomeData[index]["MonthName"]}",
                                                    year: "${yearValue}",
                                                  )));
                                    },
                                    child: Card(
                                      elevation: 3,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 15,
                                            left: 10,
                                            right: 5,
                                            bottom: 15),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                "${_incomeData[index]["MonthName"]}",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey[700]),
                                              ),
                                            ),
                                            Text(
                                              "+ ${cnst.Inr_Rupee} ${double.parse(_incomeData[index]["Amount"].toString()).toStringAsFixed(2)}",
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.green[700]),
                                            ),
                                            Icon(
                                              Icons.arrow_right,
                                              color: Colors.grey,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : NoDataComponent(),
                _incomeData.length > 0
                    ? Container(
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
                              "YEARLY INCOME",
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
                                color: Colors.green,
                              ),
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Text(
                                "${cnst.Inr_Rupee}${incomeOfYear.toStringAsFixed(2)}",
                                style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container()
              ],
            ),
    );
  }
}
