import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Services.dart';

class AddAMC extends StatefulWidget {
  @override
  _AddAMCState createState() => _AddAMCState();
}

class _AddAMCState extends State<AddAMC> {
  TextEditingController txtTitle = new TextEditingController();
  TextEditingController txtAmt = new TextEditingController();

  String _format = 'yyyy-MMMM-dd';
  DateTimePickerLocale _locale = DateTimePickerLocale.en_us;

  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();
  bool isLoading = false;
  ProgressDialog pr;



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
  }

  void _showDatePicker(type) {
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
      onConfirm: (dateTime, List<int> index) {
        if (type == "from") {
          setState(() {
            _fromDate = dateTime;
          });
        } else if (type == "to") {
          setState(() {
            _toDate = dateTime;
          });
        }
      },
    );
  }

  _addAMC() async {
    if (txtTitle.text != '' && txtAmt.text != '') {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          // pr.show();
          SharedPreferences preferences = await SharedPreferences.getInstance();
          String SocietyId = preferences.getString(Session.SocietyId);

          var data = {
            "Id": 0,
            "ServiceName": txtTitle.text,
            "StartDate": _fromDate.toString(),
            "EndDate": _toDate.toString(),
            "Amount": txtAmt.text,
            "SocietyId": SocietyId
          };

          Services.AddAMC(data).then((data) async {
            // pr.hide();
            if (data.Data != "0" && data.IsSuccess == true) {
              Navigator.pushReplacementNamed(context, "/amcList");
              Fluttertoast.showToast(
                  msg: "AMC Added Successfully",
                  toastLength: Toast.LENGTH_LONG);
            } else {
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
    } else {
      showMsg("Please Fill All Data.", title: "Alert !");
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, "/amcList");
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add AMC",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/amcList");
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 12, left: 8, right: 8),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    controller: txtTitle,
                    scrollPadding: EdgeInsets.all(0),
                    decoration: InputDecoration(
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.black),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        prefixIcon: Icon(
                          Icons.title,
                          //color: cnst.appPrimaryMaterialColor,
                        ),
                        hintText: "AMC Name"),
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "From Date",
                            style: TextStyle(fontSize: 13),
                          ),
                          Padding(padding: EdgeInsets.only(top: 4)),
                          GestureDetector(
                            onTap: () {
                              _showDatePicker("from");
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 45,
                              padding: EdgeInsets.all(5),
                              margin: EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.grey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(
                                      "${_fromDate.toString().substring(8, 10)}-${_fromDate.toString().substring(5, 7)}-${_fromDate.toString().substring(0, 4)}",
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(left: 8)),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "To Date",
                            style: TextStyle(fontSize: 13),
                          ),
                          Padding(padding: EdgeInsets.only(top: 4)),
                          GestureDetector(
                            onTap: () {
                              _showDatePicker("to");
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 45,
                              padding: EdgeInsets.all(5),
                              margin: EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: Colors.grey),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Text(
                                      "${_toDate.toString().substring(8, 10)}-${_toDate.toString().substring(5, 7)}-${_toDate.toString().substring(0, 4)}",
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    controller: txtAmt,
                    scrollPadding: EdgeInsets.all(0),
                    decoration: InputDecoration(
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.black),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        prefixIcon: Icon(
                          Icons.attach_money,
                          //color: cnst.appPrimaryMaterialColor,
                        ),
                        hintText: "Amount"),
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: RaisedButton(
                    onPressed: () {
                      _addAMC();
                    },
                    color: appPrimaryMaterialColor[700],
                    textColor: Colors.white,
                    shape: StadiumBorder(),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                            "Add AMC",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
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
