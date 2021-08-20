import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as cnst;
import 'package:smartsocietystaff/Component/LoadingComponent.dart';
import 'package:smartsocietystaff/Component/NoDataComponent.dart';
import 'package:smartsocietystaff/Screens/AddEventGallary.dart';

class EventGallary extends StatefulWidget {
  String eventId;

  EventGallary({this.eventId});

  @override
  _EventGallaryState createState() => _EventGallaryState();
}

class _EventGallaryState extends State<EventGallary> {
  List _eventGallaryData = [];
  bool isLoading = false;

  @override
  void initState() {
    _getEventGallaryData();
  }

  _getEventGallaryData() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Future res = Services.getEventGallary(widget.eventId);
        setState(() {
          isLoading = true;
        });
        res.then((data) async {
          if (data != null && data.length > 0) {
            setState(() {
              _eventGallaryData = data;
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
              _eventGallaryData = data;
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

  void _showConfirmDialog(eventId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("MYJINI"),
          content: new Text("Are You Sure You Want To Delete this Photo ?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("No",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Yes",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600)),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteEventGallary(eventId);
              },
            ),
          ],
        );
      },
    );
  }

  _deleteEventGallary(eventId) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          isLoading = true;
        });
        Services.DeleteEventGallary(eventId).then((data) async {
          if (data.Data == "1" && data.IsSuccess == true) {
            setState(() {
              isLoading = false;
            });
            _getEventGallaryData();
          } else {
            setState(() {
              isLoading = false;
            });
            showMsg("Event is Not Deleted..");
          }
        }, onError: (e) {
          setState(() {
            isLoading = false;
          });
          showMsg("Something Went Wrong Please Try Again");
        });
      }
    } on SocketException catch (_) {
      showMsg("Something Went Wrong");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, "/Events");
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Event Gallary",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/Events");
            },
          ),
        ),
        body: isLoading
            ? LoadingComponent()
            : _eventGallaryData.length > 0
                ? Container(
                    color: Colors.grey[300],
                    child: AnimationLimiter(
                      child: StaggeredGridView.countBuilder(
                        padding: const EdgeInsets.all(6),
                        crossAxisCount: 4,
                        itemCount: _eventGallaryData.length,
                        itemBuilder: (BuildContext context, int index) {
                          return AnimationConfiguration.staggeredGrid(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            columnCount: 2,
                            child: ScaleAnimation(
                              child: FadeInAnimation(
                                child: Container(
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Stack(
                                        children: <Widget>[
                                          FadeInImage.assetNetwork(
                                              placeholder:
                                                  'images/image_loading.gif',
                                              image: "http://smartsociety.itfuturz.com/" +
                                                  "${_eventGallaryData[index]["Image"]}",
                                              fit: BoxFit.fill),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Container(
                                              width: 25,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(3)),
                                              ),
                                              child: GestureDetector(
                                                  onTap: () {
                                                    _showConfirmDialog(
                                                        _eventGallaryData[index]
                                                                ["Id"]
                                                            .toString());
                                                  },
                                                  child: Icon(Icons.close)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        staggeredTileBuilder: (_) => StaggeredTile.fit(2),
                      ),
                    ))
                : NoDataComponent(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AddEventGallary(widget.eventId),
              ),
            );
          },
          child: Icon(Icons.add, color: Colors.white),
          backgroundColor: cnst.appPrimaryMaterialColor,
        ),
      ),
    );
  }
}
