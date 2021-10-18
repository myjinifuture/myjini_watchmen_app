import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/NoDataComponent.dart';
import 'package:smartsocietystaff/Component/VisitorOutSideComponent.dart';
import '../Common/Constants.dart' as cnst;

class VisitorOutSideList extends StatefulWidget {
  @override
  _VisitorOutSideListState createState() => _VisitorOutSideListState();
}

class _VisitorOutSideListState extends State<VisitorOutSideList> {
  List _visitorOutsideList = [];
  bool isLoading = false;

  @override
  void initState() {
    _fromDate = DateTime.now();
    _toDate = DateTime.now();
    getLocalData();
    _getInsideVisitor();
  }

  String societyId;
  getLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    societyId = prefs.getString(Session.SocietyId);
  }
  _getInsideVisitor({String fromDate,String toDate}) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var now = new DateTime.now();
        var formatter = new DateFormat('dd/MM/yyyy');
        String formattedDate = formatter.format(now);
        var data = {
          "societyId" : societyId,
          "fromDate" : fromDate==null?formattedDate:fromDate,
          "toDate" : toDate==null?formattedDate:toDate
        };
        print("data");
        print(data);
        Future res = Services.responseHandler(apiName: "watchman/getAllVisitorEntry_v1",body: data);
        setState(() {
          isLoading = true;
        });
        res.then((data) async {
          if (data.Data != null && data.Data.length > 0) {
            _visitorOutsideList.clear();
            setState(() {
              // _visitorOutsideList = data.Data;
              isLoading = false;
              for(int i=0;i<data.Data.length;i++){
                if(data.Data[i]["outDateTime"].length!=0){
                  _visitorOutsideList.add(data.Data[i]);
                }
              }
              _visitorOutsideList = _visitorOutsideList.reversed.toList();
              print("_visitorOutsideList");
              print(_visitorOutsideList);
            });
          } else {
            setState(() {
              _visitorOutsideList = data.Data;
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

  String month = "", selectedWing = "";
  String _format = 'yyyy-MMMM-dd';
  DateTimePickerLocale _locale = DateTimePickerLocale.en_us;
  DateTime _fromDate;
  DateTime _toDate;

  void _showFromDatePicker() {
    DatePicker.showDatePicker(
      context,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
        confirm: Text('Done', style: TextStyle(color: Colors.red)),
        cancel: Text('cancel', style: TextStyle(color: Colors.cyan)),
      ),
      initialDateTime: DateTime.now(),
      dateFormat: _format,
      locale: _locale,
      onChange: (dateTime, List<int> index) {
        setState(() {
          _fromDate = dateTime;
        });
      },
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          _fromDate = dateTime;
        });
      },
    );
  }

  void _showToDatePicker() {
    DatePicker.showDatePicker(
      context,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
        confirm: Text('Done', style: TextStyle(color: Colors.red)),
        cancel: Text('cancel', style: TextStyle(color: Colors.cyan)),
      ),
      initialDateTime: DateTime.now(),
      dateFormat: _format,
      locale: _locale,
      onChange: (dateTime, List<int> index) {
        setState(() {
          _toDate = dateTime;
        });
      },
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          _toDate = dateTime;
        });
      },
    );
  }

  List searchList = [];
  bool isSearching = false;

  @override
  Widget build(BuildContext context) {
    print(_fromDate);
    print("visitorOutsideList");
    print(_visitorOutsideList);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          body:
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            _showFromDatePicker();
                          },
                          child: Container(
                            height: 37,
                            decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius:
                                BorderRadius.all(Radius.circular(5))),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(padding: EdgeInsets.only(left: 5)),
                                Text(
                                  "${_fromDate.toString().substring(8, 10)}-${_fromDate.toString().substring(5, 7)}-${_fromDate.toString().substring(0, 4)}",
                                  style: TextStyle(fontSize: 13),
                                ),
                                Padding(padding: EdgeInsets.only(left: 5)),
                                Container(
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
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: Text("To ",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ),
                        Container(
                          height: 37,
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius:
                              BorderRadius.all(Radius.circular(5))),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(padding: EdgeInsets.only(left: 5)),
                              Text(
                                "${_toDate.toString().substring(8, 10)}-${_toDate.toString().substring(5, 7)}-${_toDate.toString().substring(0, 4)}",
                                style: TextStyle(fontSize: 13),
                              ),
                              Padding(padding: EdgeInsets.only(left: 5)),
                              GestureDetector(
                                onTap: () {
                                  _showToDatePicker();
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
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(left: 4)),
                    Expanded(
                      child: RaisedButton(
                          color: cnst.appPrimaryMaterialColor,
                          child: Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _getInsideVisitor(fromDate: _fromDate.toString().split(" ")[0].split("-")[2]+"/" +
                                _fromDate.toString().split(" ")[0].split("-")[1]+"/" +
                                _fromDate.toString().split(" ")[0].split("-")[0],toDate: _toDate.toString().split(" ")[0].split("-")[2]+"/" +
                                _toDate.toString().split(" ")[0].split("-")[1]+"/" +
                                _toDate.toString().split(" ")[0].split("-")[0]);
                            // getStaffData(_fromDate.toString(),
                            //     _toDate.toString(), selectedWing);
                          }),
                    ),
                  ],
                ),
              ),
              isLoading
                  ? Container(child: Center(child: CircularProgressIndicator()))
                  : !isSearching ? _visitorOutsideList.length > 0
                  ? Expanded(
                    child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  // _visitorOutsideList[index]["outDateTime"] = ["16/04/2021", "1:36:34 pm"];
                  return VisitorOutSideComponent(
                        _visitorOutsideList[index]);
                },
                itemCount: _visitorOutsideList.length,
              ),
                  )
                  : NoDataComponent():searchList.length > 0
                  ? Expanded(
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return VisitorOutSideComponent(
                        searchList[index]);
                  },
                  itemCount: searchList.length,
                ),
              )
                  : NoDataComponent(),
            ],
          ),
      ),
    );
  }
}
