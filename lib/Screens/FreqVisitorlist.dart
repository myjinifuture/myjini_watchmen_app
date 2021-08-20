import 'package:flutter/material.dart';
import 'package:smartsocietystaff/Component/VisitorOutSideComponent.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as constant;
import 'package:smartsocietystaff/Component/freqVisitorComponent.dart';
import 'package:smartsocietystaff/Screens/StaffOutSideList.dart';
import 'package:smartsocietystaff/Screens/StaffInSideList.dart';

class FreqVisitorlist extends StatefulWidget {
  @override
  _FreqVisitorlistState createState() => _FreqVisitorlistState();
}

class _FreqVisitorlistState extends State<FreqVisitorlist> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: AppBar(
              leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){}),
              elevation: 0,
              backgroundColor: Colors.white,
              flexibleSpace: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  new TabBar(
                    indicatorColor: constant.appPrimaryMaterialColor,
                    tabs: [
                      Tab(
                        child: Text("Inside",style: TextStyle(color: constant.appPrimaryMaterialColor),),
                      ),
                      Tab(
                        child: Text("OutSide",style: TextStyle(color: constant.appPrimaryMaterialColor),),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(children: [
            StaffInSideList(),
            StaffOutSideList()
          ])
      ),
    );
  }
}
