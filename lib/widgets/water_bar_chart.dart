import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WaterBarChart extends StatefulWidget {
  final List<double> dataList;
  final String title;
  final double reservedSize;
  final double barSize;

  const WaterBarChart({
    required this.dataList, 
    required this.title,
    required this.reservedSize,
    required this.barSize,
  });

  @override
  State<StatefulWidget> createState() => WaterBarChartState();
}

class WaterBarChartState extends State<WaterBarChart> {
  final Duration animDuration = const Duration(milliseconds: 250);
  int touchedIndex = -1;
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(bottom:  15.0),
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0), //Change the chart left right padding
                    child: BarChart(
                      mainBarData(
                        widget.dataList.reduce(max).ceilToDouble(),
                        widget.dataList.reduce(min).floorToDouble(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y,
    double size, {
      bool isTouched = false,
      Color barColor = Colors.blue,
      List<int> showTooltips = const [],
    }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: isTouched ? y : y,
          colors: isTouched ? [Colors.lightBlue.shade200] : [barColor],
          width: size,
          borderSide: const BorderSide(width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            y: 0, //White Rod at the back of rod data shown
            colors: [Colors.white],
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(widget.dataList.length, (i) {
    return makeGroupData(i, widget.dataList[i], widget.barSize, isTouched: i == touchedIndex);
  });

  BarChartData mainBarData(double yMax, double yMin) {
    
    //To avoid the graph y axis top value too low
    if ((yMax - yMin) < 1.3 && yMax != yMin) {
      yMax = yMax + 1;
    } else if (yMax == yMin) {
      yMax = yMax + 1;
      yMin = yMin - 5;
    }

    return BarChartData(
      maxY: yMax,
      minY: yMin,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.transparent,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              //String label;
              //label = widget.xAxisLabels[group.x.toInt()]; //Convert x axis to label
              return BarTooltipItem(
                rod.y.toString(),
                const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              );
            }),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        topTitles: SideTitles(showTitles: false),
        rightTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          margin: 10.0,
          showTitles: true,
          getTextStyles: (context, value) => const TextStyle(
            color: Colors.grey,
            fontSize: 14.0,
            fontWeight: FontWeight.w500
          ),
          rotateAngle: 30.0,
          getTitles: (double value) {
            return 'Day ' + value.toInt().toString();
          },
        ),
        leftTitles: SideTitles(
          margin: 10.0,
          reservedSize: widget.reservedSize,
          showTitles: true,
          getTextStyles: (context, value) => const TextStyle(
            color: Colors.grey,
            fontSize: 14.0,
            fontWeight: FontWeight.w500
          ),
          getTitles: (value) {
            //Adjust range of y-axis here
            //print((value - value.truncate()).toStringAsFixed(1));
            //print(value);
            /*if (value == yMax) {
              return yMax.toString();
            } else if(((value - value.truncate()) * 10).toInt() % 2 == 0) {
              return value.toStringAsFixed(1);
            }
            return '';*/
            return value.toStringAsFixed(1);
            /*if (value == 0) {
              return '0';
            } 
            else if (value % 5 == 0) {
              return '${value ~/ 5 * 5}';
            }
            return '';*/
          }
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
      gridData: FlGridData(
        show: true,
        checkToShowHorizontalLine: (value) => value % value == 0, //? value % 5 == 0 | value % value == 0 | ((value - value.truncate()) * 10).toInt() % 2 == 0
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.black12,
          strokeWidth: 1.0,
          dashArray: [5],
        ),
        getDrawingVerticalLine: (value) => FlLine(
          strokeWidth: 0.0
        ),
      ),
    );
  }
}