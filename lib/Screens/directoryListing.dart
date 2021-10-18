/*
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/LoadingComponent.dart';

import 'DirectoryMemberComponent.dart';

// this is member directory - takes lots of time to search
class DirecotryScreen extends StatefulWidget {

  var searchMemberName;

  DirecotryScreen({this.searchMemberName});

  @override
  _DirecotryScreenState createState() => _DirecotryScreenState();
}

class _DirecotryScreenState extends State<DirecotryScreen> {
  bool isLoading = false, isFilter = false, isMemberLoading = false;
  List memberData = [];
  List _wingList = [];
  List filterMemberData = [];

  TextEditingController _controller = TextEditingController();

  Widget appBarTitle = new Text(
    "Member Directory",
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  );

  List searchMemberData = new List();
  bool _isSearching = false, isfirst = false;
  String selectedWing = "",wingName = "";

  Icon icon = new Icon(
    Icons.search,
    color: Colors.white,
  );

  @override
  void initState() {
    getLocaldata();
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
                Navigator.of(context).pop();;
              },
            ),
          ],
        );
      },
    );
  }

  String SocietyId,MobileNo;
  bool lengthIsZero = false;
  _getDirectoryListing({String seletecedWing}) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          "societyId" : SocietyId
        };
        setState(() {
          isLoading = true;
        });
        Services.responseHandler(apiName: "admin/directoryListing",body: data).then((data) async {
          memberData.clear();
          if (data.Data != null && data.Data.length > 0) {
            setState(() {
              // memberData = data.Data;
              if(widget.searchMemberName!=null){
                for(int i=0;i<data.Data.length;i++){
                  if(data.Data[i]["Name"].toString().split(" ")[0].toUpperCase()
                      .contains(widget.searchMemberName.split(" ")[0]) ||
                      data.Data[i]["ContactNo"].toString().toUpperCase().
                      contains(widget.searchMemberName.toUpperCase().trim().replaceAll(" ", ""))||
                      data.Data[i]["BloodGroup"].toString().toUpperCase().
                      contains(widget.searchMemberName.toUpperCase().trim().replaceAll(" ", ""))||
                      data.Data[i]["Vehicles"].toString().toUpperCase().replaceAll("-", "")
                          .contains(widget.searchMemberName.replaceAll(" ", "").replaceAll("-",""))  ||
                      (data.Data[i]["WingData"][0]["wingName"] + data.Data[i]["FlatData"][0]["flatNo"])
                          .toString().toUpperCase().replaceAll("-", "")
                          .contains(widget.searchMemberName.replaceAll(" ", ""))){
                    selectedWing = data.Data[i]["society"]["wingId"].toString();
                    wingName = data.Data[i]["WingData"][0]["wingName"].toString();
                    memberData.add(data.Data[i]);
                  }
                }
              }
              else{
                for(int i=0;i<data.Data.length;i++){
                  // if(data.Data[i]["society"]["wingId"] == selectedWing){
                    memberData.add(data.Data[i]);

                  // }
                }
                print("memberData");
                print(memberData[0]["FlatData"][0]["flatNo"]);
                memberData.sort((a,b){
                  return a["FlatData"][0]["flatNo"].toString().compareTo(b["FlatData"][0]["flatNo"].toString());
                });
              }
              isLoading = false;
              lengthIsZero = true;
            });
            print("memberData");
            print(memberData);
          } else {
            // setState(() {
            //   isLoading = false;
            // });
          }
        }, onError: (e) {
          showHHMsg("Something Went Wrong Please Try Again","");
          setState(() {
            isLoading = false;
          });
        });
      }
    } on SocketException catch (_) {
      showHHMsg("No Internet Connection.","");
    }
  }

  _getWing(String societyId) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          "societyId" : societyId
        };
        // setState(() {
        //   isLoading = true;
        // });
        Services.responseHandler(apiName: "admin/getAllWingOfSociety",body: data).then((data) async {
          if (data.Data != null && data.Data.length > 0) {
            setState(() {
              for(int i=0;i<data.Data.length;i++){
                if(data.Data[i]["totalFloor"].toString()!="0"){
                  _wingList.add(data.Data[i]);
                }
              }
              isLoading = false;
              if(widget.searchMemberName==null) {
                selectedWing = data.Data[0]["_id"].toString();
              }
            });
            if(widget.searchMemberName==null){
              _getDirectoryListing(seletecedWing: selectedWing);
            }
            else{
              _getDirectoryListing();
            }
            // _getotherListing(SocietyId,_fromDate.toString(),_toDate.toString());
            // S.Services.getStaffData(DateTime.now().toString(), DateTime.now().toString(),
            //     data[0]["Id"].toString());
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
    }
  }

  getLocaldata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // MobileNo = prefs.getString(Session.session_login);
      SocietyId = prefs.getString(Session.SocietyId);
    });
    _getWing(SocietyId);
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
                Navigator.of(context).pop();;
              },
            ),
          ],
        );
      },
    );
  }

  TextEditingController _searchcontroller = new TextEditingController();

  getSearchData(String text){
    searchMemberData.clear();
    for(int i=0;i<memberData.length;i++){
      setState(() {
        _isSearching = true;
      });
      if(memberData[i].toString().toLowerCase().contains(text.toLowerCase())){
        searchMemberData.add(memberData[i]);
      }
      print("searchMemberData");
      print(searchMemberData);
    }
  }

  //Members can see this directory
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        print("pressed");
        Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: buildAppBar(context),
        body: isLoading
            ? LoadingComponent()
            : Column(
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (int i = 0; i < _wingList.length; i++) ...[
                    GestureDetector(
                      onTap: () {
                        if (selectedWing != _wingList[i]["_id"].toString()) {
                          setState(() {
                            selectedWing = _wingList[i]["_id"].toString();
                            _getDirectoryListing(seletecedWing: selectedWing);
                          });
                          // setState(() {
                          //   memberData = [];
                          //   filterMemberData = [];
                          //   searchMemberData = [];
                          //   // isFilter = false;
                          //   // _isSearching = false;
                          // });
                        }
                      },
                      child: Container(
                        width: selectedWing == _wingList[i]["_id"].toString()
                            ? 60
                            : 45,
                        height:
                        selectedWing == _wingList[i]["_id"].toString()
                            ? 60
                            : 45,
                        margin: EdgeInsets.only(top: 10, left: 5, right: 5),
                        decoration: BoxDecoration(
                            color: selectedWing ==
                                _wingList[i]["_id"].toString()
                                ? appPrimaryMaterialColor
                                : Colors.white,
                            border: Border.all(
                                color: appPrimaryMaterialColor),
                            borderRadius:
                            BorderRadius.all(Radius.circular(4))),
                        alignment: Alignment.center,
                        child: Text(
                          "${_wingList[i]["wingName"]}",
                          style: TextStyle(
                              color: selectedWing ==
                                  _wingList[i]["_id"].toString()
                                  ? Colors.white
                                  : appPrimaryMaterialColor,
                              fontSize: 19),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child:
               memberData.length > 0 && memberData != null
                   ? searchMemberData.length != 0
                  ? AnimationLimiter(
                 child: ListView.builder(
                   padding: EdgeInsets.all(0),
                   itemCount: searchMemberData.length,
                   itemBuilder: (BuildContext context,
                       int index) {
                     return DirectoryMemberComponent(
                         MemberData:searchMemberData[index],
                         search : widget.searchMemberName,
                         wingName : wingName,
                         index:index);
                   },
                 ),
               )
                   : _isSearching && isfirst
                   ? AnimationLimiter(
                 child: ListView.builder(
                   padding: EdgeInsets.all(0),
                   itemCount:
                   searchMemberData.length,
                   itemBuilder:
                       (BuildContext context,
                       int index) {
                     return DirectoryMemberComponent(
                         search : widget.searchMemberName,
                         wingName : wingName,
                         MemberData:searchMemberData[index],
                        index:index);
                   },
                 ),
               )
                   :
              SingleChildScrollView(
                child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(8.0))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: TextFormField(
                                onChanged: (val){
                                  getSearchData(val);
                                },
                                cursorColor: Colors.black,
                                style: TextStyle(color: Colors.black),
                                textInputAction: TextInputAction.done,
                                controller: _searchcontroller,
                                keyboardType: TextInputType.text,
                                cursorRadius: Radius.circular(3),
                                decoration: InputDecoration(
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        getSearchData(_searchcontroller.text);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(8),
                                                bottomRight: Radius.circular(8))),
                                        child: Icon(
                                          Icons.search,
                                          color: appPrimaryMaterialColor,
                                          size: 23,
                                        ),
                                      ),
                                    ),
                           */
