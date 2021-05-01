import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import '../Common/Constants.dart' as constant;
import 'MemberComponent.dart';

class CallSocietyMembers extends StatefulWidget {
  @override
  _CallSocietyMembersState createState() => _CallSocietyMembersState();
}

class _CallSocietyMembersState extends State<CallSocietyMembers> {
  bool isLoading = false, isSelected = false;
  String SocietyId, selectedWing = "";

  TextEditingController _controller = TextEditingController();

  Widget appBarTitle = new Text(
    "Directory",
    style: TextStyle(fontSize: 18),
  );

  List searchMemberData = new List();
  List WingData = new List();
  bool _isSearching = false,
      isfirst = false,
      isFilter = false,
      isMemberLoading = false;

  Icon icon = new Icon(
    Icons.search,
    color: Colors.white,
  );

  @override
  void initState() {
    print("init entered successfully");
    _getLocaldata();
  }

  _getLocaldata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    SocietyId = prefs.getString(constant.Session.SocietyId);
    print("soceityid");
    print(SocietyId);
    _getWingList();
  }

  String MobileNo = "";

  List MemberData = [];
  _getWingList() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print("soceityid");
        print(SocietyId);
        var data = {
          "societyId" : SocietyId
        };
        setState(() {
          isLoading = true;
        });
        Services.responseHandler(apiName: "admin/directoryListing",body: data).then((data) async {
          if (data.Data != null && data.Data.length > 0) {
            setState(() {
              MemberData = data.Data;
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
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

  @override
  Widget build(BuildContext context) {
    print(MemberData);
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, "/WatchmanDashboard");
      },
      child: Scaffold(
        appBar: buildAppBar(context),
        body: isLoading
            ? Container(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        )
            : Column(
          children: <Widget>[
            Container(
              color: constant.appPrimaryMaterialColor,
              width: MediaQuery.of(context).size.width,
              height: 40,
              padding: EdgeInsets.only(left: 12),
              alignment: Alignment.centerLeft,
              child: Text(
                "Members : ${MemberData.length}",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            isMemberLoading
                ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
                : Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 1.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child:
                 MemberData.length > 0 &&
                      MemberData != null
                      ? searchMemberData.length > 0
                      ? ListView.builder(
                    itemCount:
                    searchMemberData.length,
                    shrinkWrap: true,
                    itemBuilder:
                        (BuildContext context,
                        int index) {
                      return MemberComponent(
                          searchMemberData[
                          index]);
                    },
                  )
                      : ListView.builder(
                    padding:
                    EdgeInsets.all(0),
                    itemCount:
                    MemberData.length,
                    itemBuilder:
                        (BuildContext context,
                        int index) {
                      return MemberComponent(
                          MemberData[index]);
                    },
                  )
                      : Container(
                    child: Center(
                        child:
                        Text("No Member Found")),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: appBarTitle,
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, "/WatchmanDashboard");
          }),
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
      this.appBarTitle = new Text('Member Directory');
      _isSearching = false;
      isfirst = false;
      searchMemberData.clear();
      _controller.clear();
    });
  }

  void searchOperation(String searchText) {
    searchMemberData.clear();
    if (_isSearching != null) {
      isfirst = true;
      for (int i = 0; i < MemberData.length; i++) {
        String name = MemberData[i]["Name"];
        String flat = MemberData[i]["FlatNo"].toString();
        String mobile = MemberData[i]["ContactNo"].toString();
        String bloodGroup =
        MemberData[i]["BloodGroup"].toString();
        String designation =
        MemberData[i]["Designation"].toString();
        if (name.toLowerCase().contains(searchText.toLowerCase()) ||
            designation.toLowerCase().contains(searchText.toLowerCase()) ||
            mobile.toLowerCase().contains(searchText.toLowerCase()) ||
            bloodGroup.toLowerCase().contains(searchText.toLowerCase()) ||
            flat.toLowerCase().contains(searchText.toLowerCase())) {
          searchMemberData.add(MemberData[i]);
        }
        else{
          searchMemberData.remove(MemberData[i]);
        }
      }
    }
    setState(() {});
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
