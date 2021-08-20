import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:smartsocietystaff/Screens/MemberProfile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as cnst;

class DirectoryMemberComponent extends StatefulWidget {
  var memberData;

  int index;

  DirectoryMemberComponent(this.memberData, this.index);

  @override
  _DirectoryMemberComponentState createState() =>
      _DirectoryMemberComponentState();
}

class _DirectoryMemberComponentState extends State<DirectoryMemberComponent> {
  _openWhatsapp(mobile) {
    String whatsAppLink = cnst.whatsAppLink;
    String urlwithmobile = whatsAppLink.replaceAll("#mobile", "91$mobile");
    String urlwithmsg = urlwithmobile.replaceAll("#msg", "");
    launch(urlwithmsg);
  }

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: widget.index,
      duration: const Duration(milliseconds: 450),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Container(
            color: Colors.white,
            child: ExpansionTile(
              title: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      ClipOval(
                        child: widget.memberData["Image"] != '' &&
                                widget.memberData["Image"] != null
                            ? FadeInImage.assetNetwork(
                                placeholder: '',
                                image: "http://smartsociety.itfuturz.com/" +
                                    "${widget.memberData["Image"]}",
                                width: 50,
                                height: 50,
                                fit: BoxFit.fill)
                            : Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: cnst.appPrimaryMaterialColor,
                                ),
                                child: Center(
                                  child: Text(
                                    "${widget.memberData["Name"].toString().substring(0, 1).toUpperCase()}",
                                    style: TextStyle(
                                        fontSize: 25, color: Colors.white),
                                  ),
                                ),
                              ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("${widget.memberData["Name"]}",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700])),
                              Row(
                                children: <Widget>[
                                  Text("Flat No:"),
                                  Text("${widget.memberData["FlatNo"]}")
                                ],
                              )
                            ],
                          ),
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
                        icon: Image.asset("images/whatsapp_icon.png",
                            width: 30, height: 30),
                        onPressed: () {
                          _openWhatsapp(
                              widget.memberData["ContactNo"].toString());
                        },
                      ),
                      IconButton(
                          icon: Icon(Icons.call, color: Colors.brown),
                          onPressed: () {
                            launch("tel:" + widget.memberData["ContactNo"]);
                          }),
                      IconButton(
                          icon: Icon(Icons.remove_red_eye,
                              color: cnst.appPrimaryMaterialColor),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MemberProfile(
                                          memberData: widget.memberData,
                                        )));
                          }),
                      IconButton(icon: Icon(Icons.share), onPressed: () {}),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