/*         suffixIcon: IconButton(
                      icon: Icon(Icons.mic),
                      onPressed: () {
                          requestPermission(PermissionGroup.microphone);
                          _speechRecognitionName
                              .listen(locale: "en_US")
                              .then((result) => print('####-$result'));
                      },
                    ),*//*

                                    border: InputBorder.none,
                                    hintText: "Search Here",
                                    hintStyle: TextStyle(
                                        fontSize: 13, color: Colors.black)),
                              ),
                            ),
                          ),
                        ),
                        AnimationLimiter(
                  child: _isSearching ?
                  ListView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.all(0),
                    itemCount: searchMemberData.length,
                    itemBuilder:
                        (BuildContext context,
                        int index) {
                      return DirectoryMemberComponent(
                          search : widget.searchMemberName,
                          wingName : wingName,
                          MemberData:searchMemberData[index],
                          index:index);
                    },
                  ):
                          ListView.builder(
                    shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.all(0),
                        itemCount: memberData.length,
                        itemBuilder:
                            (BuildContext context,
                            int index) {
                          return DirectoryMemberComponent(
                              search : widget.searchMemberName,
                              wingName : wingName,
                              MemberData:memberData[index],
                              index:index);
                        },
                  ),
                ),
                      ],
                    ),
              )                   : lengthIsZero ? Center(child: Text("No Data Found"),) :!isLoading ? Container()  :Container(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: appBarTitle,centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(context, '/WatchmanDashboard', (route) => false);
        },
      ),
       actions: <Widget>[
         new IconButton(
           icon: icon,
           onPressed: () {
             if (this.icon.icon == Icons.search) {
               this.icon = new Icon(
                 Icons.close,
                 color: Colors.white,
               );
               this.appBarTitle = new TextField(
                 controller: _controller,
                 style: new TextStyle(
                   color: Colors.white,
                 ),
                 decoration: new InputDecoration(
                     prefixIcon: new Icon(Icons.search, color: Colors.white),
                     hintText: "Search...",
                     hintStyle: new TextStyle(color: Colors.white)),
                 onChanged: searchOperation,
               );
               _handleSearchStart();
             } else {
               _handleSearchEnd();
             }
           },
         ),
       ],
    );
  }

  void _handleSearchStart() {
    setState(() {
      _isSearching = true;
    });
  }

  void _handleSearchEnd() {
    setState(() {
      this.icon = new Icon(
        Icons.search,
        color: Colors.white,
      );
      this.appBarTitle = new Text(
        'Member Directory'  ,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      );
      _isSearching = false;
      isfirst = false;
      searchMemberData.clear();
      _controller.clear();
    });
  }

  void searchOperation(String searchText) {
    if (_isSearching != null) {
      searchMemberData.clear();
      setState(() {
        isfirst = true;
      });
      for (int i = 0; i < memberData.length; i++) {
        String name = memberData[i]["Name"];
        String flat = memberData[i]["FlatData"][0]["flatNo"].toString();
        String wing = memberData[i]["WingData"][0]["wingName"].toString();
        String contactNo = memberData[i]["ContactNo"].toString();
        if (name.toLowerCase().contains(searchText.toLowerCase()) ||
            flat.toLowerCase().contains(searchText.toLowerCase())  ||
            wing.toLowerCase().contains(searchText.toLowerCase())||
            contactNo.toLowerCase().contains(searchText.toLowerCase())) {
          searchMemberData.add(memberData[i]);
        }
      }
    }
  }
}

class showFilterDailog extends StatefulWidget {
  Function onSelect;

  showFilterDailog({this.onSelect});

  @override
  _showFilterDailogState createState() => _showFilterDailogState();
}

class _showFilterDailogState extends State<showFilterDailog> {
  String _gender;

  bool ownerSelect = false, rentedSelect = false, ownedSelect = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Filter Your Criteria"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Gender",
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: Row(
              children: <Widget>[
                Radio(
                    value: 'Male',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                      });
                    }),
                Text("Male", style: TextStyle(fontSize: 13)),
                Radio(
                    value: 'Female',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                      });
                    }),
                Text("Female", style: TextStyle(fontSize: 13))
              ],
            ),
          ),
          Text(
            "Residential Type",
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600),
          ),
          Row(
            children: <Widget>[
              Checkbox(
                  activeColor: Colors.green,
                  value: ownedSelect,
                  onChanged: (bool value) {
                    setState(() {
                      ownedSelect = value;
                    });
                  }),
              Text(
                "Owned",
                style: TextStyle(fontSize: 13),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Checkbox(
                  activeColor: Colors.green,
                  value: rentedSelect,
                  onChanged: (bool value) {
                    setState(() {
                      rentedSelect = value;
                    });
                  }),
              Text(
                "Rented",
                style: TextStyle(fontSize: 13),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Checkbox(
                  activeColor: Colors.green,
                  value: ownerSelect,
                  onChanged: (bool value) {
                    setState(() {
                      ownerSelect = value;
                    });
                  }),
              Text(
                "Owner",
                style: TextStyle(fontSize: 13),
              )
            ],
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
        ),
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onSelect(_gender, ownedSelect, ownerSelect, rentedSelect);
          },
          child: Text("Done"),
        )
      ],
    );
  }
}
*/
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/LoadingComponent.dart';

