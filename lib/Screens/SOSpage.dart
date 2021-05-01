import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as cnst;

// import 'package:smart_society_new/Member_App/common/Services.dart';
// import 'package:smart_society_new/Member_App/common/constant.dart' as constant;
// import '../common/constant.dart' as cnst;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartsocietystaff/Common/Services.dart';

List flats=[];

class FlatNo {
  final String name;

  FlatNo({
    this.name,
  });
}

class SOSpage extends StatefulWidget {
  @override
  _SOSpageState createState() => _SOSpageState();
}

class _SOSpageState extends State<SOSpage> {
  int isSelected = -1;

  List titles = ["Fire", "Accident", "Criminal", "Kids Alert"];
  List imageUrls = [
    'https://image.flaticon.com/icons/png/128/785/785116.png',
    'https://image.flaticon.com/icons/png/128/2474/2474058.png',
    'https://image.flaticon.com/icons/png/128/2861/2861240.png',
    'https://image.flaticon.com/icons/png/128/4072/4072108.png'
  ];

  List flatDetails=[];
  String societyId;
  String wingId;

  @override
  void initState() {
    // getFlatIds();
    _getLocaldata();
  }

  String SocietyId,flatId,memberId;
  List allFamilyIds = [],allWatchmenIds = [],allFlatMembersId = [];
  List flatNumbersAndIds = [],flatIdsForBackend = [];
  static List<FlatNo> flatNumbers = [];
  List flatsToMakeSort = [],selectedFlatIds = [];
  _getLocaldata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    SocietyId = prefs.getString(cnst.Session.SocietyId);
    wingId = prefs.getString(cnst.Session.WingId);
    memberId = prefs.getString(cnst.Session.MemberId);
    getFlatIds();
  }

  GetFamilyDetail() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          "societyId": SocietyId,
          "wingId": wingId,
          "flatId": flatId
        };
        Services.responseHandler(apiName: "member/getFamilyMembers",body: data).then((data) async {
          if (data.Data != null && data.Data.length > 0) {
            allFamilyIds.clear();
            setState(() {
              for(int i=0;i<data.Data.length;i++){
                allFamilyIds.add(data.Data[i]["_id"]);
              }
              //phoneNumber1 = data[0]["ContactNo"];
            });
            // for(int i=0;i<FmemberData.length;i++){
            //   if(FmemberData[i]["_id"].toString() == MemberId){
            //     FmemberData.remove(FmemberData[i]);
            //   }
            // }
          } else {
          }
        }, onError: (e) {
          showHHMsg("Try Again.", "");
        });
      }
    } on SocketException catch (_) {
      showHHMsg("No Internet Connection.", "");
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

  showHHMsg(String title, String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(title),
          content: new Text(msg),
          actions: <Widget>[
            new FlatButton(
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

  List EmergencyNumberData = [];
  List IdsSentToBakend = [];

  GetEmergencyNumber() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Services.responseHandler(
            apiName: "admin/getAllEmergencyContacts",
            body: {}).then((data) async {
          if (data.Data != null && data.Data.length > 0) {
            setState(() {
              EmergencyNumberData = data.Data;
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

  sendSos(List watchmen,List flat,List family) async {
    try {

      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // var body;
        // if(selFamMem && selFlats && !selWatchmen){
        //   body = {
        //     "senderId" : memberId,
        //     "receiverMemberIds" : flat + family,
        //     "receiverWatchmanIds" : flat + family,
        //     "message" : emergencyText.text,
        //     "societyId": SocietyId,
        //     "sendBy" : 1
        //   };
        //   print("body when only watchmen is not selected");
        //   print(body);
        // }
        // else  if(!selFamMem && !selFlats && selWatchmen){
        //   body = {
        //     // "senderId" : memberId,
        //     // "receiverIds" : recieverIds,
        //     // "message" : "SOS notification",
        //     // "isForMember" : false,
        //     // "deviceType": Platform.isAndroid ? "Android" : "IOS"
        //     "senderId" : memberId,
        //     "receiverMemberIds" : watchmen,
        //     "receiverWatchmanIds" : watchmen,
        //     "message" : emergencyText.text,
        //     "societyId": SocietyId,
        //     "sendBy" : 0
        //   };
        //   print("body when only watchmen is selected");
        //   print(body);
        // }
        // else  if(selFamMem && !selFlats && !selWatchmen){
        //   body = {
        //     // "senderId" : memberId,
        //     // "receiverIds" : recieverIds,
        //     // "message" : "SOS notification",
        //     // "isForMember" : false,
        //     // "deviceType": Platform.isAndroid ? "Android" : "IOS"
        //     "senderId" : memberId,
        //     "receiverMemberIds" : family,
        //     "receiverWatchmanIds" : family,
        //     "message" : emergencyText.text,
        //     "societyId": SocietyId,
        //     "sendBy" : 0
        //   };
        //   print("body when only family is selected");
        //   print(body);
        // }
        // else  if(!selFamMem && selFlats && !selWatchmen && flat.length > 0){
        //   body = {
        //     // "senderId" : memberId,
        //     // "receiverIds" : recieverIds,
        //     // "message" : "SOS notification",
        //     // "isForMember" : false,
        //     // "deviceType": Platform.isAndroid ? "Android" : "IOS"
        //     "senderId" : memberId,
        //     "receiverMemberIds" : flat,
        //     "receiverWatchmanIds" : flat,
        //     "message" : emergencyText.text,
        //     "societyId": SocietyId,
        //     "sendBy" : 0
        //   };
        //   print("body when only flat is selected");
        //   print(body);
        // }
        // else if(!selFamMem && selFlats && selWatchmen && flat.length > 0){
        //   body = {
        //     // "senderId" : memberId,
        //     // "receiverIds" : recieverIds,
        //     // "message" : "SOS notification",
        //     // "isForMember" : false,
        //     // "deviceType": Platform.isAndroid ? "Android" : "IOS"
        //     "senderId" : memberId,
        //     "receiverMemberIds" : flat,
        //     "receiverWatchmanIds" : watchmen,
        //     "message" : emergencyText.text,
        //     "societyId": SocietyId,
        //     "sendBy" : 0
        //   };
        //   print("body when only watchmen and flat is  selected");
        //   print(body);
        // }
        // else if(selFamMem && !selFlats && selWatchmen){
        //   body = {
        //     // "senderId" : memberId,
        //     // "receiverIds" : recieverIds,
        //     // "message" : "SOS notification",
        //     // "isForMember" : false,
        //     // "deviceType": Platform.isAndroid ? "Android" : "IOS"
        //     "senderId" : memberId,
        //     "receiverMemberIds" : family,
        //     "receiverWatchmanIds" : watchmen,
        //     "message" : emergencyText.text,
        //     "societyId": SocietyId,
        //     "sendBy" : 0
        //   };
        //   print("body when only watchmen and family is selected");
        //   print(body);
        // }
        // else{
        //   // pr.hide();
        //   Fluttertoast.showToast(
        //     msg: "No Member Found in that Flat",
        //     backgroundColor: Colors.red,
        //     gravity: ToastGravity.BOTTOM,
        //     textColor: Colors.white,
        //   );
        // }
        var body = {
          "senderId" : memberId,
          "receiverMemberIds" : flat.toSet().toList(),
          // "receiverWatchmanIds" : (flat + family).toSet().toList(),
          "message" : emergencyText.text,
          "societyId": SocietyId,
          "sendBy" : 1
        };
        print("body");
        print(body);
        Services.responseHandler(
            apiName: "member/sendSOS",
            body: body).then((data) async {
          print(data.Data);
          print(data.Message);
          if (data.Data != null && data.Data.toString() == "1") {
            // pr.hide();
            Fluttertoast.showToast(
              msg: "Notification Sent Successfully!!",
              backgroundColor: Colors.green,
              gravity: ToastGravity.TOP,
              textColor: Colors.white,
            );
            Navigator.pop(context);
          }
          // else {
          //   Fluttertoast.showToast(
          //       msg: "Error Occured",
          //       backgroundColor: Colors.red,
          //       gravity: ToastGravity.BOTTOM,
          //       textColor: Colors.white,
          //   );
          // }
          // allFamilyIds.clear();
          // allWatchmenIds.clear();
          // allFlatMembersId.clear();
        }, onError: (e) {
          // pr.hide();
          showHHMsg("Try Again.", "");
        });
      }
    } on SocketException catch (_) {
      // pr.hide();
      showHHMsg("No Internet Connection.", "");
    }
  }

  bool selWatchmen = false;
  bool selFamMem = false;
  bool selFlats = false;
  bool singleFlat=false;
  TextEditingController emergencyText = new TextEditingController();
  ProgressDialog pr;

  getFlatIds() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        societyId=prefs.getString(cnst.Session.SocietyId);
        wingId=prefs.getString(cnst.Session.WingId);
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
              if(!flatsToMakeSort.contains(data.Data[i]["flatNo"])) {
                flatsToMakeSort.add(data.Data[i]["flatNo"],);
                flatNumbersAndIds.add({
                  "flatNo" : data.Data[i]["flatNo"],
                  "flatId" : data.Data[i]["_id"]
                });
              }
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "SOS",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        // leading: IconButton(
        //   onPressed: () {
        //     Navigator.of(context).pop();
        //   },
        //   icon: Icon(
        //     Icons.arrow_back,
        //     color: Colors.white,
        //   ),
        // ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                SizedBox(
                  width: 15,
                ),
                Text(
                  "What kind of Emergency ?",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: cnst.appPrimaryMaterialColor,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            GridView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: titles.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  // childAspectRatio: 1.3,
                  mainAxisSpacing: 5, crossAxisSpacing: 5,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        isSelected = index;
                      });
                    },
                    child: Card(
                      color: isSelected == index
                          ? Colors.redAccent.withOpacity(0.6)
                          : null,
                      // margin: EdgeInsets.only(left: 15, right: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: NetworkImage(imageUrls[index]),
                                  fit: BoxFit.fill),
                            ),
                          ),
                          Text(
                            titles[index],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: cnst.appPrimaryMaterialColor,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Container(
              height: 0.5,
              color: Colors.black,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.always,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(Icons.location_pin),
                        hintText: 'Where is the emergency ?',
                      ),
                      onSaved: (String value) {
                        // This optional block of code can be used to run
                        // code when the user saves the form.
                      },
                      validator: (String value) {
                        return value.contains('@')
                            ? 'Do not use the @ char.'
                            : null;
                      },
                    )),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: RaisedButton(
                    //     disabledColor: Colors.red,
                    // disabledTextColor: Colors.black,
                    textColor: Colors.white,
                    color: cnst.appPrimaryMaterialColor,
                    onPressed: () {},
                    child: Text('MY LOCATION'),
                  ),
                ),
              ],
            ),
            Container(
              height: 0.5,
              color: Colors.black,
            ),
            Column(
              children: [
                // Row(
                //   children: [
                //     Checkbox(
                //       value: selWatchmen,
                //       onChanged: (bool value) {
                //         print(value);
                //         setState(() {
                //           selWatchmen = value;
                //         });
                //         if(value){
                //           GetWatchmenDetail();
                //         }
                //         else{
                //           allWatchmenIds.clear();
                //         }
                //       },
                //     ),
                //     Text('Watchmen'),
                //   ],
                // ),
                // Row(
                //   children: [
                //     Checkbox(
                //       value: selFamMem,
                //       onChanged: (bool value) {
                //         print(value);
                //         setState(() {
                //           selFamMem = !selFamMem;
                //         });
                //         if(value){
                //           GetFamilyDetail();
                //         }
                //         else{
                //           allFamilyIds.clear();
                //         }
                //       },
                //     ),
                //     Text('Family Member'),
                //   ],
                // ),
                Row(children: [Checkbox(
                  value: selFlats,
                  onChanged: (bool value) {
                    setState(() {
                      selFlats = !selFlats;
                    });
                    if(value){
                      setState(() {
                        getFlatIds();
                      });
                    }
                    else{
                      allFlatMembersId.clear();
                    }
                  },
                ),
                  Text('Flats'),],),
                selFlats == true ?
                MultiSelectDialogField(
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
                    print(allFlats);
                    flatIdsForBackend.clear();
                    for(int i=0;i<allFlats.length;i++){
                      for(int j=0;j<flatNumbersAndIds.length;j++){
                        if(flatNumbersAndIds[j]["flatNo"].toString() == allFlats[i].toString()){
                          flatIdsForBackend.add(flatNumbersAndIds[j]["flatId"]);
                        }
                      }
                    }
                    getFlatMemberId(flatIdsForBackend);
                    print("flatIdsForBackend");
                    print(flatIdsForBackend);
                  },
                ):Container(),
                RaisedButton(
                  child: Text(
                    "SEND REPORT",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  color: cnst.appPrimaryMaterialColor,
                  onPressed: () {
                    allFlatMembersId.toSet().toList();
                    allFamilyIds.toSet().toList();
                    // for(int i=0;i<allWatchmenIds.length;i++){
                    //   IdsSentToBakend.add({
                    //     "watchmenIds" : allWatchmenIds[i]
                    //   });
                    // }
                    // for(int i=0;i<allFlatMembersId.length;i++){
                    //   IdsSentToBakend.add({
                    //     "flatMemberIds" : allFlatMembersId[i]
                    //   });
                    // }
                    // for(int i=0;i<allFamilyIds.length;i++){
                    //   IdsSentToBakend.add({
                    //     "familyMemberIds" : allFamilyIds[i]
                    //   });
                    // }
                    print("allFlatMembersId");
                    print(allFlatMembersId.remove(null));
                    if(!selFlats){
                      Fluttertoast.showToast(
                          msg: "Please select at least One Field",
                          backgroundColor: Colors.red,
                          gravity: ToastGravity.TOP,
                          textColor: Colors.white);
                    }
                    // else if(selFlats && allFlatMembersId.length==0 ){
                    //   Fluttertoast.showToast(
                    //       msg: "No Members Found in that flat",
                    //       backgroundColor: Colors.red,
                    //       gravity: ToastGravity.TOP,
                    //       textColor: Colors.white);
                    // }
                    else{
                      sendSos(allWatchmenIds,allFlatMembersId,allFamilyIds);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      // bottomNavigationBar: FlatButton(
      //   height: 50,
      //   onPressed: () {
      //     if(isSelected == -1){
      //       Fluttertoast.showToast(
      //         msg: "Please select kind of Emergency you want",
      //         backgroundColor: Colors.red,
      //         gravity: ToastGravity.TOP,
      //         textColor: Colors.white,
      //       );
      //     }
      //     else{
      //       showDialog(
      //         context: context,
      //         builder: (BuildContext context) {
      //           return PopUp(titles[isSelected]);
      //         },
      //       );
      //     }
      //   },
      //   child: Text(
      //     'CONTINUE',
      //     style: TextStyle(color: Colors.white),
      //   ),
      //   color: cnst.appPrimaryMaterialColor,
      // ),
    );
  }
}

class PopUp extends StatefulWidget {
  // var flats;
  // PopUp({this.flats});
  String selectedEmergency = "";

  PopUp(this.selectedEmergency);

  @override
  _PopUpState createState() => _PopUpState();
}

class _PopUpState extends State<PopUp> {
  bool selWatchmen = false;
  bool selFamMem = false;
  bool selFlats = false;
  bool singleFlat=false;
  TextEditingController emergencyText = new TextEditingController();
  ProgressDialog pr;

  @override
  void initState() {
    if(widget.selectedEmergency == "Fire"){
      emergencyText.text = "Fire Emergency";
    }
    else if(widget.selectedEmergency == "Accident"){
      emergencyText.text = "Accident Emergency";
    }
    else if(widget.selectedEmergency == "Criminal"){
      emergencyText.text = "Crime Emergency";
    }
    else if(widget.selectedEmergency == "Kids Alert"){
      emergencyText.text = "Kids Emergency";
    }

    _getLocaldata();
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

  String SocietyId,flatId,memberId;
  List allFamilyIds = [],allWatchmenIds = [],allFlatMembersId = [];
  _getLocaldata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    SocietyId = prefs.getString(cnst.Session.SocietyId);
    wingId = prefs.getString(cnst.Session.WingId);
    memberId = prefs.getString(cnst.Session.MemberId);
  }

  GetFamilyDetail() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          "societyId": SocietyId,
          "wingId": wingId,
          "flatId": flatId
        };
        Services.responseHandler(apiName: "member/getFamilyMembers",body: data).then((data) async {
          if (data.Data != null && data.Data.length > 0) {
            allFamilyIds.clear();
            setState(() {
              for(int i=0;i<data.Data.length;i++){
                allFamilyIds.add(data.Data[i]["_id"]);
              }
              //phoneNumber1 = data[0]["ContactNo"];
            });
            // for(int i=0;i<FmemberData.length;i++){
            //   if(FmemberData[i]["_id"].toString() == MemberId){
            //     FmemberData.remove(FmemberData[i]);
            //   }
            // }
          } else {
          }
        }, onError: (e) {
          showHHMsg("Try Again.", "");
        });
      }
    } on SocketException catch (_) {
      showHHMsg("No Internet Connection.", "");
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

  showHHMsg(String title, String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(title),
          content: new Text(msg),
          actions: <Widget>[
            new FlatButton(
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

  List EmergencyNumberData = [];
  List IdsSentToBakend = [];

  GetEmergencyNumber() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Services.responseHandler(
            apiName: "admin/getAllEmergencyContacts",
            body: {}).then((data) async {
          if (data.Data != null && data.Data.length > 0) {
            setState(() {
              EmergencyNumberData = data.Data;
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

  sendSos(List watchmen,List flat,List family) async {
    try {

      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // var body;
        // if(selFamMem && selFlats && !selWatchmen){
        //   body = {
        //     "senderId" : memberId,
        //     "receiverMemberIds" : flat + family,
        //     "receiverWatchmanIds" : flat + family,
        //     "message" : emergencyText.text,
        //     "societyId": SocietyId,
        //     "sendBy" : 1
        //   };
        //   print("body when only watchmen is not selected");
        //   print(body);
        // }
        // else  if(!selFamMem && !selFlats && selWatchmen){
        //   body = {
        //     // "senderId" : memberId,
        //     // "receiverIds" : recieverIds,
        //     // "message" : "SOS notification",
        //     // "isForMember" : false,
        //     // "deviceType": Platform.isAndroid ? "Android" : "IOS"
        //     "senderId" : memberId,
        //     "receiverMemberIds" : watchmen,
        //     "receiverWatchmanIds" : watchmen,
        //     "message" : emergencyText.text,
        //     "societyId": SocietyId,
        //     "sendBy" : 0
        //   };
        //   print("body when only watchmen is selected");
        //   print(body);
        // }
        // else  if(selFamMem && !selFlats && !selWatchmen){
        //   body = {
        //     // "senderId" : memberId,
        //     // "receiverIds" : recieverIds,
        //     // "message" : "SOS notification",
        //     // "isForMember" : false,
        //     // "deviceType": Platform.isAndroid ? "Android" : "IOS"
        //     "senderId" : memberId,
        //     "receiverMemberIds" : family,
        //     "receiverWatchmanIds" : family,
        //     "message" : emergencyText.text,
        //     "societyId": SocietyId,
        //     "sendBy" : 0
        //   };
        //   print("body when only family is selected");
        //   print(body);
        // }
        // else  if(!selFamMem && selFlats && !selWatchmen && flat.length > 0){
        //   body = {
        //     // "senderId" : memberId,
        //     // "receiverIds" : recieverIds,
        //     // "message" : "SOS notification",
        //     // "isForMember" : false,
        //     // "deviceType": Platform.isAndroid ? "Android" : "IOS"
        //     "senderId" : memberId,
        //     "receiverMemberIds" : flat,
        //     "receiverWatchmanIds" : flat,
        //     "message" : emergencyText.text,
        //     "societyId": SocietyId,
        //     "sendBy" : 0
        //   };
        //   print("body when only flat is selected");
        //   print(body);
        // }
        // else if(!selFamMem && selFlats && selWatchmen && flat.length > 0){
        //   body = {
        //     // "senderId" : memberId,
        //     // "receiverIds" : recieverIds,
        //     // "message" : "SOS notification",
        //     // "isForMember" : false,
        //     // "deviceType": Platform.isAndroid ? "Android" : "IOS"
        //     "senderId" : memberId,
        //     "receiverMemberIds" : flat,
        //     "receiverWatchmanIds" : watchmen,
        //     "message" : emergencyText.text,
        //     "societyId": SocietyId,
        //     "sendBy" : 0
        //   };
        //   print("body when only watchmen and flat is  selected");
        //   print(body);
        // }
        // else if(selFamMem && !selFlats && selWatchmen){
        //   body = {
        //     // "senderId" : memberId,
        //     // "receiverIds" : recieverIds,
        //     // "message" : "SOS notification",
        //     // "isForMember" : false,
        //     // "deviceType": Platform.isAndroid ? "Android" : "IOS"
        //     "senderId" : memberId,
        //     "receiverMemberIds" : family,
        //     "receiverWatchmanIds" : watchmen,
        //     "message" : emergencyText.text,
        //     "societyId": SocietyId,
        //     "sendBy" : 0
        //   };
        //   print("body when only watchmen and family is selected");
        //   print(body);
        // }
        // else{
        //   // pr.hide();
        //   Fluttertoast.showToast(
        //     msg: "No Member Found in that Flat",
        //     backgroundColor: Colors.red,
        //     gravity: ToastGravity.BOTTOM,
        //     textColor: Colors.white,
        //   );
        // }
       var body = {
          "senderId" : memberId,
          "receiverMemberIds" : flat ,
          "receiverWatchmanIds" : flat + family,
          "message" : emergencyText.text,
          "societyId": SocietyId,
          "sendBy" : 1
        };

        Services.responseHandler(
            apiName: "member/sendSOS",
            body: body).then((data) async {
          print(data.Data);
          print(data.Message);
          if (data.Data != null && data.Data.toString() == "1") {
            // pr.hide();
            Fluttertoast.showToast(
              msg: "Notification Sent Successfully!!",
              backgroundColor: Colors.green,
              gravity: ToastGravity.TOP,
              textColor: Colors.white,
            );
            Navigator.pop(context);
            Navigator.pop(context);
          }
          // else {
          //   Fluttertoast.showToast(
          //       msg: "Error Occured",
          //       backgroundColor: Colors.red,
          //       gravity: ToastGravity.BOTTOM,
          //       textColor: Colors.white,
          //   );
          // }
          // allFamilyIds.clear();
          // allWatchmenIds.clear();
          // allFlatMembersId.clear();
        }, onError: (e) {
          // pr.hide();
          showHHMsg("Try Again.", "");
        });
      }
    } on SocketException catch (_) {
      // pr.hide();
      showHHMsg("No Internet Connection.", "");
    }
  }

  String societyId,wingId;
  List flatNumbersAndIds = [],flatIdsForBackend = [];
  static List<FlatNo> flatNumbers = [];
  List flatsToMakeSort = [],selectedFlatIds = [];

  getFlatIds() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        societyId=prefs.getString(cnst.Session.SocietyId);
        wingId=prefs.getString(cnst.Session.WingId);
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
              if(!flatsToMakeSort.contains(data.Data[i]["flatNo"])) {
                flatsToMakeSort.add(data.Data[i]["flatNo"],);
                flatNumbersAndIds.add({
                  "flatNo" : data.Data[i]["flatNo"],
                  "flatId" : data.Data[i]["_id"]
                });
              }
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
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Select people to Alert for the Emergency!"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            shape: RoundedRectangleBorder(
                side: new BorderSide(color: Colors.red, width: 2.0),
                borderRadius: BorderRadius.circular(4.0)),
            child: TextFormField(
              maxLines: 4,
              controller: emergencyText,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Message here... (Optional)",
                contentPadding: EdgeInsets.only(left: 10, top: 5),
              ),
            ),
          ),
          Column(
            children: [
              // Row(
              //   children: [
              //     Checkbox(
              //       value: selWatchmen,
              //       onChanged: (bool value) {
              //         print(value);
              //         setState(() {
              //           selWatchmen = value;
              //         });
              //         if(value){
              //           GetWatchmenDetail();
              //         }
              //         else{
              //           allWatchmenIds.clear();
              //         }
              //       },
              //     ),
              //     Text('Watchmen'),
              //   ],
              // ),
              // Row(
              //   children: [
              //     Checkbox(
              //       value: selFamMem,
              //       onChanged: (bool value) {
              //         print(value);
              //         setState(() {
              //           selFamMem = !selFamMem;
              //         });
              //         if(value){
              //           GetFamilyDetail();
              //         }
              //         else{
              //           allFamilyIds.clear();
              //         }
              //       },
              //     ),
              //     Text('Family Member'),
              //   ],
              // ),
              Row(children: [Checkbox(
                value: selFlats,
                onChanged: (bool value) {
                  setState(() {
                    selFlats = !selFlats;
                  });
                  if(value){
                    setState(() {
                      getFlatIds();
                    });
                  }
                  else{
                    allFlatMembersId.clear();
                  }
                },
              ),
                Text('Flats'),],),
              selFlats==true?MultiSelectDialogField(
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
                  print(allFlats);
                  flatIdsForBackend.clear();
                  for(int i=0;i<allFlats.length;i++){
                    for(int j=0;j<flatNumbersAndIds.length;j++){
                      if(flatNumbersAndIds[j]["flatNo"].toString() == allFlats[i].toString()){
                        flatIdsForBackend.add(flatNumbersAndIds[j]["flatId"]);
                      }
                    }
                  }
                  getFlatMemberId(flatIdsForBackend);
                  print("flatIdsForBackend");
                  print(flatIdsForBackend);
                },
              ):Container(),
              RaisedButton(
                child: Text(
                  "SEND REPORT",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                color: cnst.appPrimaryMaterialColor,
                onPressed: () {
                  allFlatMembersId.toSet().toList();
                  allFamilyIds.toSet().toList();
                  // for(int i=0;i<allWatchmenIds.length;i++){
                  //   IdsSentToBakend.add({
                  //     "watchmenIds" : allWatchmenIds[i]
                  //   });
                  // }
                  // for(int i=0;i<allFlatMembersId.length;i++){
                  //   IdsSentToBakend.add({
                  //     "flatMemberIds" : allFlatMembersId[i]
                  //   });
                  // }
                  // for(int i=0;i<allFamilyIds.length;i++){
                  //   IdsSentToBakend.add({
                  //     "familyMemberIds" : allFamilyIds[i]
                  //   });
                  // }
                  print("allFlatMembersId");
                  print(allFlatMembersId.remove(null));
                  if(!selFlats){
                    Fluttertoast.showToast(
                        msg: "Please select at least One Field",
                        backgroundColor: Colors.red,
                        gravity: ToastGravity.TOP,
                        textColor: Colors.white);
                  }
                  // else if(selFlats && allFlatMembersId.length==0 ){
                  //   Fluttertoast.showToast(
                  //       msg: "No Members Found in that flat",
                  //       backgroundColor: Colors.red,
                  //       gravity: ToastGravity.TOP,
                  //       textColor: Colors.white);
                  // }
                  else{
                    sendSos(allWatchmenIds,allFlatMembersId,allFamilyIds);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
