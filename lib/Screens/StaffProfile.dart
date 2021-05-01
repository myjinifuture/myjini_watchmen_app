import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:smartsocietystaff/Common/ClassList.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as constant;
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/masktext.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AddDocument.dart';

class StaffProfile extends StatefulWidget {
  var staffData;

  StaffProfile({this.staffData});

  @override
  _StaffProfileState createState() => _StaffProfileState();
}

class _StaffProfileState extends State<StaffProfile> {
  TextEditingController nameText = new TextEditingController();
  TextEditingController contactText = new TextEditingController();
  TextEditingController addressText = new TextEditingController();
  TextEditingController vehicleText = new TextEditingController();
  TextEditingController workText = new TextEditingController();
  TextEditingController purposeText = new TextEditingController();

  List<dynamic> wingclasslist = [];
  WingClass wingClass;
  String SocietyId;
  String selectedWing;
  List _selectedFlatlist = [];
  List FlatData = [];
  List allWingList = [];
  List finalSelectList = [];
  List allFlatList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setData();
    _getLocalData();
  }

  String societyId = "",_FlateNo;
  _getLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      societyId = prefs.getString(Session.SocietyId);
    });
    _WingListData(societyId);
  }

  _WingListData(String societyId) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var body = {
          "societyId" : societyId
        };
        Services.responseHandler(apiName: "admin/getAllWingOfSociety",body: body).then((data) async {
          if (data !=null) {
            setState(() {
              allWingList = data.Data;
            });
          }
        }, onError: (e) {
          Fluttertoast.showToast(
              msg: "$e", toastLength: Toast.LENGTH_LONG);
        });
      } else {
        Fluttertoast.showToast(
            msg: "No Internet Connection.", toastLength: Toast.LENGTH_LONG);
      }
    } on SocketException catch (_) {
      Fluttertoast.showToast(
          msg: "Something Went Wrong", toastLength: Toast.LENGTH_LONG);
    }
  }


  setData() {
    nameText.text = widget.staffData["Name"];
    contactText.text = widget.staffData["ContactNo1"];
    vehicleText.text = widget.staffData['VehicleNo'];
    workText.text = widget.staffData["Work"];
    // purposeText.text = widget.staffData["Purpose"];
    addressText.text = widget.staffData["Address"];

    // _getWingList();
  }


  _flatSelectionBottomsheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Select Flat",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: GridView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: FlatData.length,
                    itemBuilder: (BuildContext context, int i) {
                      return Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: InkWell(
                          onTap: () {
                            if (FlatData.length > 0) {
                              setState(() {
                                // selectFlat.insert(index, FlatData[i]["display"]);
                                _FlateNo = FlatData[i]["display"];
                              });
                              Navigator.pop(context);
                            }
                          },
                          child: Card(
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      '${FlatData[i]["display"].toString()}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                      ;
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    )),
              )
            ],
          );
        });
  }

  GetFlatData(String WingId,String societyId) async {
    try {
      //check Internet Connection
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // setState(() {
        //   // pr.show();
        // });

        var data = {
          "societyId" : societyId,
          "wingId" : WingId
        };
        Services.responseHandler(apiName: "admin/getFlatsOfSociety",body: data).then((data) async {
          // // pr.hide();
          if (data.Data != null && data.Data.length > 0) {
            FlatData.clear();
            setState(() {
              for(int i=0;i<data.Data.length;i++){
                FlatData.add(
                    {
                      "display" : data.Data[i]["flatNo"],
                      "value" : data.Data[i]["flatNo"],
                      "Ids" : data.Data[i]["_id"]
                    }
                );
              }
              _flatSelectionBottomsheet(context);
            });
            print("----->" + data.toString());
          } else {
            setState(() {
              // // pr.hide();
            });
          }
        }, onError: (e) {
          setState(() {
            // pr.hide();
          });
          showHHMsg("Try Again.", "");
        });
      } else {
        setState(() {
          // pr.hide();
        });
        showHHMsg("No Internet Connection.", "");
      }
    } on SocketException catch (_) {
      showHHMsg("No Internet Connection.", "");
    }
  }

  showHHMsg(String title, String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(title),
          content: new Text(msg),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              color: Colors.grey[100],
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String selectedWingId,selectedSocietyId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Edit Staff",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {},
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                child: widget.staffData["staffImage"] != '' &&
                        widget.staffData["staffImage"] != null
                    ? FadeInImage.assetNetwork(
                        placeholder: '',
                        image: "http://smartsociety.itfuturz.com/" +
                            "${widget.staffData["staffImage"]}",
                        width: 60,
                        height: 60,
                        fit: BoxFit.fill)
                    : Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(75),
                          color: constant.appPrimaryMaterialColor,
                        ),
                        child: Center(
                          child: Text(
                            "${widget.staffData["Name"].toString().substring(0, 1).toUpperCase()}",
                            style: TextStyle(fontSize: 35, color: Colors.white),
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                height: 50,
                child: TextFormField(
                  controller: nameText,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(5.0),
                        borderSide: new BorderSide(),
                      ),
                      counterText: "",
                      labelText: "Staff Name",
                      hasFloatingPlaceholder: true,
                      labelStyle: TextStyle(fontSize: 13)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                height: 50,
                child: TextFormField(
                  controller: contactText,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  decoration: InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(5.0),
                        borderSide: new BorderSide(),
                      ),
                      counterText: "",
                      labelText: "Contact Number",
                      hasFloatingPlaceholder: true,
                      labelStyle: TextStyle(fontSize: 13)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                height: 50,
                child: TextFormField(
                  inputFormatters: [
                    MaskedTextInputFormatter(
                      mask: 'xx-xx-xx-xxxx',
                      separator: '-',
                    ),
                  ],
                  controller: vehicleText,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(5.0),
                        borderSide: new BorderSide(),
                      ),
                      counterText: "",
                      labelText: "Enter Vehicle Number",
                      hintText: "XX-00-XX-0000",
                      hasFloatingPlaceholder: true,
                      labelStyle: TextStyle(fontSize: 13)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                height: 50,
                child: TextFormField(
                  controller: addressText,
                  keyboardType: TextInputType.text,
                  maxLength: 10,
                  decoration: InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(5.0),
                        borderSide: new BorderSide(),
                      ),
                      counterText: "",
                      labelText: "Staff Address",
                      hasFloatingPlaceholder: true,
                      labelStyle: TextStyle(fontSize: 13)),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 10.0),
                      child: Text(
                        "Select Wing",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width / 2.3,
                        decoration: BoxDecoration(
                            border: Border.all(width: 1),
                            borderRadius:
                            BorderRadius.all(Radius.circular(6.0))),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton<dynamic>(
                                icon: Icon(
                                  Icons.chevron_right,
                                  size: 20,
                                ),
                                hint: allWingList != null &&
                                    allWingList != "" &&
                                    allWingList.length > 0
                                    ? Text("Select Wing",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                                    : Text(
                                  "Wing Not Found",
                                  style: TextStyle(fontSize: 14),
                                ),
                                value:selectedWing,
                                onChanged: (val) {
                                  setState(() {
                                    selectedWing = val;
                                    // selectedWing[index] = val;
                                    // selectedWing.insert(index, val);
                                  });
                                  for(int i=0;i<allWingList.length;i++){
                                    if(val == allWingList[i]["wingName"]){
                                      selectedWingId = allWingList[i]["_id"];
                                      selectedSocietyId = allWingList[i]["societyId"];
                                      break;
                                    }
                                  }
                                  GetFlatData(selectedWingId,selectedSocietyId);
                                },
                                items: allWingList.map((dynamic val) {
                                  return new DropdownMenuItem<dynamic>(
                                    value: val["wingName"],
                                    child: Text(
                                      val["wingName"],
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  );
                                }).toList(),
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 10.0),
                      child: Text(
                        "Select Flat",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          border: Border.all(color: Colors.black)),
                      width: 120,
                      height: 50,
                      child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  _FlateNo == "" || _FlateNo== null
                                      ? 'Flat No'
                                      : _FlateNo,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600, fontSize: 14),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                size: 18,
                              )
                            ],
                          )),
                    )
                  ],
                )
              ],
            ),
          /*  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 10.0),
                  child: Text(
                    "Select Wing",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(6.0))),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: DropdownButtonHideUnderline(
                          child: DropdownButton<dynamic>(
                        icon: Icon(
                          Icons.chevron_right,
                          size: 20,
                        ),
                        hint: wingclasslist.length > 0
                            ? Text("Select Wing",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600))
                            : Text(
                                "Wing Not Found",
                                style: TextStyle(fontSize: 14),
                              ),
                        value: selectedWing,
                        onChanged: (val) {
                          setState(() {
                            selectedWing = val;
                            _selectedFlatlist.clear();
                            FlatData.clear();
                          });
                          GetFlatData(val);
                        },
                        items: wingclasslist.map((dynamic value) {
                          return new DropdownMenuItem<String>(
                            value: value["WingName"],
                            child: Text(
                              value["WingName"],
                              style: TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList(),
                      )),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.4,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SizedBox(
                      child: MultiSelectFormField(
                        autovalidate: false,
                        titleText: "Select Flat",
                        dataSource: FlatData,
                        textField: "FlatNo",
                        valueField: 'FlatNo',
                        okButtonLabel: 'OK',
                        cancelButtonLabel: 'CANCEL',
                        hintText: 'Select Flat',
                        value: _selectedFlatlist,
                        onSaved: (value) {
                          setState(() {
                            setState(() {
                              _selectedFlatlist = value;
                            });
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  height: 60,
                  child: RaisedButton(
                      child: Text(
                        "+",
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                      onPressed: () {
                        print("allWingList");
                        print(allWingList);
                        print("_selectedFlatlist");
                        print(_selectedFlatlist);
                        print("finalSelectList");
                        print(finalSelectList);
                        if (!allWingList.contains(wingClass)) {
                          for (int i = 0; i < _selectedFlatlist.length; i++) {
                            finalSelectList.add({
                              "WingId": wingClass.WingId,
                              "FlatId": _selectedFlatlist[i]
                            });
                          }
                          setState(() {
                            allFlatList.add(_selectedFlatlist);
                            allWingList.add(wingClass);
                          });
                          setState(() {
                            _selectedFlatlist = [];
                            wingClass = null;
                          });
                        } else {
                          int index = allWingList.indexOf(wingClass);
                          print(index);
                          setState(() {
                            allWingList.removeAt(index);
                            allFlatList.removeAt(index);
                          });
                          for (int i = 0; i < _selectedFlatlist.length; i++) {
                            finalSelectList.add({
                              "WingId": wingClass.WingId,
                              "FlatId": _selectedFlatlist[i]
                            });
                          }
                          setState(() {
                            allFlatList.add(_selectedFlatlist);
                            allWingList.add(wingClass);
                          });
                          setState(() {
                            _selectedFlatlist = [];
                            wingClass = null;
                          });
                        }
                      }),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Selected Wing & Flat"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: allWingList.length * 60.0,
                child: ListView.separated(
                  itemCount: allWingList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Row(
                          children: <Widget>[
                            Text(
                              allWingList[index]["wingName"] +
                                  '-' +
                                  allFlatList[index]
                                      .toString()
                                      .replaceAll("[", "")
                                      .replaceAll("]", ""),
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider();
                  },
                ),
              ),
            ),*/
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: RaisedButton(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Update Staff",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16),
                          ),
                        ],
                      ),
                      color: Colors.green,
                      onPressed: () {})),
            ),
          ],
        ),
      ),
    );
  }
}
