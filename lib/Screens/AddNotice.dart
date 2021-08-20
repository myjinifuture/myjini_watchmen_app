import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Common/Constants.dart';

ProgressDialog pr;

class AddNotice extends StatefulWidget {
  @override
  _AddNoticeState createState() => _AddNoticeState();
}

class _AddNoticeState extends State<AddNotice> {
  TextEditingController txtTitle = new TextEditingController();
  TextEditingController txtDescription = new TextEditingController();
  File _imageNotice;
  String societyId = "0";

  DateTimePickerLocale _locale = DateTimePickerLocale.en_us;
  List<DateTimePickerLocale> _locales = DateTimePickerLocale.values;

  String _format = 'yyyy-MMMM-dd';
  TextEditingController _formatCtrl = TextEditingController();

  DateTime _dateTime;
  bool isLoading = false;

  String _fileName;
  String _path;
  bool _loadingPath = false;
  bool _hasValidMime = false;
  FileType _pickingType = FileType.any;

  @override
  void initState() {
    super.initState();
    getLocalData();
    setData();
    pr = new ProgressDialog(context, type: ProgressDialogType.Normal);
    pr.style(
        message: "Please Wait",
        borderRadius: 10.0,
        progressWidget: Container(
          padding: EdgeInsets.all(15),
          child: CircularProgressIndicator(
            //backgroundColor: cnst.appPrimaryMaterialColor,
          ),
        ),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut,
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 17.0, fontWeight: FontWeight.w600));
    _dateTime = DateTime.now();
  }

  getLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      societyId = prefs.getString(Session.SocietyId);
    });
  }

  setData() {
    setState(() {
      txtTitle.text = "";
      txtDescription.text = "";
    });
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

  void _openFileExplorer() async {
    if (_pickingType != FileType.custom || _hasValidMime) {
      setState(() => _loadingPath = true);
      try {
        _path = await FilePicker.getFilePath(
          type: _pickingType,
        );
      } on PlatformException catch (e) {
        print("Unsupported operation" + e.toString());
      }
      if (!mounted) return;
      setState(() {
        _loadingPath = false;
        _imageNotice = null;
        _fileName = _path != null ? _path.split('/').last : '';
      });
    }
  }

  addNotice() async {
    if (txtTitle.text != null &&
        txtTitle.text != '' &&
        txtDescription.text != null &&
        txtDescription.text != '' &&
        _dateTime != null &&
        _dateTime != '') {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          // pr.show();

          String filename = "";
          String filePath = "";
          File compressedFile;

          if (_imageNotice != null) {
            ImageProperties properties =
                await FlutterNativeImage.getImageProperties(_imageNotice.path);

            compressedFile = await FlutterNativeImage.compressImage(
              _imageNotice.path,
              quality: 80,
              targetWidth: 600,
              targetHeight:
                  (properties.height * 600 / properties.width).round(),
            );

            filename = _imageNotice.path.split('/').last;
            filePath = compressedFile.path;
          } else if (_path != null && _path != '') {
            filePath = _path;
            filename = _fileName;
          }

          FormData formData = new FormData.fromMap({
            "Id": 0,
            "Title": txtTitle.text,
            "Description": txtDescription.text,
            "Date": _dateTime.toString(),
            "SocietyId": societyId,
            "File": (filePath != null && filePath != '')
                ? await MultipartFile.fromFile(filePath,
                    filename: filename.toString())
                : null
          });

          Services.SaveNotice(formData).then((data) async {
            // pr.hide();

            if (data.Data != "0" && data.IsSuccess == true) {
              Navigator.pushReplacementNamed(context, "/Notice");
              //showMsg("Notice Saved Successfully", title: "Success");
            } else {
              showMsg(data.Message, title: "Error");
            }
          }, onError: (e) {
            // pr.hide();
            showMsg("Try Again.");
          });
        }
      } on SocketException catch (_) {
        // pr.hide();
        showMsg("No Internet Connection.");
      }
    } else {
      showMsg("Please Fill All Data.", title: "Alert !");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Notice',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/Notice');
          },
        ),
      ),
      body: WillPopScope(
        onWillPop: () {
          Navigator.pushReplacementNamed(context, '/Notice');
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(left: 15, right: 15, top: 20),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    controller: txtTitle,
                    scrollPadding: EdgeInsets.all(0),
                    decoration: InputDecoration(
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.black),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        prefixIcon: Icon(
                          Icons.title,
                          //color: cnst.appPrimaryMaterialColor,
                        ),
                        hintText: "Title"),
                    keyboardType: TextInputType.text,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: TextFormField(
                    controller: txtDescription,
                    scrollPadding: EdgeInsets.all(0),
                    decoration: InputDecoration(
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.black),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        prefixIcon: Icon(
                          Icons.description,
                          //color: cnst.appPrimaryMaterialColor,
                        ),
                        hintText: "Description"),
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
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
                        border: Border.all(width: 1, color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Flexible(
                      flex: 1,
                      child: RaisedButton(
                        onPressed: () {
                          _imagePopup(context);
                        },
                        color: appPrimaryMaterialColor[700],
                        textColor: Colors.white,
                        shape: StadiumBorder(),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child:Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.camera_alt,
                              size: 25,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  "Upload Image",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Flexible(
                      flex: 1,
                      child: RaisedButton(
                        onPressed: () {
                          _openFileExplorer();
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
                              Icons.file_upload,
                              size: 25,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  "Upload File",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                _imageNotice != null
                    ? Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Image.file(
                          File(_imageNotice.path),
                          height: 150,
                          fit: BoxFit.fitHeight,
                        ),
                      )
                    : _fileName != null && _fileName != ''
                        ? Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              "${_fileName}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : Container(),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: RaisedButton(
                    onPressed: () {
                      addNotice();
                    },
                    color: appPrimaryMaterialColor[700],
                    textColor: Colors.white,
                    shape: StadiumBorder(),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                            "Save Notice",
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
                          _imageNotice = image;
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
                          _imageNotice = image;
                        });
                      Navigator.pop(context);
                    }),
              ],
            ),
          );
        });
  }
}
