import 'dart:math';
import 'package:ecosail/others/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WaterBarChart extends StatefulWidget {
  final List<double> dataList;
  final List<String> dataTime;
  final List<String> dateTimeList;
  final String title;
  final double reservedSize;
  final double barSize;

  const WaterBarChart({
    required this.dataList, 
    required this.dataTime,
    required this.dateTimeList,
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
            padding: const EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom:  15.0, top: 5.0),
                  child: Text(
                    widget.dateTimeList[0] + " - " + widget.dateTimeList.last,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
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
      bool isLabel = false,
      Color barColor = Colors.blue,
      List<int> showTooltips = const [],
    }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: isTouched ? y : y,
          //colors: isTouched? [Colors.lightBlue.shade200] : [barColor],
          colors: isLabel && !isTouched? [AppColors.pageBackground] // If it is a %5 label and that label is not touched
          : isLabel && isTouched? [AppColors.pageBackground.withOpacity(0.8)] 
          : !isLabel && !isTouched? [barColor]:[Colors.lightBlue.shade200],
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
    bool checking = (i + 1)%5==0;
    if (widget.dataList.length == 7) {
      checking = false;
    }
    return makeGroupData(i, widget.dataList[i], widget.barSize, isTouched: i == touchedIndex, isLabel: checking);
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
                  fontSize: 12.0,
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
            fontSize: 12.0,
            fontWeight: FontWeight.w500
          ),
          rotateAngle: 30.0,
          getTitles: (double value) {
            // Display of x Axis
              if (widget.dataList.length == 33 || widget.dataList.length == 46 || widget.dataList.length == 60 || widget.dataList.length == 20) {
                if ((value + 1)%5 == 0) {
                  if (value.toInt() < widget.dataList.length) {
                    return widget.dataTime[value.toInt()];
                  }
                }
              } else if (widget.dataList.length <= 20) {
                if (value.toInt() < widget.dataList.length) {
                  return widget.dataTime[value.toInt()];
                }
              }
            return '';
          },
        ),
        leftTitles: SideTitles(
          margin: 10.0,
          reservedSize: widget.reservedSize,
          showTitles: true,
          getTextStyles: (context, value) => const TextStyle(
            color: Colors.grey,
            fontSize: 12.0,
            fontWeight: FontWeight.w500
          ),
          getTitles: (value) {
            return value.toStringAsFixed(1);
          }
        ),
      ),
      borderData: yMax <=0.0? FlBorderData(
        show: true,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
          left: BorderSide(color: Theme.of(context).dividerColor),
        )
      ): FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
          left: BorderSide(color: Theme.of(context).dividerColor),
        )
      ),
      barGroups: showingGroups(),
      gridData: FlGridData(
        show: true,
        checkToShowHorizontalLine: (value) => value % value == 0, //? value % 5 == 0 | value % value == 0 | ((value - value.truncate()) * 10).toInt() % 2 == 0
        getDrawingHorizontalLine: (value) { 
          return FlLine(
          color: Colors.black12,
          strokeWidth: 1.0,
          dashArray: [5],
          );
        },
        getDrawingVerticalLine: (value) => FlLine(
          strokeWidth: 0.0,
        ),
      ),
    );
  }
}