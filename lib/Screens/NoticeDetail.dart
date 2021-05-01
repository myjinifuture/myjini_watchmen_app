import 'package:flutter/material.dart';

class NoticeDetail extends StatefulWidget {
  var noticeData;

  NoticeDetail(this.noticeData);

  @override
  _NoticeDetailState createState() => _NoticeDetailState();
}

class _NoticeDetailState extends State<NoticeDetail> {
  String setDate(String date) {
    var tempDate;
    if (date != "" || date != null) {
      tempDate = date.toString().split("-");
      if (tempDate[2].toString().length == 1) {
        tempDate[2] = "0" + tempDate[2].toString();
      }
      if (tempDate[1].toString().length == 1) {
        tempDate[1] = "0" + tempDate[1].toString();
      }
    }
    String final_date = date == "" || date == null
        ? ""
        : "${tempDate[2].toString().substring(0, 2)}-${tempDate[1].toString()}-${tempDate[0].toString()}"
            .toString();

    return final_date;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notice Detail"),
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: <Widget>[
            Center(
              child: Container(
                child: widget.noticeData["Image"] != "" &&
                        widget.noticeData["Image"] != null
                    ? FadeInImage.assetNetwork(
                        placeholder: '',
                        image: "http://smartsociety.itfuturz.com/" +
                            widget.noticeData["Image"],
                        height: MediaQuery.of(context).size.height / 3,
                        width: MediaQuery.of(context).size.width - 20,
                        fit: BoxFit.fill,
                      )
                    : Image.asset(
                        "images/no_image.png",
                        height: MediaQuery.of(context).size.height / 3,
                        width: MediaQuery.of(context).size.width - 20,
                        fit: BoxFit.fill,
                      ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Card(
                margin: EdgeInsets.only(left: 8, right: 8, top: 15, bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(1.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 6, top: 7, bottom: 10, right: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Image.asset(
                                    "images/notification_icon.png",
                                    width: 17,
                                    height: 15,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text("${widget.noticeData["Title"]}",
                                            style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600)),
                                        Text(
                                            "${setDate(widget.noticeData["Date"])}",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700])),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                endIndent: 10,
                                indent: 25,
                                color: Colors.grey[400],
                              ),
                              Text("${widget.noticeData["Description"]}",
                                  maxLines: 3,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.grey[900])),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
