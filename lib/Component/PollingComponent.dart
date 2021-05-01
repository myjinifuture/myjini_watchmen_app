import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:smartsocietystaff/Common/Constants.dart' as cnst;

class PollingComponent extends StatefulWidget {
  var _pollingData;
  int index;

  PollingComponent(this._pollingData, this.index);

  @override
  _PollingComponentState createState() => _PollingComponentState();
}

class _PollingComponentState extends State<PollingComponent> {
  int touchedIndex;

  List<Color> colors = [
    Color(0xff00A6A6),
    Color(0xff3D405B),
    Color(0xff7EB2DD),
    Color(0xff81B29A)
  ];

  List<PieChartSectionData> showingSections() {
    return List.generate(widget._pollingData["PollingOptionCountList"].length,
        (i) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 25 : 16;
      final double fontSizeForZero = isTouched ? 18 : 12;
      final double radius = isTouched ? 60 : 50;
      return widget._pollingData["PollingOptionCountList"][i]["Count"]
                  .toString() !=
              '0.0'
          ? PieChartSectionData(
              color: colors[i],
              value: widget._pollingData["PollingOptionCountList"][i]["Count"],
              title:
                  '${widget._pollingData["PollingOptionCountList"][i]["Count"]}%',
              radius: radius,
              titleStyle: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xffffffff)),
            )
          : PieChartSectionData(
              color: colors[i],
              title:
                  '${widget._pollingData["PollingOptionCountList"][i]["Count"]}%',
              radius: radius,
              titleStyle: TextStyle(
                  fontSize: fontSizeForZero,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xffffffff)),
            );
    });
  }

  List<Widget> chartData() {
    return List.generate(widget._pollingData["PollingOptionCountList"].length,
        (i) {
      return Indicator(
        color: colors[i], // colors[i],
        text: '${widget._pollingData["PollingOptionCountList"][i]["Title"]}',
        isSquare: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimationConfiguration.staggeredList(
      position: widget.index,
      duration: const Duration(milliseconds: 450),
      child: FlipAnimation(
        //verticalOffset: 50.0,
        delay: Duration(milliseconds: 350),
        flipAxis: FlipAxis.x,
        child: FadeInAnimation(
          child: Card(
            elevation: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        "images/question.png",
                        width: 15,
                        height: 15,
                        color: Colors.grey,
                      ),
                      Padding(padding: EdgeInsets.only(left: 8)),
                      Expanded(
                        child: Text(
                          "${widget._pollingData["PollingData"]["Title"]}",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: cnst.appPrimaryMaterialColor),
                        ),
                      ),
                    ],
                  ),
                ),
                widget._pollingData["PollingOptionCountList"].length > 0
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          SizedBox(
                            height: 160,
                            width: 160,
                            child: PieChart(
                              PieChartData(
                                  pieTouchData: PieTouchData(
                                      touchCallback: (pieTouchResponse) {
                                    setState(() {
                                      if (pieTouchResponse.touchInput
                                              is FlLongPressEnd ||
                                          pieTouchResponse.touchInput
                                              is FlPanEnd) {
                                        touchedIndex = -1;
                                      } else {
                                        touchedIndex = pieTouchResponse
                                            .touchedSectionIndex;
                                      }
                                    });
                                  }),
                                  borderData: FlBorderData(
                                    show: false,
                                  ),
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 20,
                                  sections: showingSections()),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            padding: EdgeInsets.all(10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: chartData()),
                          ),
                        ],
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const Indicator({
    Key key,
    this.color,
    this.text,
    this.isSquare,
    this.size = 13,
    this.textColor = const Color(0xff505050),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
        )
      ],
    );
  }
}
