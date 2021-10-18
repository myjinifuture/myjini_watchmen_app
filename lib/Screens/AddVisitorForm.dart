import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartsocietystaff/Common/ClassList.dart';
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as constant;
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Common/join.dart';
import 'package:smartsocietystaff/Component/masktext.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:textfield_search/textfield_search.dart';

class FlatNo {
  final String name;

  FlatNo({
    this.name,
  });
}

class AddVisitorForm extends StatefulWidget {
  String visitortype;
bool isConfirmed;
int stepFromVideoPage;
  AddVisitorForm({this.visitortype,this.isConfirmed,this.stepFromVideoPage});

  @override
  _AddVisitorFormState createState() => _AddVisitorFormState();
}

class _AddVisitorFormState extends State<AddVisitorForm> {
  int step = 1;
  bool othersSelected = false;
  File _image;
  SpeechRecognition _speechRecognitionName = new SpeechRecognition();
  SpeechRecognition _speechRecognitionPurpose = new SpeechRecognition();
  TextEditingController resultText = new TextEditingController();
  TextEditingController mobilenotext = new TextEditingController();
  TextEditingController vehiclenotext = new TextEditingController();
  TextEditingController purposeText = new TextEditingController();
  TextEditingController temperatureText = new TextEditingController();
  PermissionStatus _permissionStatus = PermissionStatus.unknown;

  int selected_Index;

  String _selectedCompanyName;
  String _selectedCompanyLogo;

  String vehicleNumber = "";

  String _selectedVisitorType;
  String _selectedVisitorIcon;
  String _selectedvisitorId;
  String _FlateNo;

  bool isLoading = false;
  List WingData = new List();
  String SocietyId, WatchManId;
  bool _WingLoading = false;
  List VisitorTypeData = [];
  List FlatData = [];
  List CompanyData = new List();
  List purposeData = [];
  ProgressDialog pr;

  // List<WingClass> _winglist = [];
  List wingList = [];
  String selectedWing,selectedWingId;
  // WingClass _wingClass;
  String purposeSelected ;
  bool mask = false;
  bool sanitized = false;
  FocusNode focusNode;

