import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as cnst;
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:url_launcher/url_launcher.dart';

class StaffComponentBywing extends StatefulWidget {
  var _visitorData;
  int index;

  StaffComponentBywing(this._visitorData, this.index);

  @override
  _StaffComponentBywingState createState() => _StaffComponentBywingState();
}

class _StaffComponentBywingState extends State<StaffComponentBywing> {
  setTime(String datetime) {
    String hour = "";
    var time = datetime.split(" ");
    var t = time[1].split(":");
    if (int.parse(t[0]) > 12) {
      hour = (int.parse(t[0]) - 12).toString();
      return "${hour}:${t[1]} PM";
    } else {
      hour = int.parse(t[0]).toString();
      return "${hour}:${t[1]} AM";
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: widget.index,
      duration: const Duration(milliseconds: 450),
      child: SlideAnimation(
        horizontalOffset: 50.0,
        child: FadeInAnimation(
          child: Card(
            margin: EdgeInsets.only(top: 4, right: 8, left: 8, bottom: 6),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              padding: EdgeInsets.only(right: 10, top: 7, left: 7, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ClipOval(
                      child: widget._visitorData["Image"] != null &&
                              widget._visitorData["Image"] != ""
                          ? FadeInImage.assetNetwork(
                              placeholder: '',
                              image: "http://smartsociety.itfuturz.com/" +
                                  "${widget._visitorData["Image"]}",
                              width: 50,
                              height: 50,
                              fit: BoxFit.fill)
                          : Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: cnst.appPrimaryMaterialColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50))),
                              child: Center(
                                child: Text(
                                  "${widget._visitorData["Name"].toString().substring(0, 1).toUpperCase()}",
                                  style: TextStyle(
                                      fontSize: 26, color: Colors.white),
                                ),
                              ),
                            )),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('${widget._visitorData["Name"]}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('${widget._visitorData["Role"]}',
                              style: TextStyle(fontSize: 15)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.arrow_downward,
                                color: Colors.green,
                              ),
                              Text("${setTime(widget._visitorData["InTime"])}"),
                              widget._visitorData["OutTime"] == null ||
                                      widget._visitorData["OutTime"] == ""
                                  ? Container()
                                  : Icon(
                                      Icons.arrow_upward,
                                      color: Colors.red,
                                    ),
                              widget._visitorData["OutTime"] == null ||
                                      widget._visitorData["OutTime"] == ""
                                  ? Container()
                                  : Text(
                                      "${setTime(widget._visitorData["OutTime"])}"),
                            ],
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
      ),
    );
  }
}
