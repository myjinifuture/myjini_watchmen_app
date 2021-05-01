import 'package:flutter/material.dart';
import 'package:smartsocietystaff/Common/Constants.dart';

class VisitorProfile extends StatefulWidget {
  var _visitorList;

  VisitorProfile(this._visitorList);

  @override
  _VisitorProfileState createState() => _VisitorProfileState();
}

class _VisitorProfileState extends State<VisitorProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Card(
                  elevation: 2,
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipOval(
                                child: FadeInImage.assetNetwork(
                                    placeholder: 'images/user.png',
                                    image:
                                        "${IMG_URL + widget._visitorList["Image"]}",
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.fill)),
                          ),
                        ],
                      ),
                      Text("8456",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black)),
                      Text("Uniq Code", style: TextStyle(fontSize: 12)),
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text(
                          "Name",
                          style: TextStyle(fontSize: 12),
                        ),
                        subtitle: Text('${widget._visitorList["Name"]}',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700])),
                      ),
                      ListTile(
                        leading: Icon(Icons.call),
                        title: Text(
                          "Mobile",
                          style: TextStyle(fontSize: 12),
                        ),
                        subtitle: Text('${widget._visitorList["ContactNo"]}',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700])),
                      ),
                      ListTile(
                        leading: Icon(Icons.business),
                        title: Text(
                          "Company",
                          style: TextStyle(fontSize: 12),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top:4.0),
                          child: Row(
                            children: <Widget>[
                              Image.network('${IMG_URL +widget._visitorList["CompanyImage"]}.',height:30 ,),
                              Text(' ${widget._visitorList["CompanyName"]}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700]))
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
