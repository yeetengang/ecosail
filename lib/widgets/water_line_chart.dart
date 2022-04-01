import 'dart:math';

import 'package:ecosail/others/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/extensions/color_extension.dart';
import 'package:fl_chart/src/utils/lerp.dart';
import 'package:fl_chart/src/utils/utils.dart';
import 'package:fl_chart/src/chart/line_chart/line_chart_helper.dart';
import 'package:flutter/material.dart';

class WaterLineChart2 extends StatefulWidget {
  final List<double> dataList;
  final String title;
  final double reservedSize;
  final int barSize;

  final List<String> xAxisLabels = const [
    'Data 1', 'Data 2', 'Data 3', 'Data 4', 'Data 5', 'Data 6', 'Data 7',
  ];
  
  const WaterLineChart2({ 
    Key? key, 
    required this.dataList, 
    required this.title, 
    required this.reservedSize,
    required this.barSize,
  }) : super(key: key);

  @override
  _WaterLineChart2State createState() => _WaterLineChart2State();
}

class _WaterLineChart2State extends State<WaterLineChart2> {
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
                    padding: const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 15.0),
                    child: LineChart(
                      mainLineData(
                        widget.dataList.reduce(max).ceilToDouble(),
                        widget.dataList.reduce(min).floorToDouble(),
                      ),
                    )
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LineChartData mainLineData(double yMax, double yMin) {
    if ((yMax - yMin) < 1.3 && yMax != yMin) {
      yMax = yMax + 1;
    } else if (yMax == yMin) {
      yMax = yMax + 1;
      yMin = yMin - 5;
    }

    return LineChartData(
      minX: 0,
      maxX: widget.barSize.toDouble(), //Number of Days extra to left some space between
      maxY: yMax,
      minY: yMin,
      lineTouchData: LineTouchData(
        touchSpotThreshold: 5.0, //Touch Area Size
        handleBuiltInTouches: true,
        getTouchedSpotIndicator: lineTouchedIndicators,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.white.withOpacity(0.8),
        ),
      ),
      gridData: FlGridData(
        show: true,
        checkToShowHorizontalLine: (value) => value % value == 0,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.black12,
          strokeWidth: 1.0,
          dashArray: [5],
        ),
        getDrawingVerticalLine: (value) => FlLine(
          strokeWidth: 0.0
        ),
      ),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          //reservedSize: 20, //X Axis Label reserved Size
          margin: 10, //X Axis Label and Label Line margin
          interval: 1, //X Axis label interval
          getTextStyles: (context, value) => const TextStyle(
            color: Colors.grey,
            fontSize: 12.0,
            fontWeight: FontWeight.w500
          ),
          rotateAngle: 30.0,
          getTitles: (value) {
            // Display of x Axis
            print(widget.dataList.length);
            if (value != 0) {
              if (widget.dataList.length == 60) {
                if (value == 10 || value == 20 || value == 30 || value == 40 || value == 50 || value == 60) {
                  return 'Data ' + value.toInt().toString(); 
                }
              } else if (widget.dataList.length == 33 || widget.dataList.length == 46) {
                if (value%5 == 0) {
                  return 'Data ' + value.toInt().toString(); 
                }
              } else if (widget.dataList.length == 20) {
                if (value%2 == 0) {
                  return 'Data ' + value.toInt().toString(); 
                }
              } else if (widget.dataList.length <= 20) {
                return 'Data ' + value.toInt().toString();
              }
            }
            /*if (value != 0 && value != 8) {
              return 'Data ' + value.toInt().toString();
            }*/
            return '';
          },
        ),
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        leftTitles: _getLeftTitles(
          getTitles: (value) {
            return value.toStringAsFixed(1);
          },
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      lineBarsData: [
        LineChartBarData(
          isCurved: false,
          colors: [Colors.blue], //Multiple child can turn to gradient
          barWidth: 2,
          isStrokeCapRound: false,
          dotData: FlDotData(
            show: true, 
            getDotPainter: (FlSpot spot, double xPercentage, LineChartBarData bar, int index, {size = 2.0}) =>
              FlDotCirclePainter(
                radius: size,
                color: _defaultGetDotColor(spot, xPercentage, bar),
                strokeColor: _defaultGetDotStrokeColor(spot, xPercentage, bar),
              )
            ,
          ),
          belowBarData: BarAreaData(show: false),
          spots: _getCoordinates(),
        ),
      ],
    );
  }

  List<FlSpot> _getCoordinates() => List.generate(widget.dataList.length, (i) {
    return FlSpot(i.toDouble() + 1, widget.dataList[i]);
  });

  SideTitles _getLeftTitles({required GetTitleFunction getTitles}) => SideTitles(
    getTitles: getTitles,
    showTitles: true,
    margin: 10.0,
    reservedSize: widget.reservedSize,
    getTextStyles: (context, value) => const TextStyle(
      color: Colors.grey,
      fontSize: 12.0,
      fontWeight: FontWeight.w500
    ),
  );
}

List<TouchedSpotIndicatorData> lineTouchedIndicators(
    LineChartBarData barData, List<int> indicators) {
  return indicators.map((int index) {
    /// Indicator Line
    var lineColor = barData.colors[0];
    if (barData.dotData.show) {
      lineColor = _defaultGetDotColor(barData.spots[index], 0, barData);
    }
    const lineStrokeWidth = 2.0;
    final flLine = FlLine(color: lineColor, strokeWidth: lineStrokeWidth);

    var dotSize = 10.0;
    if (barData.dotData.show) {
      dotSize = 4.0 * 1.8;
    }

    final dotData = FlDotData(
        getDotPainter: (spot, percent, bar, index) =>
            _defaultGetDotPainter(spot, percent, bar, index, size: dotSize));

    return TouchedSpotIndicatorData(flLine, dotData);
  }).toList();
}

Color _defaultGetDotColor(FlSpot _, double xPercentage, LineChartBarData bar) {
  if (bar.colors.isEmpty) {
    throw ArgumentError('"colors" is empty.');
  } else if (bar.colors.length == 1) {
    return bar.colors[0];
  } else {
    return lerpGradient(bar.colors, bar.getSafeColorStops(), xPercentage / 100);
  }
}

FlDotPainter _defaultGetDotPainter(
    FlSpot spot, double xPercentage, LineChartBarData bar, int index,
    {double? size}) {
  return FlDotCirclePainter(
    radius: size,
    color: _defaultGetDotColor(spot, xPercentage, bar),
    strokeColor: _defaultGetDotStrokeColor(spot, xPercentage, bar),
  );
}

FlDotPainter _getDotPainter(
    FlSpot spot, double xPercentage, LineChartBarData bar, int index,
    {double? size}) {
  return FlDotCirclePainter(
    radius: 2.0,
    color: _defaultGetDotColor(spot, xPercentage, bar),
    strokeColor: _defaultGetDotStrokeColor(spot, xPercentage, bar),
  );
}

Color _defaultGetDotStrokeColor(
    FlSpot spot, double xPercentage, LineChartBarData bar) {
  Color color;
  if (bar.colors.isEmpty) {
    throw ArgumentError('"colors" is empty.');
  } else if (bar.colors.length == 1) {
    color = bar.colors[0];
  } else {
    color =
        lerpGradient(bar.colors, bar.getSafeColorStops(), xPercentage / 100);
  }
  return color.darken();
}