  @override
  void initState() {
    print("widget.isConfirmed");
    print(widget.isConfirmed);
    // getFlatIds();
    getFlatIds_v2();
    if(widget.isConfirmed==true){
      setState(() {
        step=widget.stepFromVideoPage;
        getImage();
      });
    }
    // TODO: implement initState
    super.initState();
    print(step.toString());
    initSpeechRecognizer();
    print("widget.visitortype");
    print(widget.visitortype);
    // initSpeechRecognizer2();
    focusNode = new FocusNode();

    // listen to focus changes
    focusNode.addListener(() => print('focusNode updated: hasFocus: ${focusNode.hasFocus}'));

    GetPurpose();
    _getLocaldata();
    GetVisitorType();

    pr = new ProgressDialog(context, type: ProgressDialogType.Normal);
    pr.style(
        message: "Please Wait..",
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

  List mobileNo = [];
  getAllVisitorsMobileNo(String id) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {"societyId": id};

        setState(() {
          isLoading = true;
        });
        Services.responseHandler(
            apiName: "watchman/getAllVisitorEntry_v1", body: data)
            .then((data) async {
          mobileNo.clear();
          if (data.Data != null && data.Data.length > 0) {
            setState(() {
              for(int i=0;i<data.Data.length;i++){
                mobileNo.add(data.Data[i]["ContactNo"]);
              }
              isLoading = false;
            });
          } else {
            setState(() {
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

  _getLocaldata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    SocietyId = prefs.getString(constant.Session.SocietyId);
    WatchManId = prefs.getString(constant.Session.MemberId);
    getWingsId(SocietyId);
    getAllVisitorsMobileNo(SocietyId);
  }

  void setFocus() {
    FocusScope.of(context).requestFocus(focusNode);
  }

  Widget numberKeyboard() {
    return TextFormField(
      inputFormatters: [
        MaskedTextInputFormatter(
          mask: 'xx-xx-xx-xxxx',
          separator: '-',
        ),
      ],
      onChanged: (value) {
        print(value.length);
        setState(() {
          vehicleNumber = value;
        });
      },
      initialValue: vehicleNumber,
      keyboardType: TextInputType.number,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(5.0),
            borderSide: new BorderSide(),
          ),
          counterText: "",
          labelText: "Enter Vehicle Number",
          hintText: "XX-00-XX-0000",
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: TextStyle(fontSize: 13)),
    );
  }

  Widget textKeyboard() {
    return TextFormField(
      inputFormatters: [
        MaskedTextInputFormatter(
          mask: 'xx-xx-xx-xxxx',
          separator: '-',
        ),
      ],
      onChanged: (value) {
        print(value.length);
        setState(() {
          vehicleNumber = value;
        });
      },
      initialValue: vehicleNumber,
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
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: TextStyle(fontSize: 13)),
    );
  }

  List wingsNameData = [];

  getWingsId(String societyId) async {
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
              wingList = data.Data;
            });
            for(int i=0;i<wingsList.length;i++){
              wingsNameData.add({
                "Name" : wingsList[i]["wingName"],
                "Id" : wingsList[i]["_id"],
              });
            }
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

  String purposeSelectedId;
  String selectedFlatId,selectedMemberId;
  String allWingFlats;
  bool successfullyCalled = false;

  SaveVisitorData(bool otherAmenitiesSelected) async {
    try {
      print("flatIdsForBackend");
      print(flatIdsForBackend);
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if(otherAmenitiesSelected){
          print("divyan Sondagar");
          if (resultText.text != "" && mobilenotext.text.length  == 10) {
            pr.show();
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String SocietyId = prefs.getString(constant.Session.SocietyId);
            String filename = "";
            String filePath = "";
            File compressedFile;
            if (_image != null) {
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
            }

            String code = "";

            var rnd = new Random();
            setState(() {
              code = "";
            });
            for (var i = 0; i < 4; i++) {
              code = code + rnd.nextInt(9).toString();
            }
            print("flatdata");
            print(FlatData);
            print(_FlateNo);

            for(int i=0;i<purposeData.length;i++){
              print("1");
              if(purposeSelected==purposeData[i]["purposeName"]){
                purposeSelectedId = purposeData[i]["_id"];
              }
            }
            for(int i=0;i<FlatData.length;i++){
              print("2");
              if(_FlateNo.toString()==FlatData[i]["flatNo"].toString()){
                print("3");
                selectedFlatId = FlatData[i]["_id"].toString();
                print(selectedFlatId);
                selectedMemberId = FlatData[i]["parentMember"].toString();
                print(selectedMemberId);
              }
            }
            for(int i=0;i<wingList.length;i++){
              if(selectedWing.toString()==wingList[i]["wingName"].toString()){
                print("4");
                selectedWingId = wingList[i]["_id"].toString();
                print(selectedWingId);
              }
            }
            FormData formData;
            // if(selectedWingId!=null) {
              print("selectedFlatId");
              print(selectedFlatId);
                formData = new FormData.fromMap({
                  "Name": resultText.text,
                  "societyId": SocietyId,
                  "ContactNo": mobilenotext.text,
                  // "memberId": selectedMemberId == null
                  //     ? null
                  //     : selectedMemberId,
                  "CompanyName": _selectedCompanyName == null
                      ? ""
                      : _selectedCompanyName,
                  "guestType": _selectedvisitorId.toString(),
                  // doubt will ask to monil
                  "purposeId": purposeSelectedId,
                  "vehicleNo": vehicleNumber,
                  // "wingId": selectedWingId,
                  // "flatId": selectedFlatId,
                  "guestImage": (filePath != null && filePath != '')
                      ? await MultipartFile.fromFile(filePath,
                      filename: filename.toString())
                      : "",
                  "companyImage": _selectedCompanyLogo == null
                      ? ""
                      : _selectedCompanyLogo,
                  "watchmanId": WatchManId,
                  "isMask": mask == true ? "1" : "0",
                  "isSanitize": sanitized == true ? "1" : "0",
                  "Temperature": temperatureText.text.toString(),
                  "deviceType": Platform.isAndroid ? "Android" : "IOS",
                  "isVerified": widget.isConfirmed == null ? true : widget
                      .isConfirmed,
                });
              setState(() {
                successfullyCalled = true;
              });
              Services.responseHandler(
                  apiName: "Watchman/addOtherVisitor_v1", body: formData).then((
                  data) async {
                pr.hide();
                if (data.Data.length > 0 && data.IsSuccess == true) {
                  print("smit watchman1 ${data.Data}");
                  SharedPreferences preferences =
                  await SharedPreferences.getInstance();
                  print("data.message");
                  print(data.Message);
                  // await preferences.setString('data', data.Data[0]["entryNo"]);
                  showMsg(data.Message, title: "Success",
                      entryno: ""
                  );
                } else {
                  showMsg(data.Message, title: "Error");
                }
              }, onError: (e) {
                // pr.hide();
                showMsg("Try Again.");
              });
          } else
            Fluttertoast.showToast(
                msg: "name or contact number can't be empty",
                toastLength: Toast.LENGTH_SHORT,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                gravity: ToastGravity.TOP);
        }
        else if (flatIdsForBackend.length > 0 ) {
          print("Nitin Sondagar");
          if (resultText.text != "" && mobilenotext.text != "" && purposeSelected != null) {
            // pr.show();
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String SocietyId = prefs.getString(constant.Session.SocietyId);
            String filename = "";
            String filePath = "";
            File compressedFile;
            if (_image != null) {
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
            }

            String code = "";

            var rnd = new Random();
            setState(() {
              code = "";
            });
            for (var i = 0; i < 4; i++) {
              code = code + rnd.nextInt(9).toString();
            }
            print("flatdata");
            print(FlatData);
            print(_FlateNo);

            for(int i=0;i<purposeData.length;i++){
              print("1");
              if(purposeSelected==purposeData[i]["purposeName"]){
                purposeSelectedId = purposeData[i]["_id"];
              }
            }
            for(int i=0;i<FlatData.length;i++){
              print("2");
              if(_FlateNo.toString()==FlatData[i]["flatNo"].toString()){
                print("3");
                selectedFlatId = FlatData[i]["_id"].toString();
                print(selectedFlatId);
                selectedMemberId = FlatData[i]["parentMember"].toString();
                print(selectedMemberId);
              }
            }
            // for(int i=0;i<wingList.length;i++){
            //   if(selectedWing.toString()==wingList[i]["wingName"].toString()){
            //     print("4");
            //     print("4");
            //     selectedWingId = wingList[i]["_id"].toString();
            //     print(selectedWingId);
            //   }
            // }
            FormData formData;
                formData = new FormData.fromMap({
                  "Name": resultText.text,
                  "societyId": SocietyId,
                  "ContactNo": mobilenotext.text,
                  // "memberId": selectedMemberId == null
                  //     ? null
                  //     : selectedMemberId,
                  "CompanyName": _selectedCompanyName == null
                      ? ""
                      : _selectedCompanyName,
                  "guestType": _selectedvisitorId.toString(),
                  // doubt will ask to monil
                  "purposeId": purposeSelectedId,
                  "vehicleNo": vehicleNumber,
                  "allWingFlats" : flatIdsForBackend.toString().replaceAll("[","").replaceAll("]","").replaceAll(" ", ""),
                  // "wingId": selectedWingId,
                  // "flatId": selectedFlatId,
                  "guestImage": (filePath != null && filePath != '')
                      ? await MultipartFile.fromFile(filePath,
                      filename: filename.toString())
                      : null,
                  "companyImage": _selectedCompanyLogo == null
                      ? null
                      : _selectedCompanyLogo,
                  "watchmanId": WatchManId,
                  "isMask": mask == true ? "1" : "0",
                  "isSanitize": sanitized == true ? "1" : "0",
                  "Temperature": temperatureText.text.toString(),
                  "deviceType": Platform.isAndroid ? "Android" : "IOS",
                  "isVerified": widget.isConfirmed == null ? false : widget
                      .isConfirmed,
                });
                print({
                  "Name": resultText.text,
                  "societyId": SocietyId,
                  "ContactNo": mobilenotext.text,
                  // "memberId": selectedMemberId == null
                  //     ? null
                  //     : selectedMemberId,
                  "CompanyName": _selectedCompanyName == null
                      ? ""
                      : _selectedCompanyName,
                  "guestType": _selectedvisitorId.toString(),
                  // doubt will ask to monil
                  "purposeId": purposeSelectedId,
                  "vehicleNo": vehicleNumber,
                  "allWingFlats" : flatIdsForBackend.toString().replaceAll("[","").replaceAll("]","").replaceAll(" ", ""),
                  // "wingId": selectedWingId,
                  // "flatId": selectedFlatId,
                  "guestImage": (filePath != null && filePath != '')
                      ? await MultipartFile.fromFile(filePath,
                      filename: filename.toString())
                      : "",
                  "companyImage": _selectedCompanyLogo == null
                      ? ""
                      : _selectedCompanyLogo,
                  "watchmanId": WatchManId,
                  "isMask": mask == true ? "1" : "0",
                  "isSanitize": sanitized == true ? "1" : "0",
                  "Temperature": temperatureText.text.toString(),
                  "deviceType": Platform.isAndroid ? "Android" : "IOS",
                  "isVerified": widget.isConfirmed == null ? false : widget
                      .isConfirmed,
                });
              Services.responseHandler(
                  apiName: "watchman/addVisitorEntry_v4", body: formData).then((
                  data) async {
                // pr.hide();
                if (data.Data != "0" && data.IsSuccess == true) {
                  print("data.message");
                  print(data.Message);
                  // await preferences.setString('data', data.Data[0]["entryNo"]);
                  showMsg(data.Message, title: "Success",
                      );
                } else {
                  showMsg(data.Message, title: "Error");
                }
              }, onError: (e) {
                // pr.hide();
                showMsg("Try Again.");
                print(e);
              });
          } else
            Fluttertoast.showToast(
                msg: "name,contact number or purpose can't be empty",
                toastLength: Toast.LENGTH_SHORT,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                gravity: ToastGravity.TOP);
        } else
          Fluttertoast.showToast(
              msg: "Please Select Wing and Flat",
              gravity: ToastGravity.TOP,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              toastLength: Toast.LENGTH_LONG);
      } else
        showMsg("No Internet Connection.");
    } on SocketException catch (_) {
      // pr.hide();
      showMsg("No Internet Connection.");
    }
  }

  showMsg(String msg, {String title = 'MYJINI',String entryno}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Image.asset(
            'images/success.png',
            width: 60,
            height: 60,
          ),
          content: new Text(msg),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Okay",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onPressed: () {
                 Navigator.pushReplacementNamed(context, '/WatchmanDashboard');
              /*  if(widget.isConfirmed == null){
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
                else {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              */  // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => JoinPage(entryIdWhileGuestEntry:entryno ,),
                //   ),
                // );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> requestPermission(PermissionGroup permission) async {
    final List<PermissionGroup> permissions = <PermissionGroup>[
      PermissionGroup.microphone
    ];
    final Map<PermissionGroup, PermissionStatus> permissionRequestResult =
        await PermissionHandler().requestPermissions(permissions);

    setState(() {
      print(permissionRequestResult);
      _permissionStatus = permissionRequestResult[permission];
      print(_permissionStatus);
    });
    if (permissionRequestResult[permission] == PermissionStatus.granted) {
    } else
      Fluttertoast.showToast(
          msg: "Permission Not Granted",
          gravity: ToastGravity.TOP,
          toastLength: Toast.LENGTH_SHORT);
  }

  initSpeechRecognizer() {
    _speechRecognitionName.setRecognitionResultHandler(
      (String speech) => setState(() => resultText.text = speech),
    );
  }

  // initSpeechRecognizer2() {
  //   _speechRecognitionPurpose.setRecognitionResultHandler(
  //     (String speech) => setState(() => purposeText.text = speech),
  //   );
  // }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  get visitortype {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Text(
            "Visitor Type",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        InkWell(
          onTap: () {
            _visitorTypeSelection(context);
          },
          child: Card(
            elevation: 2,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _selectedVisitorIcon != ""
                          ? Image.network('$_selectedVisitorIcon')
                          : Image.asset(
                              'images/noimg.png',
                              width: 50,
                              height: 50,
                            )),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _selectedVisitorType == null
                            ? 'Select Visitor Type'
                            : '$_selectedVisitorType',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right)
                ],
              ),
            ),
          ),
        ),
       //  Padding(
       //          padding: const EdgeInsets.all(6.0),
       //          child: Text(
       //            "Company Name",
       //            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
       //          ),
       //        ),
       // InkWell(
       //          onTap: () {
       //            // if (_selectedVisitorType == "Guest") {
       //            //   _companySelectBottomSheet(context);
       //            // } else if(_selectedVisitorType == "Cab Driver") {
       //            //   GetCompanyName(0);
       //            // }
       //            // else{
       //            //   GetCompanyName(1);
       //            // }
       //          },
       //          child: Card(
       //            elevation: 2,
       //            child: Container(
       //              width: MediaQuery.of(context).size.width,
       //              height: 60,
       //              child: Row(
       //                mainAxisAlignment: MainAxisAlignment.spaceBetween,
       //                crossAxisAlignment: CrossAxisAlignment.center,
       //                children: <Widget>[
       //                  Padding(
       //                      padding: const EdgeInsets.all(8.0),
       //                      child: Image.network(
       //                          '$IMG_URL' + '$_selectedCompanyLogo')),
       //                  // Expanded(
       //                  //   child: Padding(
       //                  //     padding: const EdgeInsets.all(8.0),
       //                  //     child: Text(
       //                  //       _selectedCompanyName == null
       //                  //           ? 'Select Company Name'
       //                  //           : '$_selectedCompanyName',
       //                  //       style: TextStyle(fontWeight: FontWeight.bold),
       //                  //     ),
       //                  //   ),
       //                  // ),
       //                  Icon(Icons.chevron_right)
       //                ],
       //              ),
       //            ),
       //          ),
       //        ),
        // Padding(
        //   padding: const EdgeInsets.all(6.0),
        //   child: Text(
        //     "Photo & Name",
        //     style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        //   ),
        // ),
        InkWell(
          onTap: () {
            // _selectedVisitorIcon == null ||
            //         _selectedVisitorIcon == "" &&
                        _selectedVisitorType == null ||
                    _selectedVisitorType == ""
                ? Fluttertoast.showToast(
                    msg: "Please Select Visitor Type",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.TOP,
                    timeInSecForIos: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0)
                : _selectedVisitorType!="Guest" &&
                            _selectedCompanyName == null ||
                            _selectedCompanyName=="" ? Fluttertoast.showToast(
                            msg: "Please Select Company Type",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP,
                            timeInSecForIos: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0) : setState(() {
                    step = 2;
                  });
          },
          child: Card(
            elevation: 2,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.person_add)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Visitor Photo & Name",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool _isListening = false;

  int counter = 1;
  List wingsList = [];
  List flatsList = [];
  List flatsToMakeSort = [];
  String societyId,wingId;
  List flats=[];
  List flatNumbersAndIds = [],flatIdsForBackend = [];
  static List<FlatNo> flatNumbers = [];

  getFlatIds_v2({bool allFlat}) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        societyId=prefs.getString(Session.SocietyId);
        // wingId=prefs.getString(cnst.Session.WingId);
        print("Divyan Sondagar460505");
        print("Divyan Sondagar460505");
        List wings=[];
        wings=prefs.getString(Session.WingId).split(",");
        print(wings.length);
        if(prefs.getString(Session.WingId).length > 0){
          wingId = prefs.getString(Session.WingId).replaceAll("[", "")
              .replaceAll("]", "").replaceAll(" ", "");
        }
        else{
          wingId = prefs.getString(Session.WingId);
          print(prefs.getString(Session.WingId).length);
        }
        var data = {
          "societyId" : societyId,
          "wingId" : wingId
        };
        print("data");
        print(data);
        Services.responseHandler(apiName: "member/getOccupiedFlats_v2",body: data).then((data) async {
          if (data.Data !=null) {
            flats.clear();
            flatsToMakeSort.clear();
            flatNumbersAndIds.clear();
            for(int i=0;i<data.Data.length;i++){
              if(data.Data[i]["WingData"].length!=0) {
                  flatsToMakeSort.add("${data
                      .Data[i]["WingData"][0]["wingName"]}-${data
                      .Data[i]["flatNo"]}");
                  flatNumbersAndIds.add({
                    "flatNo": data.Data[i]["flatNo"],
                    "flatId": data.Data[i]["_id"],
                    "wingName": data.Data[i]["WingData"][0]["wingName"],
                    "wingId" : data.Data[i]["WingData"][0]["_id"]
                  });
              }
            }
            print("divyan sondagar");
            print(flatsToMakeSort.length);
            flatsToMakeSort.sort();
            print(flatsToMakeSort.length);
            print("flatNumbersAndIds");
            print(flatNumbersAndIds);
            setState(() {
              for(int i=0;i<flatsToMakeSort.length;i++){
                if(!flatNumbers.contains(FlatNo(name: flatsToMakeSort[i].toString()))) {
                  flats.add(flatsToMakeSort[i].toString());
                  flatNumbers.add(
                      FlatNo(name: flatsToMakeSort[i].toString()));
                }
              }
              print("flats after data");
              print(flatNumbers);
            });
            // if(allFlat){
            //   flatIdsForBackend.clear();
            //   for(int j=0;j<flatNumbersAndIds.length;j++){
            //     flatIdsForBackend.add(flatNumbersAndIds[j]["flatId"]);
            //   }
            //   getFlatMemberId(flatIdsForBackend);
            //   print("flatIdsForBackend");
            //   print(flatIdsForBackend);
            // }
          }
        }, onError: (e) {
          showMsg("$e");
        });
      } else {
        showMsg("No Internet Connection.");
      }
    } on SocketException catch (_) {
      showMsg("Something Went Wrong");
    }
  }

 /* getFlatIds() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        societyId=prefs.getString(Session.SocietyId);
        wingId=prefs.getString(Session.WingId);
        var data = {
          "societyId" : societyId,
          "wingId" : wingId
        };
        Services.responseHandler(apiName: "member/getOccupiedFlats",body: data).then((data) async {
          if (data.Data !=null) {
            flats.clear();
            flatsToMakeSort.clear();
            flatNumbersAndIds.clear();
            for(int i=0;i<data.Data.length;i++){
              flatsToMakeSort.add(data.Data[i]["flatNo"],);
              flatNumbersAndIds.add({
                "flatNo" : data.Data[i]["flatNo"],
                "flatId" : data.Data[i]["_id"],
              });
            }
            flatsToMakeSort.sort();
            print("flatsToMakeSort");
            print(flatsToMakeSort);
            setState(() {
              for(int i=0;i<flatsToMakeSort.length;i++){
                if(!flatNumbers.contains(FlatNo(name: flatsToMakeSort[i].toString()))) {
                  flats.add(flatsToMakeSort[i].toString());
                  flatNumbers.add(
                      FlatNo(name: flatsToMakeSort[i].toString()));
                }
              }
              print("flats after data");
              print(flatNumbers);
            });
          }
        }, onError: (e) {
          showMsg("$e");
        });
      } else {
        showMsg("No Internet Connection.");
      }
    } on SocketException catch (_) {
      showMsg("Something Went Wrong");
    }
  }*/

  List allFlatMembersId = [];

  getFlatMemberId(List Ids) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var body = {
          "flatIdList": Ids
        };
        Services.responseHandler(
            apiName: "member/getFlatMember",
            body: body).then((data) async {
          if (data.Data != null && data.Data.length > 0) {
            allFlatMembersId.clear();
            setState(() {
              for(int i=0;i<data.Data.length;i++){
                if(data.Data[i]["parentMember"].toString()!=null || data.Data[i]["parentMember"].toString() !="") {
                  allFlatMembersId.add(data.Data[i]["parentMember"]);
                }
                for(int j = 0;j<data.Data[i]["memberIds"].length;j++){
                  if(data.Data[i]["memberIds"].length > 0) {
                    allFlatMembersId.add(data.Data[i]["memberIds"][j]);
                  }
                }
              }
            });
          } else {}
        }, onError: (e) {
          showHHMsg("Try Again.", "");
        });
      }
    } on SocketException catch (_) {
      showHHMsg("No Internet Connection.", "");
    }
  }

  TextEditingController contactNumberController = TextEditingController();


  Widget photoname(bool otherSelected) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      setState(() {
                        step = 1;
                      });
                    })
              ],
            ),
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
                                    image: AssetImage('images/user.png'),
                                    fit: BoxFit.cover),
                                borderRadius:
                                    BorderRadius.all(new Radius.circular(75.0)),
                                border: Border.all(
                                    width: 2.5, color: Colors.white)),
                          )
                        : Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                                image: new DecorationImage(
                                    image: FileImage(_image),
                                    fit: BoxFit.cover),
                                borderRadius:
                                    BorderRadius.all(new Radius.circular(75.0)),
                                border: Border.all(
                                    width: 2.5, color: Colors.white)),
                          ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                height: 50,
                child: TextFormField(
                  controller: mobilenotext,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  onChanged: (val){
                    print("val");
                    print(val.length);
                    if(val.length == 10){
                          getNameOfVisitor(val.toString());
                    }
                    else{
                      setState(() {
                        resultText.text = "";
                      });
                    }
                  },
                  decoration: InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(5.0),
                        borderSide: new BorderSide(),
                      ),
                      counterText: "",
                      labelText: "Contact Number *",
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      labelStyle: TextStyle(fontSize: 13)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                height: 50,
                child: TextFormField(
                  focusNode: focusNode,
                  controller: resultText,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(5.0),
                        borderSide: new BorderSide(),
                      ),
                      counterText: "",
                      suffixIcon: IconButton(
                        icon: Icon(_isListening ? Icons.mic : Icons.mic_none,
                        ),
                        onPressed: () {
                          setState(() {
                            _isListening = true;
                          });
                          requestPermission(PermissionGroup.microphone);
                          _speechRecognitionName
                              .listen(locale: "en_US")
                              .then((result) {
                                print('####-$result');
                              });
                        },
                      ),
                      labelText: "Visitor Name *",
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      labelStyle: TextStyle(fontSize: 13)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                height: 50,
                child: vehicleNumber.length >= 3
                    ? numberKeyboard()
                    : textKeyboard(),
              ),
            ),
