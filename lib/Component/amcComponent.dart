import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as cnst;

class amcComponent extends StatefulWidget {
  int index;
  var amcData;

  amcComponent(this.index, this.amcData);

  @override
  _amcComponentState createState() => _amcComponentState();
}

class _amcComponentState extends State<amcComponent> {
  String status = "";

  String setDate(String date) {
    String final_date = "";
    var tempDate;
    if (date != "" || date != null) {
      tempDate = date.toString().split("-");
      if (tempDate[2].toString().length == 1) {
        tempDate[2] = "0" + tempDate[2].toString();
      }
      if (tempDate[1].toString().length == 1) {
        tempDate[1] = "0" + tempDate[1].toString();
      }
      final_date = date == "" || date == null
          ? ""
          : "${tempDate[2].toString().substring(0, 2)}-${tempDate[1].toString()}-${tempDate[0].toString()}"
              .toString();
    }

    return final_date;
  }

  @override
  void initState() {
    if (DateTime.parse(widget.amcData["EndDate"]).isAfter(DateTime.now())) {
      setState(() {
        status = "Active";
      });
    } else
      setState(() {
        status = "Expired";
      });
  }

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: widget.index,
      duration: const Duration(milliseconds: 450),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Card(
            margin: EdgeInsets.all(6),
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          "${widget.amcData["ServiceName"]}",
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 35,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color:
                                status == "Active" ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "$status",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                            Padding(padding: EdgeInsets.only(left: 3)),
                            Icon(
                              Icons.done_all,
                              color: Colors.white,
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text(
                            "Start Date",
                            style: TextStyle(
                                color: cnst.appPrimaryMaterialColor,
                                fontWeight: FontWeight.w600),
                          ),
                          Padding(padding: EdgeInsets.only(top: 3)),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.date_range,
                                color: Colors.grey,
                                size: 15,
                              ),
                              Text(
                                "${setDate(widget.amcData["StartDate"])}",
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          )
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            "End Date",
                            style: TextStyle(
                                color: cnst.appPrimaryMaterialColor,
                                fontWeight: FontWeight.w600),
                          ),
                          Padding(padding: EdgeInsets.only(top: 3)),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.date_range,
                                color: Colors.grey,
                                size: 15,
                              ),
                              Text(
                                "${setDate(widget.amcData["EndDate"])}",
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          )
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            "Amount",
                            style: TextStyle(
                                color: cnst.appPrimaryMaterialColor,
                                fontWeight: FontWeight.w600),
                          ),
                          Padding(padding: EdgeInsets.only(top: 3)),
                          Text(
                            "${cnst.Inr_Rupee}${widget.amcData["Amount"]}",
                            style: TextStyle(color: Colors.grey[700]),
                          )
                        ],
                      ),
                    ],
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
