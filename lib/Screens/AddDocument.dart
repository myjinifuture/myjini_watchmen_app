import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartsocietystaff/Common/Services.dart';
import 'package:smartsocietystaff/Common/Constants.dart';

ProgressDialog pr;

class AddDocument extends StatefulWidget {
  @override
  _AddDocumentState createState() => _AddDocumentState();
}

class _AddDocumentState extends State<AddDocument> {
  TextEditingController txtTitle = new TextEditingController();
  TextEditingController txtDate = new TextEditingController();
  String societyId = "0";

  DateTimePickerLocale _locale = DateTimePickerLocale.en_us;

  String _format = 'yyyy-MMMM-dd';
  TextEditingController _formatCtrl = TextEditingController();

  DateTime _dateTime;

  String _fileName;
  String _path;
  bool _loadingPath = false;
  bool _hasValidMime = false;
  FileType _pickingType = FileType.any;

  @override
  void initState() {
    super.initState();
    getLocalData();
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
        //_fileName = _path != null ? _path : '';
        _fileName = _path != null ? _path.split('/').last : '';
      });
    }
  }

  addDocument() async {
    if (txtTitle.text != null &&
        txtTitle.text != '' &&
        _dateTime != null &&
        _dateTime != '' &&
        _path != null &&
        _path != '') {
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          // pr.show();

          String filePath = _path;
          String filename = _fileName;

          FormData formData = new FormData.fromMap({
            "Id": 0,
            "Title": txtTitle.text,
            "Date": _dateTime.toString(),
            "SocietyId": societyId,
            "File": (filePath != null && filePath != '')
                ? await MultipartFile.fromFile(filePath,
                    filename: filename.toString())
                : null
          });

          Services.SaveDocument(formData).then((data) async {
            // pr.hide();
            if (data.Data != "0" && data.IsSuccess == true) {
              Fluttertoast.showToast(msg: "Document Added SuccessFully");
              Navigator.pushReplacementNamed(context, '/Document');
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
        title: Text("Add Document",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
        leading: GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, '/Document');
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () {
          Navigator.pushReplacementNamed(context, '/Document');
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
                              size: 30,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                "Upload File",
                                style: TextStyle(
                                  fontSize: 18,
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
                _fileName != null && _fileName != ''
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
                      addDocument();
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
                            "Save Document",
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
}
