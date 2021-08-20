import 'package:flutter/material.dart';


class FlateNoComponent extends StatefulWidget {
  @override
  _FlateNoComponentState createState() => _FlateNoComponentState();
}

class _FlateNoComponentState extends State<FlateNoComponent> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
      },

      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Card(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("102",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
