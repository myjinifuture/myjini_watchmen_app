import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multiple_image_picker/flutter_multiple_image_picker.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smartsocietystaff/Common/Constants.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Component/LoadingComponent.dart';
import 'package:smartsocietystaff/Screens/EventGallary.dart';

class AddEventGallary extends StatefulWidget {
  String eventId;

  AddEventGallary(this.eventId);

  @override
  _AddEventGallaryState createState() => _AddEventGallaryState();
}

class _AddEventGallaryState extends State<AddEventGallary> {
  String _platformMessage = 'No Error';
  List images;
  int maxImageNo = 20;
  bool selectSingleImage = false, isLoading = false;
  FormData formData;
  List tempImages = [];

  initMultiPickUp() async {
    setState(() {
      _platformMessage = 'No Error';
    });
    List resultList;
    String error;
    try {
      resultList = await FlutterMultipleImagePicker.pickMultiImages(
          maxImageNo, selectSingleImage);
    } on PlatformException catch (e) {
      error = e.message;
    }

    if (!mounted) return;

    setState(() {
      images = resultList;
      if (error == null) _platformMessage = 'No Error Dectected';
    });

    print("image collection:" + images.toString());
  }

  _addEventPhotos() async {
    if (images != null && images.length > 0) {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          String filename = "";
          String filePath = "";
          File compressedFile;

          setState(() {
            isLoading = true;
          });

          var data = {
            "Id": 0,
            "EventId": widget.eventId,
          };

          for (int i = 0; i < images.length; i++) {
            File _imageEvent = new File(images[i].toString());
            if (_imageEvent != null) {
              print("path->>" + _imageEvent.path.toString());
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

              data["Image${i + 1}"] = (filePath != null && filePath != '')
                  ? await MultipartFile.fromFile(filePath,
                      filename: filename.toString())
                  : null;
            }
          }

          print("final Data" + data.toString());

          formData = new FormData.fromMap(data);

          Services.AddEventGallary(formData).then((data) async {
            if (data.Data != "0" && data.IsSuccess == true) {
              setState(() {
                isLoading = false;
              });
              Fluttertoast.showToast(
                  msg: "Photos Added Successfully",
                  backgroundColor: Colors.green,
                  gravity: ToastGravity.TOP,
                  textColor: Colors.white);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EventGallary(
                            eventId: "${widget.eventId}",
                          )));
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
          msg: "Please Select Any Image",
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
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => EventGallary(
                      eventId: "${widget.eventId}",
                    )));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Add Event Photos",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EventGallary(
                            eventId: "${widget.eventId}",
                          )));
            },
          ),
        ),
        body: isLoading
            ? LoadingComponent()
            : Container(
                padding: EdgeInsets.only(top: 13),
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        initMultiPickUp();
                      },
                      child: Container(
                        height: 50,
                        width: 200,
                        decoration: BoxDecoration(
                          color: appPrimaryMaterialColor[700],
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    Padding(padding: EdgeInsets.only(top: 15)),
                    images != null
                        ? SizedBox(
                            height: 300.0,
                            width: 400.0,
                            child: new ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) =>
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
                    Padding(
                      padding: EdgeInsets.only(top: 15),
                      child: RaisedButton(
                        onPressed: () {
                          _addEventPhotos();
                        },
                        color: appPrimaryMaterialColor[700],
                        textColor: Colors.white,
                        shape: StadiumBorder(),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                                "Save Photos",
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
      ),
    );
  }
}
