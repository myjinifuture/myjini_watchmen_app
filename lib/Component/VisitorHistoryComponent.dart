import 'package:flutter/material.dart';
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class VisitorHistoryComponent extends StatefulWidget {
  var _Visitorlist;

  VisitorHistoryComponent(this._Visitorlist);

  @override
  _VisitorHistoryComponentState createState() =>
      _VisitorHistoryComponentState();
}

class _VisitorHistoryComponentState extends State<VisitorHistoryComponent> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Card(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0, bottom: 8.0),
              child: ClipOval(
                child: widget._Visitorlist["Image"] != "" &&
                        widget._Visitorlist["Image"] != null
                    ? FadeInImage.assetNetwork(
                        placeholder: 'images/user.png',
                        image: "${IMG_URL + widget._Visitorlist["Image"]}",
                        width: 50,
                        height: 50,
                        fit: BoxFit.fill)
                    : Image.asset("images/user.png",
                        width: 50, height: 50, fit: BoxFit.fill),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                    child: Text(
                      '${widget._Visitorlist["Name"]}',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(widget._Visitorlist["CompanyName"] != "" &&
                            widget._Visitorlist["CompanyName"] != null
                        ? '${widget._Visitorlist["CompanyName"]}'
                        : '${widget._Visitorlist["VisitorTypeName"]}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                        "Flat No: ${widget._Visitorlist["WingId"]}- ${widget._Visitorlist["FlatId"]}"),
                  )
                ],
              ),
            ),
            IconButton(
                icon: Icon(
                  Icons.call,
                  color: Colors.green,
                ),
                onPressed: () {
                  UrlLauncher.launch('tel:${widget._Visitorlist["ContactNo"]}');
                }),
          ],
        ),
      ),
    );
  }
}
