import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter_multiple_image_picker/flutter_multiple_image_picker.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/LoadingComponent.dart';

class AddEvent extends StatefulWidget {
  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  TextEditingController txtTitle = new TextEditingController();
  File _imageEvent;
  String societyId = "0";

  DateTime _dateTime;
  String _platformMessage = 'No Error';
  List images;
  int maxImageNo = 10;
  bool selectSingleImage = false;

  String _fileName;
  String _path;

  @override
  void initState() {
    _dateTime = DateTime.now();
  }

  String _format = 'yyyy-MMMM-dd';
  DateTimePickerLocale _locale = DateTimePickerLocale.en_us;
  bool isLoading = false;

  void _showDatePicker() {
    DatePicker.showDatePicker(
      context,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
        confirm: Text('Done', style: TextStyle(color: Colors.red)),
        cancel: Text('cancel', style: TextStyle(color: Colors.cyan)),
      ),
      initialDateTime: DateTime.now(),
      dateFormat: _format,
      locale: _locale,
      onClose: () => print("----- onClose -----"),
      onCancel: () => print('onCancel'),
      onChange: (dateTime, List<int> index) {
        setState(() {
          _dateTime = dateTime;
        });
      },
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          _dateTime = dateTime;
        });
      },
    );
  }

  _addEvent() async {
    if (txtTitle.text != "") {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          String SocietyId = preferences.getString(Session.SocietyId);
          String filename = "";
          String filePath = "";
          File compressedFile;
          setState(() {
            isLoading = true;
          });

          if (_imageEvent != null) {
            ImageProperties properties =
                await FlutterNativeImage.getImageProperties(_imageEvent.path);

            compressedFile = await FlutterNativeImage.compressImage(
              _imageEvent.path,
              quality: 80,
              targetWidth: 600,
              targetHeight:
                  (properties.height * 600 / properties.width).round(),
            );

            filename = _imageEvent.path.split('/').last;
            filePath = compressedFile.path;
          } else if (_path != null && _path != '') {
            filePath = _path;
            filename = _fileName;
          }

          FormData formData = new FormData.fromMap({
            "Id": 0,
            "SocietyId": SocietyId,
            "Image ": (filePath != null && filePath != '')
                ? await MultipartFile.fromFile(filePath,
                    filename: filename.toString())
                : null,
            "Title": txtTitle.text,
            "Date": _dateTime.toString(),
          });

          Services.AddEvent(formData).then((data) async {
            if (data.Data != "0" && data.IsSuccess == true) {
              setState(() {
                isLoading = false;
              });
              Fluttertoast.showToast(
                  msg: "Event Added Successfully",
                  backgroundColor: Colors.green,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.white);
              Navigator.pushReplacementNamed(context, "/Events");
            } else {
              setState(() {
                isLoading = false;
              });
              showMsg(data.Message, title: "Error");
            }
          }, onError: (e) {
            setState(() {
              isLoading = false;
            });
            showMsg("Try Again.");
          });
        }
      } on SocketException catch (_) {
        showMsg("No Internet Connection.");
      }
    } else
      Fluttertoast.showToast(
          msg: "Please Enter Event Name",
          backgroundColor: Colors.red,
          gravity: ToastGravity.TOP,
          textColor: Colors.white);
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
      appBar: AppBar(
        title: Text("Add Event",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/Events');
          },
        ),
      ),
      body: WillPopScope(
        onWillPop: () {
          Navigator.pushReplacementNamed(context, '/Events');
        },
        child: isLoading
            ? LoadingComponent()
            : SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 20),
                  child: Column(
                    children: <Widget>[
                      SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(bottom: 10),
                              child: TextFormField(
                                controller: txtTitle,
                                scrollPadding: EdgeInsets.all(0),
                                decoration: InputDecoration(
                                    border: new OutlineInputBorder(
                                        borderSide:
                                            new BorderSide(color: Colors.black),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    prefixIcon: Icon(
                                      Icons.title,
                                      //color: cnst.appPrimaryMaterialColor,
                                    ),
                                    hintText: "Title"),
                                keyboardType: TextInputType.text,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _showDatePicker();
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.all(15),
                                margin: EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.grey),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.calendar_today,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: Text(
                                        "${_dateTime.toString().substring(8, 10)}-${_dateTime.toString().substring(5, 7)}-${_dateTime.toString().substring(0, 4)}",
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    _imagePopup(context);
                                  },
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      height: 50,
                                      padding:
                                          EdgeInsets.only(left: 7, right: 7),
                                      decoration: BoxDecoration(
                                        color: appPrimaryMaterialColor[700],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Icon(
                                            Icons.camera_alt,
                                            size: 25,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            "Select Event Photo",
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(padding: EdgeInsets.only(left: 20)),
                                _imageEvent != null
                                    ? Padding(
                                        padding: EdgeInsets.only(top: 10),
                                        child: Image.file(
                                          File(_imageEvent.path),
                                          height: 160,
                                          width: 130,
                                          fit: BoxFit.fill,
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: RaisedButton(
                                onPressed: () {
                                  _addEvent();
                                },
                                color: appPrimaryMaterialColor[700],
                                textColor: Colors.white,
                                shape: StadiumBorder(),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.save,
                                      size: 30,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10),
                                      child: Text(
                                        "Save Event",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 15)),
                      images != null
                          ? SizedBox(
                              height: 300.0,
                              width: 400.0,
                              child: new ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemBuilder:
                                    (BuildContext context, int index) =>
                                        new Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: new Image.file(
                                    new File(images[index].toString()),
                                  ),
                                ),
                                itemCount: images.length,
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void _imagePopup(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.camera_alt),
                    title: new Text('Camera'),
                    onTap: () async {
                      var image = await ImagePicker.pickImage(
                        source: ImageSource.camera,
                      );
                      if (image != null)
                        setState(() {
                          _path = '';
                          _fileName = '';
                          _imageEvent = image;
                        });
                      Navigator.pop(context);
                    }),
                new ListTile(
                    leading: new Icon(Icons.photo),
                    title: new Text('Gallery'),
                    onTap: () async {
                      var image = await ImagePicker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null)
                        setState(() {
                          _path = '';
                          _fileName = '';
                          _imageEvent = image;
                        });
                      Navigator.pop(context);
                    }),
              ],
            ),
          );
        });
  }
}
