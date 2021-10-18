import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartsocietystaff/Common/ClassList.dart';
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as constant;
import 'package:smartsocietystaff/Component/masktext.dart';
import 'dart:math';
class AddStaff extends StatefulWidget {
  @override
  _AddStaffState createState() => _AddStaffState();
}

class _AddStaffState extends State<AddStaff> {
  List<staffClass> _staffTypeList = [];
  staffClass _staffClass;
  bool isLoading = false;
  File image;
  ProgressDialog pr;
  int wingflatcount = 0;
  File _image;
  String Gender;
  String _FlateNo;
  bool ispressed = false;

  TextEditingController txtName = TextEditingController();
  TextEditingController txtaddress = TextEditingController();
  TextEditingController txtagencyname = TextEditingController();
  TextEditingController txtContactNo = TextEditingController();
  TextEditingController txtvoterId = TextEditingController();
  TextEditingController txtwingflatcount = TextEditingController();
  TextEditingController vehiclenotext = TextEditingController();
  TextEditingController adharnumbertxt = TextEditingController();
  TextEditingController worktext = TextEditingController();
  TextEditingController purposetext = TextEditingController();
  TextEditingController txtemergencyNo = TextEditingController();

  List wingclasslist = [];
  String SelectType;
  String SocietyId;
  String selectedWingId;
  String selectedWing;
  List selectFlat = [];
  bool _WingLoading = false;
  List FlatData = [];
  List _selectedFlatlist = [];
  List _selectedFlatlistIds = [];
  StaffType staffType;
  bool _StaffLoading = false;
  List stafftypelist = [];
  String selectedStaff;

  List finalSelectList = [];
  List allFlatList = [];
  List allWingList = [];
  int counter = 1;

  @override
  void initState() {
    pr = new ProgressDialog(context, type: ProgressDialogType.Normal);
    pr.style(message: 'Please Wait');
    _StaffType();
    _getLocaldata();
    _WingListData();
  }