import 'DirectoryMemberComponent.dart';



// this is member directory - takes lots of time to search
class DirecotryScreen extends StatefulWidget {

  var searchMemberName;

  DirecotryScreen({this.searchMemberName});

  @override
  _DirecotryScreenState createState() => _DirecotryScreenState();
}

class _DirecotryScreenState extends State<DirecotryScreen> {
  bool isLoading = false, isFilter = false, isMemberLoading = false;
  List memberData = [];
  List _wingList = [];
  List filterMemberData = [];

  TextEditingController _controller = TextEditingController();

  Widget appBarTitle = new Text(
    "Member Directory",
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  );

  List searchMemberData = new List();
  bool _isSearching = false, isfirst = false;
  String selectedWing = "",wingName = "";

  Icon icon = new Icon(
    Icons.search,
    color: Colors.white,
  );

  @override
  void initState() {
    getLocaldata();
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
                Navigator.of(context).pop();;
              },
            ),
          ],
        );
      },
    );
  }

  String SocietyId,MobileNo;
  bool lengthIsZero = false;
  _getDirectoryListing({String seletecedWing}) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          "societyId" : SocietyId
        };
        // setState(() {
        //   isLoading = true;
        // });
        Services.responseHandler(apiName: "admin/directoryListing",body: data).then((data) async {
          memberData.clear();
          if (data.Data != null && data.Data.length > 0) {
            setState(() {
              // memberData = data.Data;
              if(widget.searchMemberName!=null){
                for(int i=0;i<data.Data.length;i++){
                  if(data.Data[i]["Name"].toString().split(" ")[0].toUpperCase()
                      .contains(widget.searchMemberName.split(" ")[0]) ||
                      data.Data[i]["ContactNo"].toString().toUpperCase().
                      contains(widget.searchMemberName.toUpperCase().trim().replaceAll(" ", ""))||
                      data.Data[i]["BloodGroup"].toString().toUpperCase().
                      contains(widget.searchMemberName.toUpperCase().trim().replaceAll(" ", ""))||
                      data.Data[i]["Vehicles"].toString().toUpperCase().replaceAll("-", "")
                          .contains(widget.searchMemberName.replaceAll(" ", "").replaceAll("-",""))  ||
                      (data.Data[i]["WingData"][0]["wingName"] + data.Data[i]["FlatData"][0]["flatNo"])
                          .toString().toUpperCase().replaceAll("-", "")
                          .contains(widget.searchMemberName.replaceAll(" ", ""))){
                    selectedWing = data.Data[i]["society"]["wingId"].toString();
                    wingName = data.Data[i]["WingData"][0]["wingName"].toString();
                    memberData.add(data.Data[i]);
                  }
                }
              }
              else{
                for(int i=0;i<data.Data.length;i++){
                  if(data.Data[i]["society"]["wingId"] == selectedWing){
                    memberData.add(data.Data[i]);
                  }
                }
              }
              isLoading = false;
              lengthIsZero = true;
            });
            print("memberData");
            print(memberData);
          } else {
            // setState(() {
            //   isLoading = false;
            // });
          }
        }, onError: (e) {
          showHHMsg("Something Went Wrong Please Try Again","");
          setState(() {
            isLoading = false;
          });
        });
      }
    } on SocketException catch (_) {
      showHHMsg("No Internet Connection.","");
    }
  }

  _getWing(String societyId) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          "societyId" : societyId
        };
        setState(() {
          isLoading = true;
        });
        Services.responseHandler(apiName: "admin/getAllWingOfSociety",body: data).then((data) async {
          if (data.Data != null && data.Data.length > 0) {
            setState(() {
              for(int i=0;i<data.Data.length;i++){
                if(data.Data[i]["totalFloor"].toString()!="0"){
                  _wingList.add(data.Data[i]);
                }
              }
              isLoading = false;
              if(widget.searchMemberName==null) {
                selectedWing = data.Data[0]["_id"].toString();
              }
            });
            if(widget.searchMemberName==null){
              _getDirectoryListing(seletecedWing: selectedWing);
            }
            else{
              _getDirectoryListing();
            }
            // _getotherListing(SocietyId,_fromDate.toString(),_toDate.toString());
            // S.Services.getStaffData(DateTime.now().toString(), DateTime.now().toString(),
            //     data[0]["Id"].toString());
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
    }
  }

  getLocaldata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      //MobileNo = prefs.getString(Session.session_login);
      SocietyId = prefs.getString(Session.SocietyId);
    });
    _getWing(SocietyId);
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
                Navigator.of(context).pop();;
              },
            ),
          ],
        );
      },
    );
  }

  //Members can see this directory
  @override
  Widget build(BuildContext context) {
    print("lengthIsZero");
    print(lengthIsZero);
    return WillPopScope(
      onWillPop: (){
        print("pressed");
        Navigator.pushNamedAndRemoveUntil(context, '/WatchmanDashboard', (route) => false);
      },
      child: Scaffold(
        appBar: buildAppBar(context),
        body: isLoading
            ? LoadingComponent()
            : Column(
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (int i = 0; i < _wingList.length; i++) ...[
                    GestureDetector(
                      onTap: () {
                        if (selectedWing != _wingList[i]["_id"].toString()) {
                          setState(() {
                            selectedWing = _wingList[i]["_id"].toString();
                            _getDirectoryListing(seletecedWing: selectedWing);
                          });
                          // setState(() {
                          //   memberData = [];
                          //   filterMemberData = [];
                          //   searchMemberData = [];
                          //   // isFilter = false;
                          //   // _isSearching = false;
                          // });
                        }
                      },
                      child: Container(
                        width: selectedWing == _wingList[i]["_id"].toString()
                            ? 60
                            : 45,
                        height:
                        selectedWing == _wingList[i]["_id"].toString()
                            ? 60
                            : 45,
                        margin: EdgeInsets.only(top: 10, left: 5, right: 5),
                        decoration: BoxDecoration(
                            color: selectedWing ==
                                _wingList[i]["_id"].toString()
                                ? appPrimaryMaterialColor
                                : Colors.white,
                            border: Border.all(
                                color: appPrimaryMaterialColor),
                            borderRadius:
                            BorderRadius.all(Radius.circular(4))),
                        alignment: Alignment.center,
                        child: Text(
                          "${_wingList[i]["wingName"]}",
                          style: TextStyle(
                              color: selectedWing ==
                                  _wingList[i]["_id"].toString()
                                  ? Colors.white
                                  : appPrimaryMaterialColor,
                              fontSize: 19),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: memberData.length > 0 && memberData != null
                  ? searchMemberData.length != 0
                  ? AnimationLimiter(
                child: ListView.builder(
                  padding: EdgeInsets.all(0),
                  itemCount: searchMemberData.length,
                  itemBuilder: (BuildContext context,
                      int index) {
                    return DirectoryMemberComponent(
                        MemberData:searchMemberData[index],
                        search : widget.searchMemberName,
                        wingName : wingName,
                        index:index);
                  },
                ),
              )
                  : _isSearching && isfirst
                  ? AnimationLimiter(
                child: ListView.builder(
                  padding: EdgeInsets.all(0),
                  itemCount:
                  searchMemberData.length,
                  itemBuilder:
                      (BuildContext context,
                      int index) {
                    return DirectoryMemberComponent(
                        search : widget.searchMemberName,
                        wingName : wingName,
                        MemberData:searchMemberData[index],
                        index:index);
                  },
                ),
              )
                  : AnimationLimiter(
                child: ListView.builder(
                  padding: EdgeInsets.all(0),
                  itemCount: memberData.length,
                  itemBuilder:
                      (BuildContext context,
                      int index) {
                    return DirectoryMemberComponent(
                        search : widget.searchMemberName,
                        wingName : wingName,
                        MemberData:memberData[index],
                        index:index);
                  },
                ),
              )
                  : lengthIsZero ? Center(child: Text("No Data Found"),) :!isLoading ? Container()  :Container(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: appBarTitle,centerTitle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(10),
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(context, '/WatchmanDashboard', (route) => false);
        },
      ),
      // actions: <Widget>[
      //   new IconButton(
      //     icon: icon,
      //     onPressed: () {
      //       if (this.icon.icon == Icons.search) {
      //         this.icon = new Icon(
      //           Icons.close,
      //           color: Colors.white,
      //         );
      //         this.appBarTitle = new TextField(
      //           controller: _controller,
      //           style: new TextStyle(
      //             color: Colors.white,
      //           ),
      //           decoration: new InputDecoration(
      //               prefixIcon: new Icon(Icons.search, color: Colors.white),
      //               hintText: "Search...",
      //               hintStyle: new TextStyle(color: Colors.white)),
      //           onChanged: searchOperation,
      //         );
      //         _handleSearchStart();
      //       } else {
      //         _handleSearchEnd();
      //       }
      //     },
      //   ),
      // ],
    );
  }

  void _handleSearchStart() {
    setState(() {
      _isSearching = true;
    });
  }

  void _handleSearchEnd() {
    setState(() {
      this.icon = new Icon(
        Icons.search,
        color: Colors.white,
      );
      this.appBarTitle = new Text(
        '++Member Directory'  ,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      );
      _isSearching = false;
      isfirst = false;
      searchMemberData.clear();
      _controller.clear();
    });
  }

  void searchOperation(String searchText) {
    if (_isSearching != null) {
      searchMemberData.clear();
      setState(() {
        isfirst = true;
      });
      for (int i = 0; i < memberData.length; i++) {
        String name = memberData[i]["Name"];
        String flat = memberData[i]["FlatData"][0]["flatNo"].toString();
        String wing = memberData[i]["WingData"][0]["wingName"].toString();
        String contactNo = memberData[i]["ContactNo"].toString();
        if (name.toLowerCase().contains(searchText.toLowerCase()) ||
            flat.toLowerCase().contains(searchText.toLowerCase())  ||
            wing.toLowerCase().contains(searchText.toLowerCase())||
            contactNo.toLowerCase().contains(searchText.toLowerCase())) {
          searchMemberData.add(memberData[i]);
        }
      }
    }
  }
}

class showFilterDailog extends StatefulWidget {
  Function onSelect;

  showFilterDailog({this.onSelect});

  @override
  _showFilterDailogState createState() => _showFilterDailogState();
}

class _showFilterDailogState extends State<showFilterDailog> {
  String _gender;

  bool ownerSelect = false, rentedSelect = false, ownedSelect = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Filter Your Criteria"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Gender",
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: Row(
              children: <Widget>[
                Radio(
                    value: 'Male',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                      });
                    }),
                Text("Male", style: TextStyle(fontSize: 13)),
                Radio(
                    value: 'Female',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                      });
                    }),
                Text("Female", style: TextStyle(fontSize: 13))
              ],
            ),
          ),
          Text(
            "Residential Type",
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600),
          ),
          Row(
            children: <Widget>[
              Checkbox(
                  activeColor: Colors.green,
                  value: ownedSelect,
                  onChanged: (bool value) {
                    setState(() {
                      ownedSelect = value;
                    });
                  }),
              Text(
                "Owned",
                style: TextStyle(fontSize: 13),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Checkbox(
                  activeColor: Colors.green,
                  value: rentedSelect,
                  onChanged: (bool value) {
                    setState(() {
                      rentedSelect = value;
                    });
                  }),
              Text(
                "Rented",
                style: TextStyle(fontSize: 13),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Checkbox(
                  activeColor: Colors.green,
                  value: ownerSelect,
                  onChanged: (bool value) {
                    setState(() {
                      ownerSelect = value;
                    });
                  }),
              Text(
                "Owner",
                style: TextStyle(fontSize: 13),
              )
            ],
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
        ),
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onSelect(_gender, ownedSelect, ownerSelect, rentedSelect);
          },
          child: Text("Done"),
        )
      ],
    );
  }
}
