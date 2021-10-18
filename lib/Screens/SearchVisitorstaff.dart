import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/NoDataComponent.dart';
import 'package:smartsocietystaff/Component/VisitorInsideComponent.dart';
class searchvisitorstaff extends StatefulWidget {
 // const searchvisitorstaff({Key? key}) : super(key: key);

  @override
  _searchvisitorstaffState createState() => _searchvisitorstaffState();
}

class _searchvisitorstaffState extends State<searchvisitorstaff> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocalData();
  }
  List _visitorInsideList=[];
  List searchMemberData=[];
  bool isLoading=false;
  String societyId;
  bool _isSearching = false, isfirst = false;
  TextEditingController _controller = TextEditingController();
  getLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    societyId = prefs.getString(Session.SocietyId);
    _getInsideVisitor();
  }
  _getInsideVisitor() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        var data = {
          "societyId" : societyId
        };

        setState(() {
          isLoading = true;
        });
        Services.responseHandler(apiName: "watchman/getAllVisitorEntry_v1",body: data).then((data) async {
          _visitorInsideList.clear();
          if (data.Data != null && data.Data.length > 0) {
            setState(() {
              // _visitorInsideList = data.Data;
              isLoading = false;
              for(int i=0;i<data.Data.length;i++){
                if(data.Data[i]["outDateTime"].length == 0){
                  _visitorInsideList.add(data.Data[i]);
                  // _visitorInsideList.length--;
                }
              }
              _visitorInsideList = _visitorInsideList.reversed.toList();
            });
          } else {
            setState(() {
              _visitorInsideList = data.Data;
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
  Widget appBarTitle = new Text(
    "Search Visitor and Staff",
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  );
  Icon icon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  void searchOperation(String searchText) {
    if (_isSearching != null) {
      searchMemberData.clear();
      setState(() {
        isfirst = true;
      });
      for (int i = 0; i < _visitorInsideList.length; i++) {
        String name = _visitorInsideList[i]["Name"];
        String flat = _visitorInsideList[i]["ContactNo"].toString();
        String indate = _visitorInsideList[i]["inDateTime"].toString();
        String outdate = _visitorInsideList[i]["outDateTime"].toString();
        String vn = _visitorInsideList[i]["vehicleNo"].toString();
        if (name.toLowerCase().contains(searchText.toLowerCase()) ||
            flat.toLowerCase().contains(searchText.toLowerCase()) ||
            indate.toLowerCase().contains(searchText.toLowerCase())||
            outdate.toLowerCase().contains(searchText.toLowerCase())||
            vn.toLowerCase().contains(searchText.toLowerCase())
        ) {
          searchMemberData.add(_visitorInsideList[i]);
        }
      }
    }
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
        'Member Directory',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      );
      _isSearching = false;
      isfirst = false;
      searchMemberData.clear();
      _controller.clear();
    });
  }
  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: appBarTitle,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context), /*AppBar(
        centerTitle: true,
        title: Text(
          "Search Visitor and Staff",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),*/
      body:  isLoading
          ? Center(child: CircularProgressIndicator())
          : searchMemberData.length > 0?ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return VisitorInsideComponent(
              searchMemberData[index], index, (type) {
            if (type == "false")
              setState(() {
                _getInsideVisitor();
              });
            else if (type == "loading")
              setState(() {
                isLoading = true;
              });
          });
        },
        itemCount: searchMemberData.length,
      ):_visitorInsideList.length > 0
          ? ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return VisitorInsideComponent(
              _visitorInsideList[index], index, (type) {
            if (type == "false")
              setState(() {
                _getInsideVisitor();
              });
            else if (type == "loading")
              setState(() {
                isLoading = true;
              });
          });
        },
        itemCount: _visitorInsideList.length,
      )
          : NoDataComponent()
    );
  }
}
