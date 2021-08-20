import 'package:flutter/material.dart';
import 'package:smartsocietystaff/Common/Constants.dart';

class ImageComponent extends StatefulWidget {
  String networkImage,memberName;

  ImageComponent(this.networkImage,this.memberName);

  @override
  _ImageComponentState createState() => _ImageComponentState();
}

class _ImageComponentState extends State<ImageComponent> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: widget.networkImage != '' &&
          widget.networkImage != null ? Image.network(
        IMG_URL + widget.networkImage,
        fit: BoxFit.cover,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
      ) : Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: appPrimaryMaterialColor,
        ),
        child: Center(
          child: Text(
            widget.memberName,
            style: TextStyle(
                fontSize: 25, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
