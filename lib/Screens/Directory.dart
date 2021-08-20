/*Widget Member_data(BuildContext context, int index) {
  return Container(
    color: Colors.white,
    child: ExpansionTile(
      title: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 1.0, top: 1, bottom: 1),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    image: new DecorationImage(
                        image: NetworkImage(
                            'https://randomuser.me/api/portraits/men/76.jpg'),
                        fit: BoxFit.cover),
                    borderRadius: BorderRadius.all(new Radius.circular(75.0)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Keval Mangroliya",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700])),
                    Row(
                      children: <Widget>[Text("Flat No:"), Text("102")],
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon:
                Image.asset("images/whatsapp_icon.png", width: 30, height: 30),
                onPressed: () {},
              ),
              IconButton(
                  icon: Icon(Icons.call, color: Colors.brown),
                  onPressed: () {}),
              IconButton(
                  icon: Icon(Icons.remove_red_eye,
                      color: cnst.appPrimaryMaterialColor),
                  onPressed: () {
                    Navigator.pushNamed(context, "/MemberProfile");
                  }),
              IconButton(icon: Icon(Icons.share), onPressed: () {}),
            ],
          ),
        )
      ],
    ),
  );
}*/

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as cnst;
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/LoadingComponent.dart';
import 'package:smartsocietystaff/Component/NoDataComponent.dart';
import 'package:smartsocietystaff/Screens/DirectoryMember.dart';

class Directory extends StatefulWidget {
  @override
  _DirectoryState createState() => _DirectoryState();
}

class _DirectoryState extends State<Directory> {
  List _wingList = [];
  bool isLoading = false;

  @override
  void initState() {
    _getWingList();
  }

  _getWingList() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Future res = Services.getWingList();
        setState(() {
          isLoading = true;
        });
        res.then((data) async {
          if (data != null && data.length > 0) {
            setState(() {
              _wingList = data;
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
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

  Widget _wingMenu(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DirectoryMember(
                      wingType: "${_wingList[index]["WingName"]}",
                      wingId: "${_wingList[index]["Id"]}",
                    )));
      },
      child: Card(
        elevation: 3,
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      _wingList[index]["WingName"],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 35,
                        color: cnst.appPrimaryMaterialColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    "Wing",
                    style: TextStyle(fontSize: 13),
                  ),
                  Text(
                    "Members: " +
                        "${_wingList[index]["MemberCount"].toString()}",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cnst.appPrimaryMaterialColor),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacementNamed(context, "/Dashboard");
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Directory",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/Dashboard");
            },
          ),
        ),
        body: isLoading
            ? LoadingComponent()
            : _wingList.length > 0 && _wingList != null
                ? Container(
                    height: MediaQuery.of(context).size.height,
                    color: Colors.grey[100],
                    child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _wingList.length,
                        itemBuilder: _wingMenu,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                        )),
                  )
                : NoDataComponent(),
      ),
    );
  }
}