/*
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                height: 50,
                child: TextFormField(
                  controller: purposeText,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(5.0),
                        borderSide: new BorderSide(),
                      ),
                      // suffixIcon: IconButton(
                      //   icon: Icon(Icons.mic),
                      //   onPressed: () {
                      //     requestPermission(PermissionGroup.microphone);
                      //     _speechRecognitionPurpose
                      //         .listen(locale: "en_US")
                      //         .then((result) => print('$result'));
                      //   },
                      // ),
                      counterText: "",
                      labelText: "Purpose of Visitor",
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      labelStyle: TextStyle(fontSize: 13)),
                ),
              ),
            ),
*/
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                height: 50,
                child: TextFormField(
                  controller: temperatureText,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(5.0),
                        borderSide: new BorderSide(),
                      ),
                      counterText: "",
                      labelText: "Temperature",
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      labelStyle: TextStyle(fontSize: 13)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width*0.948,
                decoration: BoxDecoration(
                    border: Border.all(width: 1),
                    borderRadius:
                    BorderRadius.all(Radius.circular(6.0,
                    ),
                    ),
                ),


                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: DropdownButtonHideUnderline(
                      child: DropdownButton<dynamic>(
                        icon: Icon(
                          Icons.arrow_drop_down,
                          size: 20,
                        ),
                        hint: purposeData.length > 0
                            ? Text("Select Purpose Of Visitor",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600))
                            : Text(
                          "Purpose Not Found",
                          style: TextStyle(fontSize: 14),
                        ),
                        value: purposeSelected,
                        onChanged: (val) {
                          setState(() {
                            purposeSelected = val;
                          });
                        },
                        items: purposeData.map((dynamic value) {
                          return new DropdownMenuItem<dynamic>(
                            value: value["purposeName"],
                            child: Text(
                              value["purposeName"],
                              style: TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList(),
                      )),
                ),


              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 2,
                  color: Colors.deepPurple.withOpacity(0.85),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 5.0),
                    child: Row(
                      children: [
                        Text(
                          'Mask On',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Theme(
                          data: ThemeData(
                            unselectedWidgetColor: Colors.white,
                          ),
                          child: Checkbox(
                            value: mask,
                            checkColor: Colors.white,
                            onChanged: (bool value) {
                              setState(() {
                                mask = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 2,
                  color: Colors.deepPurple.withOpacity(0.85),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0, right: 5.0),
                    child: Row(
                      children: [
                        Text(
                          'Sanitized',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Theme(
                          data: ThemeData(
                            unselectedWidgetColor: Colors.white,
                          ),
                          child: Checkbox(
                            value: sanitized,
                            onChanged: (bool value) {
                              setState(() {
                                sanitized = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            otherSelected ? Container() :
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MultiSelectDialogField(
                items: flatsToMakeSort
                    .map((val) => MultiSelectItem<dynamic>(val, val))
                    .toList(),
                onSelectionChanged: (List a){
                  print("a");
                  print(a);
                },
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Flats"),
                    // FlatButton(
                    //   color: Colors.red,
                    //   child: Text('SELECT ALL',
                    //   style: TextStyle(
                    //     color: Colors.white,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    //   ),
                    //
                    //   onPressed: () {
                    //     // setState(() {
                    //     //   txt='FlatButton tapped';
                    //     // });
                    //   },
                    // ),
                  ],
                ),
                selectedColor: Colors.purple,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                  border: Border.all(
                    color: Colors.purple,
                    width: 2,
                  ),
                ),
                searchable: true,
                onConfirm: (List allFlats){
                  print("allFlats");
                  print(allFlats);
                  flatIdsForBackend.clear();
                  for(int i=0;i<allFlats.length;i++){
                    for(int j=0;j<flatNumbersAndIds.length;j++){
                      if((flatNumbersAndIds[j]["wingName"].toString() + "-" + flatNumbersAndIds[j]["flatNo"].toString())
                          == allFlats[i].toString()){
                        flatIdsForBackend.add(
                            flatNumbersAndIds[j]["wingId"] + "-" + flatNumbersAndIds[j]["flatId"]
                            );
                      }
                    }
                  }
                  // getFlatMemberId(flatIdsForBackend);
                  print("flatIdsForBackend");
                  print(flatIdsForBackend);
                },
              ),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: <Widget>[
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: <Widget>[
            //         Padding(
            //           padding: const EdgeInsets.only(left: 8.0, top: 10.0),
            //           child: Text(
            //             "Select Wing *",
            //             style: TextStyle(
            //                 fontSize: 12, fontWeight: FontWeight.bold),
            //           ),
            //         ),
            //         Padding(
            //           padding: const EdgeInsets.all(8.0),
            //           child: Container(
            //             width: MediaQuery.of(context).size.width / 2.3,
            //             decoration: BoxDecoration(
            //                 border: Border.all(width: 1),
            //                 borderRadius:
            //                 BorderRadius.all(Radius.circular(6.0))),
            //             child: Padding(
            //               padding: const EdgeInsets.only(left: 8.0),
            //               child: DropdownButtonHideUnderline(
            //                   child: DropdownButton<dynamic>(
            //                     icon: Icon(
            //                       Icons.chevron_right,
            //                       size: 20,
            //                     ),
            //                     hint: wingList != null &&
            //                         wingList != "" &&
            //                         wingList.length > 0
            //                         ? Text("Select Wing *",
            //                         style: TextStyle(
            //                             fontSize: 14,
            //                             fontWeight: FontWeight.w600))
            //                         : Text(
            //                       "Wing Not Found",
            //                       style: TextStyle(fontSize: 14),
            //                     ),
            //                     value: selectedWing,
            //                     onChanged: (val) {
            //                       selectedWing = val;
            //                       for(int i=0;i<wingList.length;i++){
            //                         if(val == wingList[i]["wingName"]){
            //                           selectedWingId = wingList[i]["_id"];
            //                           break;
            //                         }
            //                       }
            //                       getFlatIds(SocietyId,selectedWingId);
            //                     },
            //                     items: wingList.map((dynamic val) {
            //                       return new DropdownMenuItem<dynamic>(
            //                         value: val["wingName"],
            //                         child: Text(
            //                           val["wingName"],
            //                           style: TextStyle(color: Colors.black),
            //                         ),
            //                       );
            //                     }).toList(),
            //                   )),
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //     Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: <Widget>[
            //         Padding(
            //           padding: const EdgeInsets.only(left: 8.0, top: 10.0),
            //           child: Text(
            //             "Select Flat *",
            //             style: TextStyle(
            //                 fontSize: 12, fontWeight: FontWeight.bold),
            //           ),
            //         ),
            //         Container(
            //           decoration: BoxDecoration(
            //               borderRadius: BorderRadius.all(Radius.circular(8.0)),
            //               border: Border.all(color: Colors.black)),
            //           width: 120,
            //           height: 50,
            //           child: Center(
            //               child: Row(
            //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                 children: <Widget>[
            //                   Padding(
            //                     padding: const EdgeInsets.only(left: 8.0),
            //                     child: Text(
            //                       _FlateNo == "" || _FlateNo == null
            //                           ? 'Flat No'
            //                           : '$_FlateNo',
            //                       style: TextStyle(
            //                           fontWeight: FontWeight.w600, fontSize: 14),
            //                     ),
            //                   ),
            //                   Icon(
            //                     Icons.chevron_right,
            //                     size: 18,
            //                   )
            //                 ],
            //               )),
            //         )
            //       ],
            //     ),
            //   ],
            // ),
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
                            "Save Visitor",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 16),
                          ),
                        ],
                      ),
                      color: appPrimaryMaterialColor,
                      onPressed:() {
                        if(!successfullyCalled) {
                          if(_image != null) {
                            SaveVisitorData(otherSelected);
                          }
                          else{
                            Fluttertoast.showToast(
                                msg: "Please Select Image",
                                toastLength: Toast.LENGTH_SHORT,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                gravity: ToastGravity.TOP);
                          }
                        }
                      }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  setdata(data) {
    for (int i = 0; i < data.length; i++) {
      // if (data[i]["VisitorTypeName"] == 'Courier/ Delivery Boy') {
        setState(() {
          _selectedVisitorType = VisitorTypeData[i]["guestType"];
          _selectedVisitorIcon = IMG_URL + VisitorTypeData[i]["image"];
          _selectedvisitorId = VisitorTypeData[i]["_id"];
        });
        print("_selectedvisitorId");
        print(_selectedvisitorId);
      }
    // }
  }

  GetVisitorType() async {
    try {
      //check Internet Connection
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          // pr.show();
        });
        var data = {};
        Services.responseHandler(apiName: "admin/getAllGuestCategory",body: data).then((data) async {
          setState(() {
            // pr.hide();
          });
          if (data.Data != null && data.Data.length > 0) {
            setState(() {
              VisitorTypeData = data.Data;
            });
            _visitorTypeSelection(context);
           setdata(data.Data);
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

  getNameOfVisitor(String mobileNo) async {
    try {
      //check Internet Connection
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          pr.show();
        });
        var data = {
          "ContactNo":mobileNo,
          "societyId":societyId
        };
        Services.responseHandler(apiName: "watchman/getVisitorInfo",body: data).then((data) async {
          setState(() {
            pr.hide();
          });
          if (data.Data != null && data.Data.length > 0) {
            setState(() {
              resultText.text = data.Data[0]["Name"];
            });
            Fluttertoast.showToast(
                msg: "Mobile Number Found",
                backgroundColor: Colors.green,
                gravity: ToastGravity.TOP,
                textColor: Colors.white);
          } else {
            Fluttertoast.showToast(
                msg: "Mobile Number Not Found",
                backgroundColor: Colors.red,
                gravity: ToastGravity.TOP,
                textColor: Colors.white);
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

  getFlatIds_v1(String societyId,String wingId,{int i}) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          "societyId" : societyId,
          "wingId" : wingId
        };
        FlatData.clear();
        Services.responseHandler(apiName: "admin/getFlatsOfSociety_v1",body: data).then((data) async {
          if (data.Data !=null) {
            setState(() {
              // FlatData = data.Data;
              for(int i=0;i<data.Data.length;i++){
                if(data.Data[i]["memberIds"].length > 0){
                  FlatData.add(data.Data[i]);
                  print(i);
                }
              }
            });
            if(FlatData.length > 0) {
              _flatSelectionBottomsheet(context,i);
            }
            else{
              Fluttertoast.showToast(
                  msg: "No Flat Member Found",
                  backgroundColor: Colors.red,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.white);
            }
          }
        }, onError: (e) {
          showMsg("$e");
        });
      } else {
        showMsg("No Internet Connection.");
      }
    } on SocketException catch (_) {
      showMsg("Something Went Wrong");
    }
  }

  GetCompanyName(int type) async {
    try {
      //check Internet Connection
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          // pr.show();
        });
        var data = {
          "type": type
        };

        Services.responseHandler(apiName: 'admin/getVisitorSubcategory',body: data).then((data) async {
          setState(() {
            // pr.hide();
          });
          if (data != null && data.Data.length > 0) {
            setState(() {
              CompanyData = data.Data;
            });
            _companySelectBottomSheet(context);
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

  GetPurpose() async {
    try {
      //check Internet Connection
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          // pr.show();
        });
        var data = {};
        Services.responseHandler(apiName: "admin/getAllPurposeCategory",body: data).then((data) async {
          setState(() {
            // pr.hide();
          });
          if (data.Data != null && data.Data.length > 0) {
            setState(() {
              purposeData = data.Data;
            });
            // _companySelectBottomSheet(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Add Visitor",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
      body: step == 1 ? visitortype : photoname(othersSelected),
    );
  }

  _visitorTypeSelection(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return Card(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Select Visitor Type",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: VisitorTypeData.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: InkWell(
                            onTap: () {
                              if(VisitorTypeData[index]["guestType"] == "Guest"){
                                Navigator.of(context).pop();
                                _selectedVisitorType =
                                VisitorTypeData[index]["guestType"];
                                /*_selectedVisitorIcon = VisitorTypeData[index]
                                              ["Icon"] !=
                                          null
                                      ? IMG_URL + VisitorTypeData[index]["Icon"] // told monil to add icon in this api
                                      : "";*/
                                _selectedvisitorId =
                                VisitorTypeData[index]["_id"];
                                setState(() {
                                  step = 2;
                                });
                              }
                              else if(VisitorTypeData[index]["guestType"] == "Amenities"){
                                Navigator.of(context).pop();
                                _selectedVisitorType =
                                VisitorTypeData[index]["guestType"];
                                /*_selectedVisitorIcon = VisitorTypeData[index]
                                              ["Icon"] !=
                                          null
                                      ? IMG_URL + VisitorTypeData[index]["Icon"] // told monil to add icon in this api
                                      : "";*/
                                _selectedvisitorId =
                                VisitorTypeData[index]["_id"];
                                setState(() {
                                  step = 2;
                                  othersSelected = true;
                                });
                              }
                              else
                              if (VisitorTypeData[index]["guestType"] == "Cab Driver"
                               || VisitorTypeData[index]["guestType"] == "Delivery Boy") {
                                setState(() {
                                  _selectedVisitorType =
                                      VisitorTypeData[index]["guestType"];
                                  /*_selectedVisitorIcon = VisitorTypeData[index]
                                              ["Icon"] !=
                                          null
                                      ? IMG_URL + VisitorTypeData[index]["Icon"] // told monil to add icon in this api
                                      : "";*/
                                  _selectedvisitorId =
                                      VisitorTypeData[index]["_id"];
                                });
                                Navigator.of(context).pop();
                              } else
                                GetVisitorType();
                              if (VisitorTypeData[index]["guestType"] == "Guest" ||VisitorTypeData[index]["guestType"] == "Amenities") {
                                // _companySelectBottomSheet(context);
                              } else if(VisitorTypeData[index]["guestType"] == "Cab Driver") {
                                GetCompanyName(0);
                              }
                              else{
                                GetCompanyName(1);
                              }
                            },
                            child: Card(
                              child: Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child:
                                          VisitorTypeData[index]["image"] != null
                                              ? Image.network(
                                                  '${IMG_URL}' +
                                                      '${VisitorTypeData[index]["image"]}',
                                                  width: 50,
                                                  height: 50,
                                                )
                                              : Image.asset(
                                                  'images/noimg.png',
                                                  width: 60,
                                                  height: 60,
                                                ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        '${VisitorTypeData[index]["guestType"]}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11),
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
            ),
          );
        });
  }

  _flatSelectionBottomsheet(BuildContext context,int i) {
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
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: InkWell(
                          onTap: () {
                            if (FlatData.length > 0) {
                              setState(() {
                                _FlateNo = FlatData[index]["flatNo"];
                                  flatsList.insert(i, _FlateNo);
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
                                      '${FlatData[index]["flatNo"].toString()}',
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

  _companySelectBottomSheet(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.grey[200],
        context: context,
        builder: (BuildContext context) {
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  " Select Company",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: GridView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: CompanyData.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: () {
                            if (CompanyData.length > 0) {
                              setState(() {
                                _selectedCompanyName =
                                    CompanyData[index]["name"];
                                _selectedCompanyLogo =
                                    CompanyData[index]["image"];
                              });
                              print(_selectedCompanyLogo);
                              Navigator.pop(context);
                            }
                            setState(() {
                              step = 2;
                            });
                          },
                          child: Card(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: CompanyData[index]["image"] != null
                                        ? Image.network(
                                            '${IMG_URL}' +
                                                '${CompanyData[index]["image"]}',
                                            height: 60,
                                            width: 60,
                                          )
                                        : Container(),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(
                                      '${CompanyData[index]["name"]}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    )),
              )
            ],
          );
        });
  }
}