  _getLocaldata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    SocietyId = prefs.getString(constant.Session.SocietyId);
  }

  DateTime SelectedDOB = DateTime.now();
  DateTime SelectedDOJ = DateTime.now();

  Future<Null> _selectDOB(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: SelectedDOB,
        firstDate: DateTime(1900, 1),
        lastDate: DateTime(2050));
    if (picked != null && picked != SelectedDOB)
      setState(() {
        SelectedDOB = picked;
      });
  }

  Future<Null> _selectedDOJ(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: SelectedDOJ,
        firstDate: DateTime(1900, 1),
        lastDate: DateTime(2050));
    if (picked != null && picked != SelectedDOJ)
      setState(() {
        SelectedDOJ = picked;
      });
  }

  List wingListCopy = [];
  _WingListData() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          "societyId" : SocietyId
        };
        Services.responseHandler(apiName: "admin/getAllWingOfSociety",body: data).then((data) async {
          if (data.Data != null && data.Data.length > 0) {
            setState(() {
              wingListCopy = data.Data;
              _WingLoading = false;
              wingclasslist  = data.Data;
              // for(int i=0;i<data.Data.length;i++){
              //   wingclasslist.add(data.Data[i]["wingName"]);
              // }
            });
          } else {
            setState(() {
              _WingLoading = false;
            });
          }
        }, onError: (e) {
          setState(() {
            _WingLoading = false;
          });
          Fluttertoast.showToast(
              msg: "Something Went Wrong", toastLength: Toast.LENGTH_LONG);
        });
      }
    } on SocketException catch (_) {
      setState(() {
        _WingLoading = false;
      });
      Fluttertoast.showToast(
          msg: "No Internet Access", toastLength: Toast.LENGTH_LONG);
    }
  }

  _StaffType() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var body = {};
        setState(() {
          _StaffLoading = true;
        });
        Services.responseHandler(apiName: "admin/getAllStaffCategory",body: body).then((data) async {
          if (data.Data != null && data.Data.length > 0) {
            setState(() {
              _StaffLoading = false;
              stafftypelist = data.Data;
            });
            for(int i=0;i<stafftypelist.length;i++){
              if(stafftypelist[i]["staffCategoryName"] == "Watchmen"){
                stafftypelist.remove(stafftypelist[i]);
                break;
              }
            }
          } else {
            setState(() {
              _StaffLoading = false;
            });
          }
        }, onError: (e) {
          setState(() {
            _StaffLoading = false;
          });
          Fluttertoast.showToast(
              msg: "Something Went Wrong", toastLength: Toast.LENGTH_LONG);
        });
      }
    } on SocketException catch (_) {
      setState(() {
        _WingLoading = false;
      });
      Fluttertoast.showToast(
          msg: "No Internet Access", toastLength: Toast.LENGTH_LONG);
    }
  }

  showMsg(String msg, {String title = 'MYJINI'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
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

  GetFlatData(String WingId) async {
    try {
      //check Internet Connection
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          // pr.show();
        });

        var data = {
          "societyId" : SocietyId,
          "wingId" : WingId
        };
        Services.responseHandler(apiName: "admin/getFlatsOfSociety_v1",body: data).then((data) async {
          setState(() {
            isLoading = false;
          });
          // pr.hide();
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
              // _flatSelectionBottomsheet(context, index);
              print("flatData");
              print(FlatData);
            });
            print("----->" + data.toString());
          } else {
            setState(() {
              // pr.hide();
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

  sendwingIdFlatId(String id,String wingId,String flatId) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          "staffId": id,
          "workLocation": [
            {
              "wingId": wingId,
              "flatId": flatId
            },
          ]
        };
        Services.responseHandler(apiName: "member/addStaffWorkLocation",body: data)
            .then((data) async {
          if (data.Data == "1") {
            Fluttertoast.showToast(
                msg: "${selectedStaff.toString()} Added Successfully",
                backgroundColor: Colors.green,
                gravity: ToastGravity.TOP,
                textColor: Colors.white);
          } else {
            // showMsg("Complaint Is Not Added To Solved");
          }
        }, onError: (e) {
          showMsg("Something Went Wrong Please Try Again");
        });
      }
    } on SocketException catch (_) {
      showMsg("Something Went Wrong");
    }
  }

  List finalWingFlatIds = [{
    "wingId" : "",
    "flatId" : ""
  }];
  List flatIds = [];
  _SaveStaff() async {
    print("checking");
    print(Gender);
    print(selectedWing);
    print(selectFlat.length);
    String filename = "";
    String filePath = "";
    File compressedFile;
      ImageProperties properties =
      await FlutterNativeImage.getImageProperties(_image.path);

      compressedFile = await FlutterNativeImage.compressImage(
        _image.path,
        quality: 80,
        targetWidth: 600,
        targetHeight:
        (properties.height * 600 / properties.width).round(),
      );

      filename = _image.path.split('/').last;
      filePath = compressedFile.path;

    if (txtName.text == ""
    || txtContactNo.text=="" || Gender==null  || selectedWing==null ||
          selectFlat.length == 0
    ) {
      Fluttertoast.showToast(
          msg: "Please Fill All Fields",
          backgroundColor: Colors.red,
          gravity: ToastGravity.TOP,
          textColor: Colors.white);
    }else{
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          String SocietyId = preferences.getString(Session.SocietyId);
          finalWingFlatIds[0]["wingId"] = selectedWingId;
          for(int i=0;i<FlatData.length;i++){
            for(int j=0;j<selectFlat.length;j++){
            if(selectFlat[j].toString() == FlatData[i]["value"].toString()) {
              flatIds.add(FlatData[i]["Ids"]);
            }
            }
          }
          FormData formData = new FormData.fromMap({
            "Name": txtName.text,
            "ContactNo1": txtContactNo.text,
            "Gender": Gender.toLowerCase(),
            "societyId": SocietyId,
            // "wingId" : selectedWingId,
            // "flatId" : finalWingFlatIds[0]["flatId"],
            // "identityProof" : null,
            "staffImage" : (filePath != null && filePath != '')
                ? await MultipartFile.fromFile(filePath,
                filename: filename.toString())
                : "",
            "AadharcardNo": adharnumbertxt.text,
            "VoterId": txtvoterId.text,
            "DateOfBirth": SelectedDOB.toString(),
            "DateOfJoin": SelectedDOJ.toString(),
            "RecruitType": SelectType,
            "AgencyName": txtagencyname.text,
            "EmergencyContactNo": txtemergencyNo.text,
            "VehicleNo": vehiclenotext.text,
            "Work": worktext.text,
            "staffCategory" : selectedStaff,
            "Address": txtaddress.text,
            // "workLocation" :finalWingFlatIds
          });

          print({
            "Name": txtName.text,
            "ContactNo1": txtContactNo.text,
            "Gender": Gender.toLowerCase(),
            "societyId": SocietyId,
            // "wingId" : selectedWingId,
            // "flatId" : finalWingFlatIds[0]["flatId"],
            // "identityProof" : null,
            "staffImage" : (filePath != null && filePath != '')
                ? await MultipartFile.fromFile(filePath,
                filename: filename.toString())
                : "",
            "AadharcardNo": adharnumbertxt.text,
            "VoterId": txtvoterId.text,
            // "isForSociety" : true,
            "DateOfBirth": SelectedDOB.toString(),
            "DateOfJoin": SelectedDOJ.toString(),
            "RecruitType": SelectType,
            "AgencyName": txtagencyname.text,
            "EmergencyContactNo": txtemergencyNo.text,
            "VehicleNo": vehiclenotext.text,
            "Work": worktext.text,
            "staffCategory" : selectedStaff,
            "Address": txtaddress.text,
            // "workLocation" :finalWingFlatIds
          });

          // pr.show();
          Services.responseHandler(apiName: "member/addStaff",body: formData).then((data) async {
            // pr.hide();
            if (data.Data != "0" && data.IsSuccess == true) {
              for(int i=0;i<flatIds.length;i++){
                sendwingIdFlatId(data.Data[0]["_id"],finalWingFlatIds[0]["wingId"],flatIds[i]);
              }
              Fluttertoast.showToast(
                  msg: "Staff Added Successfully!!!",
                  backgroundColor: Colors.green,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.white);
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/WatchmanDashboard', (Route<dynamic> route) => false);
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
    }
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  bool isFlatSelected = false;
  _flatSelectionBottomsheet(BuildContext context,int index) {
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
                                isFlatSelected = true;
                                // _flatSelectionBottomsheet(context, index);
                                // selectFlat.insert(index, FlatData[i]["display"]);
                                _FlateNo = FlatData[i]["display"];
                              });
                              // Navigator.pop(context);
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
                                  ),
                                  isFlatSelected ? Icon(
                                    Icons.check_circle,
                                    color: Colors.green[700],
                                  ):Container()
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

  List finalWingsAndFlats = [];
  var txtFlatList;
  List<dynamic> txtWingList = [];

  selectWingAndFlats(int index){
    return Column(
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
                        hint: wingclasslist != null &&
                            wingclasslist != "" &&
                            wingclasslist.length > 0
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
                          for(int i=0;i<wingclasslist.length;i++){
                            if(val == wingListCopy[i]["wingName"]){
                              selectedWingId = wingListCopy[i]["_id"];
                              break;
                            }
                          }
                          GetFlatData(selectedWingId);
                        },
                        items: wingclasslist.map((dynamic val) {
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

        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: <Widget>[
        //     Padding(
        //       padding: const EdgeInsets.only(left: 8.0, top: 10.0),
        //       child: Text(
        //         "Select Flat",
        //         style: TextStyle(
        //             fontSize: 12, fontWeight: FontWeight.bold),
        //       ),
        //     ),
        //     Container(
        //       decoration: BoxDecoration(
        //           borderRadius: BorderRadius.all(Radius.circular(8.0)),
        //           border: Border.all(color: Colors.black)),
        //       width: 120,
        //       height: 50,
        //       child: Center(
        //           child: Row(
        //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //             children: <Widget>[
        //               Padding(
        //                 padding: const EdgeInsets.only(left: 8.0),
        //                 child: Text(
        //                   _FlateNo == "" || _FlateNo== null
        //                       ? 'Flat No'
        //                       : _FlateNo,
        //                   style: TextStyle(
        //                       fontWeight: FontWeight.w600, fontSize: 14),
        //                 ),
        //               ),
        //               Icon(
        //                 Icons.chevron_right,
        //                 size: 18,
        //               )
        //             ],
        //           )),
        //     )
        //   ],
        // )
      ],
    );

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Add Staff",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: isLoading
            ? Container(
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            getImage();
                          },
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                _image == null
                                    ? Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                            image: new DecorationImage(
                                                image: AssetImage(
                                                    'images/user.png'),
                                                fit: BoxFit.cover),
                                            borderRadius: BorderRadius.all(
                                                new Radius.circular(75.0)),
                                            border: Border.all(
                                                width: 2.5,
                                                color: Colors.white)),
                                      )
                                    : Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                            image: new DecorationImage(
                                                image: FileImage(_image),
                                                fit: BoxFit.cover),
                                            borderRadius: BorderRadius.all(
                                                new Radius.circular(75.0)),
                                            border: Border.all(
                                                width: 2.5,
                                                color: Colors.white)),
                                      ),
                              ],
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 4.0, top: 10.0),
                              child: Text(
                                "Select StaffType",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
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
                                    hint: stafftypelist.length > 0
                                        ? Text("Select Staff Type",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600))
                                        : Text(
                                            "staff Type Not Found",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                    value: selectedStaff,
                                    onChanged: (val) {
                                      print(val);
                                      setState(() {
                                        selectedStaff = val;
                                      });
                                    },
                                    items: stafftypelist
                                        .map((dynamic val) {
                                      return new DropdownMenuItem<dynamic>(
                                        value: val["staffCategoryName"],
                                        child: Text(
                                          val["staffCategoryName"],
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
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              controller: txtName,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(5.0),
                                    borderSide: new BorderSide(),
                                  ),
                                  labelText: "Staff Name",
                                  labelStyle: TextStyle(fontSize: 13), floatingLabelBehavior: FloatingLabelBehavior.auto,),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              controller: txtContactNo,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(5.0),
                                    borderSide: new BorderSide(),
                                  ),
                                  counterText: "",
                                  labelText: "Contact Number",
                                  labelStyle: TextStyle(fontSize: 13), floatingLabelBehavior: FloatingLabelBehavior.auto,),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              controller: txtemergencyNo,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(5.0),
                                    borderSide: new BorderSide(),
                                  ),
                                  counterText: "",
                                  labelText: "Emergency Contact Number",
                                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                                  labelStyle: TextStyle(fontSize: 13)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              inputFormatters: [
                                MaskedTextInputFormatter(
                                  mask: 'xx-xx-xx-xxxx',
                                  separator: '-',
                                ),
                              ],
                              controller: vehiclenotext,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(5.0),
                                    borderSide: new BorderSide(),
                                  ),
                                  counterText: "",
                                  labelText: "Enter Vehicle Number",
                                  hintText: "XX-00-XX-0000",
                                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                                  labelStyle: TextStyle(fontSize: 13)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              controller: worktext,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(5.0),
                                    borderSide: new BorderSide(),
                                  ),
                                  counterText: "",
                                  labelText: "Enter Work",
                                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                                  labelStyle: TextStyle(fontSize: 13)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              controller: txtaddress,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(5.0),
                                    borderSide: new BorderSide(),
                                  ),
                                  labelText: "Staff Address",
                                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                                  labelStyle: TextStyle(fontSize: 13)),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 4.0, top: 6.0),
                              child: Text(
                                "Gender",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Radio(
                                value: 'Male',
                                groupValue: Gender,
                                onChanged: (value) {
                                  setState(() {
                                    Gender = value;
                                    print(Gender);
                                  });
                                }),
                            Text("Male", style: TextStyle(fontSize: 13)),
                            Radio(
                                value: 'Female',
                                groupValue: Gender,
                                onChanged: (value) {
                                  setState(() {
                                    Gender = value;
                                    print(Gender);
                                  });
                                }),
                            Text("Female", style: TextStyle(fontSize: 13)),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Text(
                                      "Select DOB",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _selectDOB(context);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10.0, right: 4.0),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 45,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1,
                                                color: Colors.black54),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8.0))),
                                        child: Center(
                                          child: Text(
                                            '${SelectedDOB.toLocal()}'
                                                .split(' ')[0],
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 12.0, right: 2),
                                    child: Text(
                                      "Select Date Of Join",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _selectedDOJ(context);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 10.0,
                                      ),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 45,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1,
                                                color: Colors.black54),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8.0))),
                                        child: Center(
                                          child: Text(
                                            '${SelectedDOJ.toLocal()}'
                                                .split(' ')[0],
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 4.0, top: 6.0),
                              child: Text(
                                "RecruitType",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Radio(
                                value: 'Through Agency',
                                groupValue: SelectType,
                                onChanged: (value) {
                                  setState(() {
                                    SelectType = value;
                                    print(SelectType);
                                  });
                                }),
                            Text("Through Agency",
                                style: TextStyle(fontSize: 13)),
                            Radio(
                                value: 'Through Society',
                                groupValue: SelectType,
                                onChanged: (value) {
                                  setState(() {
                                    SelectType = value;
                                    print(SelectType);
                                  });
                                }),
                            Text("Through Society",
                                style: TextStyle(fontSize: 13)),
                          ],
                        ),
                        SelectType == 'Through Agency'
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    top: 4.0, left: 4.0, right: 4.0),
                                child: SizedBox(
                                  height: 50,
                                  child: TextFormField(
                                    controller: txtagencyname,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                        border: new OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(5.0),
                                          borderSide: new BorderSide(),
                                        ),
                                        labelText: "Agency Name",
                                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                                        labelStyle: TextStyle(fontSize: 13)),
                                  ),
                                ),
                              )
                            : Container(),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10.0, right: 4.0, left: 4.0),
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              inputFormatters: [
                                MaskedTextInputFormatter(
                                  mask: 'xxxx-xxxx-xxxx-xxxx',
                                  separator: '-',
                                ),
                              ],
                              controller: adharnumbertxt,
                              keyboardType: TextInputType.number,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(5.0),
                                    borderSide: new BorderSide(),
                                  ),
                                  counterText: "",
                                  labelText: "Enter Adhar No Number",
                                  hintText: "xxxx-xxxx-xxxx-xxxx",
                                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                                  labelStyle: TextStyle(fontSize: 13)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: SizedBox(
                            height: 50,
                            child: TextFormField(
                              controller: txtvoterId,
                              keyboardType: TextInputType.text,
                              maxLength: 10,
                              decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(5.0),
                                    borderSide: new BorderSide(),
                                  ),
                                  counterText: "",
                                  labelText: "Voter Id",
                                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                                  labelStyle: TextStyle(fontSize: 13)),
                            ),
                          ),
                        ),
                        Column(
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
                                            hint: wingclasslist != null &&
                                                wingclasslist != "" &&
                                                wingclasslist.length > 0
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
                                              for(int i=0;i<wingclasslist.length;i++){
                                                if(val == wingListCopy[i]["wingName"]){
                                                  selectedWingId = wingListCopy[i]["_id"];
                                                  break;
                                                }
                                              }
                                              GetFlatData(selectedWingId);
                                            },
                                            items: wingclasslist.map((dynamic val) {
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
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: MultiSelectFormField(
                                    autovalidate: false,
                                    title: Text('Select Flat'),
                                    validator: (value) {
                                      if (value == null || value.length == 0) {
                                        return 'Please select one or more options';
                                      }
                                    },
                                    dataSource: FlatData,
                                    textField: 'display',
                                    valueField: 'display',
                                    okButtonLabel: 'OK',
                                    cancelButtonLabel: 'CANCEL',
                                    hintWidget: selectFlat.length == 0 ? Text('No Flat Selected'):Text(selectFlat.toString()),
                                    change: () => selectFlat,
                                    onSaved: (value) {
                                      setState(() {
                                        selectFlat = value;
                                      });
                                      print("selectFlat");
                                      print(selectFlat);
                                    },
                                  ),
                                ),
                              ],
                            ),

                            // Column(
                            //   crossAxisAlignment: CrossAxisAlignment.start,
                            //   children: <Widget>[
                            //     Padding(
                            //       padding: const EdgeInsets.only(left: 8.0, top: 10.0),
                            //       child: Text(
                            //         "Select Flat",
                            //         style: TextStyle(
                            //             fontSize: 12, fontWeight: FontWeight.bold),
                            //       ),
                            //     ),
                            //     Container(
                            //       decoration: BoxDecoration(
                            //           borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            //           border: Border.all(color: Colors.black)),
                            //       width: 120,
                            //       height: 50,
                            //       child: Center(
                            //           child: Row(
                            //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //             children: <Widget>[
                            //               Padding(
                            //                 padding: const EdgeInsets.only(left: 8.0),
                            //                 child: Text(
                            //                   _FlateNo == "" || _FlateNo== null
                            //                       ? 'Flat No'
                            //                       : _FlateNo,
                            //                   style: TextStyle(
                            //                       fontWeight: FontWeight.w600, fontSize: 14),
                            //                 ),
                            //               ),
                            //               Icon(
                            //                 Icons.chevron_right,
                            //                 size: 18,
                            //               )
                            //             ],
                            //           )),
                            //     )
                            //   ],
                            // )
                          ],
                        ),
                        // ListView.builder(
                        //   shrinkWrap: true,
                        //   physics: NeverScrollableScrollPhysics(),
                        //   itemBuilder: (context, index) {
                        //     return ExpansionTile(
                        //       title: Text("Select Wing And Flat No"),
                        //       children: <Widget>[
                        //         selectWingAndFlats(index),
                        //       ],
                        //       backgroundColor: Colors.white,
                        //     );
                        //   },
                        //   itemCount: counter,
                        // ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     GestureDetector(
                        //       onTap: (){
                        //         setState(() {
                        //           counter++;
                        //         });
                        //       },
                        //         child: Icon(
                        //             Icons.add,
                        //         ),
                        //     ),
                        //     GestureDetector(
                        //       onTap: (){
                        //         print(selectFlat);
                        //         print(selectedWing);
                        //         setState(() {
                        //           counter++;
                        //           selectFlat.add("");
                        //           // selectedWing.add("");
                        //         });
                        //       },
                        //         child: Text(
                        //           "Add Wing",
                        //         ),
                        //     ),
                        //   ],
                        // ),
                        /*Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, top: 10.0),
                              child: Text(
                                "Select Wing",
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    border: Border.all(width: 1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(6.0))),
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
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600))
                                        : Text(
                                            "Wing Not Found",
                                            style: TextStyle(fontSize: 14),
                                          ),
                                    value: selectedWing,
                                    onChanged: (val) {
                                      print(val);
                                      setState(() {
                                        selectedWing = val;
                                        _selectedFlatlist.clear();
                                        FlatData.clear();
                                      });
                                      for(int i=0;i<wingclasslist.length;i++){
                                        if(val == wingclasslist[i]["wingName"]){
                                          selectedWingId = wingclasslist[i]["_id"];
                                        }
                                      }
                                      GetFlatData(selectedWingId);
                                    },
                                    items: wingclasslist
                                        .map((dynamic wingclass) {
                                      return new DropdownMenuItem<dynamic>(
                                        value: wingclass["wingName"],
                                        child: Text(
                                          wingclass["wingName"],
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
                                    textField: "display",
                                    valueField: 'value',
                                    okButtonLabel: 'OK',
                                    cancelButtonLabel: 'CANCEL',
                                    hintText: 'Select Flat',
                                    value: _selectedFlatlist,
                                    onSaved: (value) {
                                      print("_selectedFlatlist");
                                      print(_selectedFlatlist);
                                      for(int i=0;i<FlatData.length;i++){

                                      }
                                      setState(() {
                                          _selectedFlatlist = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 60,
                              height: 60,
*//*
                              child: RaisedButton(
                                  child: Text(
                                    "+",
                                    style: TextStyle(
                                        fontSize: 24, color: Colors.white),
                                  ),
                                  onPressed: () {
                                    if (!allWingList.contains(selectedWing)) {
                                      for (int i = 0;
                                          i < _selectedFlatlist.length;
                                          i++) {
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
                                      int index =
                                          allWingList.indexOf(wingClass);
                                      print(index);
                                      setState(() {
                                        allWingList.removeAt(index);
                                        allFlatList.removeAt(index);
                                      });
                                      for (int i = 0;
                                          i < _selectedFlatlist.length;
                                          i++) {
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
*//*
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
                                          allWingList[index].WingName +
                                              '-' +
                                              allFlatList[index]
                                                  .toString()
                                                  .replaceAll("[", "")
                                                  .replaceAll("]", ""),
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Divider();
                              },
                            ),
                          ),
                        ),*/
                      ],
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          height: 45,
          child: MaterialButton(
            color: constant.appPrimaryMaterialColor[700],
            minWidth: MediaQuery.of(context).size.width - 20,
            onPressed: !ispressed ? () {
              if(_image == null){
                Fluttertoast.showToast(
                    msg: "Please select Image of Staff",
                    backgroundColor: Colors.red,
                    gravity: ToastGravity.TOP,
                    textColor: Colors.white);
              }
              else{
                setState(() {
                  ispressed = true;
                });
                _SaveStaff();
              }
            } : null,
            child: Text(
              "Add Staff",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
