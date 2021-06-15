import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as constant;
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/LoadingComponent.dart';
import 'package:smartsocietystaff/Component/NoDataComponent.dart';
import 'package:smartsocietystaff/Component/VisitorHistoryComponent.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as cnst;

class VisitorHistoryList extends StatefulWidget {
  @override
  _VisitorHistoryListState createState() => _VisitorHistoryListState();
}

class _VisitorHistoryListState extends State<VisitorHistoryList> {
  TextEditingController _searchcontroller = new TextEditingController();

  List _Visitorlist = [];
  List searchvisitordata = new List();
  String societyId = "";
  bool isLoading = false;
  bool _isSearching = true, isfirst = false;

  @override
  void initState() {
    _getInsideVisitor();
    _getLocaldata();
  }

  _getLocaldata() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    societyId = prefs.getString(cnst.Session.SocietyId);
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
        Services.responseHandler(apiName: "watchman/getAllVisitorEntry",body: data).then((data) async {
          _Visitorlist.clear();
          if (data.Data != null && data.Data.length > 0) {
            setState(() {
              // _visitorInsideList = data.Data;
              isLoading = false;
              for(int i=0;i<data.Data.length;i++){
                if(data.Data[i]["outDateTime"].length == 0){
                  print("deleted");
                  _Visitorlist.add(data.Data[i]);
                  // _visitorInsideList.length--;
                }
              }
              _Visitorlist = _Visitorlist.reversed.toList();
            });
          } else {
            setState(() {
              _Visitorlist = data.Data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: TextFormField(
              style: TextStyle(color: Colors.white),
              autofocus: false,
              textInputAction: TextInputAction.done,
              controller: _searchcontroller,
              onChanged: searchOperation,
              keyboardType: TextInputType.text,
              cursorRadius: Radius.circular(3),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search Here",
                  hintStyle: TextStyle(
                      fontSize: 13, color: Color.fromRGBO(255, 255, 255, 0.5))),
            ),
          ),
        ),
      ),
      body: isLoading
          ? LoadingComponent()
          : _Visitorlist.length > 0 && _Visitorlist != null
              ? searchvisitordata.length != 0
                  ? ListView.builder(
                      physics: BouncingScrollPhysics(),
                      padding: EdgeInsets.all(0),
                      itemCount: searchvisitordata.length,
                      itemBuilder: (BuildContext context, int index) {
                        return VisitorHistoryComponent(
                            searchvisitordata[index]);
                      },
                    )
                  : _isSearching && isfirst
                      ? ListView.builder(
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.all(0),
                          itemCount: searchvisitordata.length,
                          itemBuilder: (BuildContext context, int index) {
                            return VisitorHistoryComponent(
                                searchvisitordata[index]);
                          },
                        )
                      : ListView.builder(
                          physics: BouncingScrollPhysics(),
                          padding: EdgeInsets.all(0),
                          itemCount: _Visitorlist.length,
                          itemBuilder: (BuildContext context, int index) {
                            return VisitorHistoryComponent(_Visitorlist[index]);
                          },
                        )
              : NoDataComponent(),
    );
  }

  void searchOperation(String searchText) {
    searchvisitordata.clear();
    setState(() {
      isfirst = true;
    });
    for (int i = 0; i < _Visitorlist.length; i++) {
      String name = _Visitorlist[i]["Name"].toString();
      String mobile = _Visitorlist[i]["ContactNo"].toString();
      String WingData = _Visitorlist[i]["WingData"][0]["wingName"].toString();
      String flatData = _Visitorlist[i]["FlatData"][0]["flatNo"].toString();
      if (name.toLowerCase().contains(searchText.toLowerCase()) ||
          mobile.toLowerCase().contains(searchText.toLowerCase()) ||
          WingData.toLowerCase().contains(searchText.toLowerCase())||
          flatData.toLowerCase().contains(searchText.toLowerCase())) {
        print(_Visitorlist[i]);
        searchvisitordata.add(_Visitorlist[i]);
      }
    }
    setState(() {

    });
  }
}
