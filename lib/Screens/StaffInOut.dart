import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/LoadingComponent.dart';
import 'package:smartsocietystaff/Component/NoDataComponent.dart';
import 'package:smartsocietystaff/Component/StaffComponent.dart';
import 'package:smartsocietystaff/Component/StaffComponentBywing.dart';
import 'package:smartsocietystaff/Component/VisitorComponent.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as cnst;

class StaffInOut extends StatefulWidget {
  String wingType, wingId;

  StaffInOut({this.wingType, this.wingId});

  @override
  _StaffInOutState createState() => _StaffInOutState();
}

class _StaffInOutState extends State<StaffInOut> {
  bool isLoading = false;
  List _StaffData = [];

  String month = "";
  String _format = 'yyyy-MMMM-dd';
  DateTimePickerLocale _locale = DateTimePickerLocale.en_us;
  DateTime _fromDate;
  DateTime _toDate;

  @override
  void initState() {
    _fromDate = DateTime.now();
    _toDate = DateTime.now();
    getStaffData(_fromDate.toString(),_toDate.toString());
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

  getStaffData(String fromDate,String toDate) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Future res = Services.getStaffByWing(widget.wingId,fromDate,toDate);
        setState(() {
          isLoading = true;
        });
        res.then((data) async {
          if (data != null && data.length > 0) {
            setState(() {
              _StaffData = data;
              isLoading = false;
            });
          } else {
            setState(() {
              _StaffData = data;
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
      onClose: () => print("----- onClose -----"),
      onCancel: () => print('onCancel'),
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
      onClose: () => print("----- onClose -----"),
      onCancel: () => print('onCancel'),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.wingType} Wing Staffs",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
      ),
      body: Column(
        children: <Widget>[
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
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      padding: EdgeInsets.only(left: 5,right: 5),
                      child: Text("To ",style: TextStyle(fontSize: 13,fontWeight: FontWeight.w600)),
                    ),
                    Container(
                      height: 37,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      child: Icon(Icons.search,color: Colors.white,),
                      onPressed: (){
                        getStaffData(_fromDate.toString(), _toDate.toString());
                      }),
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: isLoading
                ? LoadingComponent()
                : _StaffData.length > 0
                ? Container(
              child: AnimationLimiter(
                child: ListView.builder(
                  itemCount: _StaffData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return StaffComponentBywing(_StaffData[index],index);
                  },
                ),
              ),
            )
                : NoDataComponent(),
          ),
        ],
      ),
    );
  }
}
