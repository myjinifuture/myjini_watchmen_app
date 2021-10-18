import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as cnst;
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/DirectoryMemberComponent.dart';
import 'package:smartsocietystaff/Component/LoadingComponent.dart';
import 'package:smartsocietystaff/Component/NoDataComponent.dart';
class DirectoryMember extends StatefulWidget {
  String wingType, wingId;
  DirectoryMember({this.wingType, this.wingId});
  @override
  _DirectoryMemberState createState() => _DirectoryMemberState();
}
class _DirectoryMemberState extends State<DirectoryMember> {
  bool isLoading = false, isFilter = false;
  List memberData = [];
  List filterMemberData = [];
  TextEditingController _controller = TextEditingController();
  Widget appBarTitle = new Text(
    "Member Directory",
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  );
  List searchMemberData = new List();
  bool _isSearching = false, isfirst = false;
  Icon icon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  _getMembers() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        Future res = Services.getMembersByWing(widget.wingId);
        setState(() {
          isLoading = true;
        });
        res.then((data) async {
          if (data != null && data.length > 0) {
            setState(() {
              memberData = data;
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
  @override
  void initState() {
    _getMembers();
  }
  showMsg(String msg, {String title = 'MYJINI'}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(title),
          content: new Text(msg),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: isLoading
          ? LoadingComponent()
          : Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: FlatButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "Filter",
                          style: TextStyle(
                              fontSize: 16,
                              color: cnst.appPrimaryMaterialColor,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Icon(
                          Icons.filter_list,
                          size: 19,
                          color: cnst.appPrimaryMaterialColor,
                        ),
                      ],
                    ),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return showFilterDailog(
                              onSelect: (gender, isOwned, isOwner, isRented) {
                                String owned = isOwned ? "Owned" : "";
                                String owner = isOwner ? "Owner" : "";
                                String rented = isRented ? "Rented" : "";
                                setState(() {
                                  isFilter = true;
                                  filterMemberData.clear();
                                });
                                for (int i = 0; i < memberData.length; i++) {
                                  if (memberData[i]["MemberData"]["Gender"] ==
                                          gender ||
                                      memberData[i]["MemberData"]
                                              ["ResidenceType"] ==
                                          owned ||
                                      memberData[i]["MemberData"]
                                              ["ResidenceType"] ==
                                          owner ||
                                      memberData[i]["MemberData"]
                                              ["ResidenceType"] ==
                                          rented) {
                                    print("matched");
                                    filterMemberData.add(memberData[i]);
                                  }
                                }
                                setState(() {});
                              },
                            );
                          });
                    },
                  ),
                ),
                Expanded(
                  child: isFilter
                      ? filterMemberData.length > 0
                          ? AnimationLimiter(
                              child: ListView.builder(
                                padding: EdgeInsets.all(0),
                                itemCount: filterMemberData.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return DirectoryMemberComponent(
                                      filterMemberData[index]["MemberData"],
                                      index);
                                },
                              ),
                            )
                          : Container(
                              child: Center(child: Text("No Member Found")),
                            )
                      : memberData.length > 0 && memberData != null
                          ? searchMemberData.length != 0
                              ? AnimationLimiter(
                                  child: ListView.builder(
                                    padding: EdgeInsets.all(0),
                                    itemCount: searchMemberData.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return DirectoryMemberComponent(
                                          searchMemberData[index]["MemberData"],
                                          index);
                                    },
                                  ),
                                )
                              : _isSearching && isfirst
                                  ? AnimationLimiter(
                                      child: ListView.builder(
                                        padding: EdgeInsets.all(0),
                                        itemCount: searchMemberData.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return DirectoryMemberComponent(
                                              searchMemberData[index]
                                                  ["MemberData"],
                                              index);
                                        },
                                      ),
                                    )
                                  : AnimationLimiter(
                                      child: ListView.builder(
                                        padding: EdgeInsets.all(0),
                                        itemCount: memberData.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return DirectoryMemberComponent(
                                              memberData[index]["MemberData"],
                                              index);
                                        },
                                      ),
                                    )
                          : NoDataComponent(),
                ),
              ],
            ),
    );
  }
  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: appBarTitle,
      actions: <Widget>[
        new IconButton(
          icon: icon,
          onPressed: () {
            if (this.icon.icon == Icons.search) {
              this.icon = new Icon(
                Icons.close,
                color: Colors.white,
              );
              this.appBarTitle = new TextField(
                controller: _controller,
                style: new TextStyle(
                  color: Colors.white,
                ),
                decoration: new InputDecoration(
                    prefixIcon: new Icon(Icons.search, color: Colors.white),
                    hintText: "Search...",
                    hintStyle: new TextStyle(color: Colors.white)),
                onChanged: searchOperation,
              );
              _handleSearchStart();
            } else {
              _handleSearchEnd();
            }
          },
        ),
      ],
    );
  }
  void _handleSearchStart() {
    setState(() {
      _isSearching = true;
    });
  }
  void _handleSearchEnd() {
    setState(() {
      this.icon = new Icon(
        Icons.search,
        color: Colors.white,
      );
      this.appBarTitle = new Text(
        'Member Directory',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      );
      _isSearching = false;
      isfirst = false;
      searchMemberData.clear();
      _controller.clear();
    });
  }
  void searchOperation(String searchText) {
    if (_isSearching != null) {
      searchMemberData.clear();
      setState(() {
        isfirst = true;
      });
      for (int i = 0; i < memberData.length; i++) {
        String name = memberData[i]["MemberData"]["Name"];
        String flat = memberData[i]["MemberData"]["FlatNo"].toString();
        if (name.toLowerCase().contains(searchText.toLowerCase()) ||
            flat.toLowerCase().contains(searchText.toLowerCase())) {
          searchMemberData.add(memberData[i]);
        }
      }
    }
  }
}
class showFilterDailog extends StatefulWidget {
  Function onSelect;
  showFilterDailog({this.onSelect});
  @override
  _showFilterDailogState createState() => _showFilterDailogState();
}
class _showFilterDailogState extends State<showFilterDailog> {
  String _gender;
  bool ownerSelect = false, rentedSelect = false, ownedSelect = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Filter Your Criteria"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Gender",
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: Row(
              children: <Widget>[
                Radio(
                    value: 'Male',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                      });
                    }),
                Text("Male", style: TextStyle(fontSize: 13)),
                Radio(
                    value: 'Female',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                      });
                    }),
                Text("Female", style: TextStyle(fontSize: 13))
              ],
            ),
          ),
          Text(
            "Residential Type",
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600),
          ),
          Row(
            children: <Widget>[
              Checkbox(
                  activeColor: Colors.green,
                  value: ownedSelect,
                  onChanged: (bool value) {
                    setState(() {
                      ownedSelect = value;
                    });
                  }),
              Text(
                "Owned",
                style: TextStyle(fontSize: 13),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Checkbox(
                  activeColor: Colors.green,
                  value: rentedSelect,
                  onChanged: (bool value) {
                    setState(() {
                      rentedSelect = value;
                    });
                  }),
              Text(
                "Rented",
                style: TextStyle(fontSize: 13),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Checkbox(
                  activeColor: Colors.green,
                  value: ownerSelect,
                  onChanged: (bool value) {
                    setState(() {
                      ownerSelect = value;
                    });
                  }),
              Text(
                "Owner",
                style: TextStyle(fontSize: 13),
              )
            ],
          ),
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
        ),
        FlatButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onSelect(_gender, ownedSelect, ownerSelect, rentedSelect);
          },
          child: Text("Done"),
        )
      ],
    );
  }
}
