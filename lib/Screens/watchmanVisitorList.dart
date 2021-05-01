import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/VisitorInsideComponent.dart';
import 'package:smartsocietystaff/Component/VisitorInsideComponent.dart';
import 'package:smartsocietystaff/Component/VisitorOutSideComponent.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as constant;
import 'package:smartsocietystaff/Screens/VisitorInsideList.dart';
import 'package:smartsocietystaff/Screens/VisitorOutSideList.dart';

class visitorlist extends StatefulWidget {
  @override
  _visitorlistState createState() => _visitorlistState();
}

class _visitorlistState extends State<visitorlist> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: AppBar(
              leading:
                  IconButton(icon: Icon(Icons.arrow_back), onPressed: () {}),
              elevation: 0,
              backgroundColor: Colors.white,
              flexibleSpace: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new TabBar(
                    indicatorColor: constant.appPrimaryMaterialColor,
                    tabs: [
                      Tab(
                        child: Text(
                          "Inside",
                          style: TextStyle(
                              color: constant.appPrimaryMaterialColor),
                        ),
                      ),
                      Tab(
                        child: Text(
                          "OutSide",
                          style: TextStyle(
                              color: constant.appPrimaryMaterialColor),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(children: [
            VisitorInsideList(),
            VisitorOutSideList(),
          ])),
    );
  }
}
