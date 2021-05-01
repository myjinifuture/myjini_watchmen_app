import 'package:flutter/material.dart';

class freqVisitorComponent extends StatefulWidget {
  @override
  _freqVisitorComponentState createState() =>
      _freqVisitorComponentState();
}

class _freqVisitorComponentState extends State<freqVisitorComponent> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top:8.0,left: 8.0,bottom: 8.0),
            child: ClipOval(
                child: FadeInImage.assetNetwork(
                    placeholder: 'images/Logo.png',
                    image:
                    "https://i1.rgstatic.net/ii/profile.image/279689487765507-1443694578350_Q512/Sahin_Ahmed.jpg",
                    width: 50,
                    height: 50,
                    fit: BoxFit.fill)
                   ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: Text(
                  "Keval Mangroliya",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text("Amazon Delivery"),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text("GJ-05-KP-4187"),
              )
            ],
          ),
          IconButton(icon: Icon(Icons.call,color: Colors.green,), onPressed: (){}),
         Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: <Widget>[
             Padding(
               padding: const EdgeInsets.only(top:8.0),
               child: Text("12 Min"),
             ),
             Padding(
               padding: const EdgeInsets.all(6.0),
               child: Container(
                 height: 50,
                 width: 50,
                 decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.all(Radius.circular(8.0)),
                     border: Border.all(width: 2,color: Colors.red)
                 ),
                 child: Center(
                   child: Text("OUT",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: Colors.red),),
                 ),
               ),
             )
           ],
         )
        ],
      ),
    );
  }
}
