import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as cnst;
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class VisitorOutSideComponent extends StatefulWidget {
  var _visitorOutSideList;

  VisitorOutSideComponent(this._visitorOutSideList);

  @override
  _VisitorOutSideComponentState createState() =>
      _VisitorOutSideComponentState();
}

class _VisitorOutSideComponentState extends State<VisitorOutSideComponent> {
  var date, newDt, monthNumber, dateNumber;
  String formattedInTime;
  String formattedOutTime;
  String hourInFormat;
  String hourOutFormat;
  DateTime fInTime, fOutTime;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget._visitorOutSideList["outDateTime"].length != 0) {
      monthNumber =
          widget._visitorOutSideList["outDateTime"][0].toString().split("/")[1];
      dateNumber =
          widget._visitorOutSideList["outDateTime"][0].toString().split("/")[0];
      date = DateTime.parse(widget._visitorOutSideList["outDateTime"][0]
              .toString()
              .split("/")[2] +
          "-" +
          monthNumber +
          "-" +
          dateNumber +
          " " +
          "00:00:00.000000");
      newDt = DateFormat.yMMMEd().format(date);
    }
    formatInTimeConversion();
    formatOutTimeConversion();
  }

  formatInTimeConversion() {
      if (widget._visitorOutSideList["inDateTime"][1]
              .toString()
              .split(' ')[1]
              .toString() !=
          "am") {
        hourInFormat = (int.parse(widget._visitorOutSideList["inDateTime"][1]
                        .toString()
                        .split(' ')[0]
                        .split(':')[0]) +
                    12)
                .toString() +
            ":" +
            widget._visitorOutSideList["inDateTime"][1]
                .toString()
                .split(' ')[0]
                .split(':')[1]
                .toString() +
            ":" +
            widget._visitorOutSideList["inDateTime"][1]
                .toString()
                .split(' ')[0]
                .split(':')[2]
                .toString();
        formattedInTime = widget._visitorOutSideList["inDateTime"][0]
                .toString()
                .split('/')[2]
                .toString() +
            "-" +
            widget._visitorOutSideList["inDateTime"][0]
                .toString()
                .split('/')[1]
                .toString() +
            "-" +
            widget._visitorOutSideList["inDateTime"][0]
                .toString()
                .split('/')[0]
                .toString() +
            " " +
            hourInFormat;
      } else {
        hourInFormat = int.parse(widget._visitorOutSideList["inDateTime"][1]
                    .toString()
                    .split(' ')[0]
                    .toString()
                    .split(":")[0]) >=
                10
            ? widget._visitorOutSideList["inDateTime"][1]
                .toString()
                .split(' ')[0]
                .toString()
            : "0" +
                widget._visitorOutSideList["inDateTime"][1]
                    .toString()
                    .split(' ')[0]
                    .toString();
        formattedInTime = widget._visitorOutSideList["inDateTime"][0]
                .toString()
                .split('/')[2]
                .toString() +
            "-" +
            widget._visitorOutSideList["inDateTime"][0]
                .toString()
                .split('/')[1]
                .toString() +
            "-" +
            widget._visitorOutSideList["inDateTime"][0]
                .toString()
                .split('/')[0]
                .toString() +
            " " +
            hourInFormat;
      }

  }

  formatOutTimeConversion() {
      if (widget._visitorOutSideList["outDateTime"][1]
              .toString()
              .split(' ')[1]
              .toString() !=
          "am") {
        hourOutFormat = (int.parse(widget._visitorOutSideList["outDateTime"][1]
                        .toString()
                        .split(' ')[0]
                        .split(':')[0]) +
                    12)
                .toString() +
            ":" +
            widget._visitorOutSideList["outDateTime"][1]
                .toString()
                .split(' ')[0]
                .split(':')[1]
                .toString() +
            ":" +
            widget._visitorOutSideList["outDateTime"][1]
                .toString()
                .split(' ')[0]
                .split(':')[2]
                .toString();
        formattedOutTime = widget._visitorOutSideList["outDateTime"][0]
                .toString()
                .split('/')[2]
                .toString() +
            "-" +
            widget._visitorOutSideList["outDateTime"][0]
                .toString()
                .split('/')[1]
                .toString() +
            "-" +
            widget._visitorOutSideList["outDateTime"][0]
                .toString()
                .split('/')[0]
                .toString() +
            " " +
            hourOutFormat;
      } else {
        hourOutFormat = int.parse(widget._visitorOutSideList["outDateTime"][1]
            .toString()
            .split(' ')[0]
            .toString()
            .split(":")[0]) >=
            10
            ? widget._visitorOutSideList["outDateTime"][1]
            .toString()
            .split(' ')[0]
            .toString()
            : "0" +
            widget._visitorOutSideList["outDateTime"][1]
                .toString()
                .split(' ')[0]
                .toString();
        formattedOutTime = widget._visitorOutSideList["outDateTime"][0]
            .toString()
            .split('/')[2]
            .toString()  +
            "-" +
            widget._visitorOutSideList["outDateTime"][0]
                .toString()
                .split('/')[1]
                .toString() +
            "-" +widget._visitorOutSideList["outDateTime"][0]
            .toString()
            .split('/')[0]
            .toString()
            +
            " " +
            hourOutFormat;
      }

  }

  @override
  Widget build(BuildContext context) {

    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, bottom: 20.0),
            child: ClipOval(
                child: FadeInImage.assetNetwork(
                    placeholder: 'images/Logo.png',
                    image:
                        "${cnst.IMG_URL + widget._visitorOutSideList["guestImage"]}",
                    width: 50,
                    height: 50,
                    fit: BoxFit.fill)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                  child: Text(
                    '${widget._visitorOutSideList["Name"]}',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text('${widget._visitorOutSideList["CompanyName"]}'),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                      "Flat No: ${widget._visitorOutSideList["WingData"][0]["wingName"]}- ${widget._visitorOutSideList["FlatData"][0]["flatNo"]}"),
                )
              ],
            ),
          ),
          Column(
            children: [
              widget._visitorOutSideList["outDateTime"].length == 0
                  ? Padding(
                      padding: const EdgeInsets.only(right: 35.0),
                      child: Text(
                        "No Date Found",
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(right: 35.0),
                      child: Text(
                        "$newDt",
                        style: TextStyle(color: cnst.appPrimaryMaterialColor),
                      ),
                    ),
              widget._visitorOutSideList["inDateTime"].length == 0
                  ? Padding(
                      padding: const EdgeInsets.only(right: 35.0),
                      child: Text(
                        "No inTime Found",
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(right: 35.0),
                      child: Text(
                        widget._visitorOutSideList["inDateTime"][1],
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
              widget._visitorOutSideList["outDateTime"].length == 0
                  ? Padding(
                      padding: const EdgeInsets.only(right: 35.0),
                      child: Text(
                        "No Outime Found",
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(right: 35.0),
                      child: Text(
                        widget._visitorOutSideList["outDateTime"][1],
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right:10.0,top: 10),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    "${(DateTime.parse(formattedOutTime).
                difference(DateTime.parse(formattedInTime))).toString().split('.')[0]}"),

                IconButton(
                    icon: Icon(
                      Icons.call,
                      color: Colors.green,
                    ),
                    onPressed: () {
                      UrlLauncher.launch(
                          'tel:${widget._visitorOutSideList["ContactNo"]}');
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
