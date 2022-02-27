import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecosail/widgets/water_line_chart.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:ecosail/gateway.dart';
import 'package:ecosail/others/colors.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:ecosail/widgets/water_bar_chart.dart';
import 'package:flutter/material.dart';

class ChartsPage extends StatefulWidget {
  final List<Data> dataList;

  const ChartsPage({required this.dataList});

  @override
  _ChartsPageState createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  List<String> parameters = ['Temperature', 'Turbidity', 'pH', 'Electrical Conductivity', 'Dissolved Oxygen'];
  List<bool> _selected = [false, true];
  CarouselController sliderController = CarouselController();
  int activeIndex = 0;
  double _currentSliderValue = 7;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: <Widget>[
          _buildHeader(),
          _buildBody(screenSize.height, screenSize.width),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0, bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppLargeText(text: 'Charts', color: Colors.blue.shade100,size: 26,),
            Text('Historical Data', style: TextStyle(height: 1.6, color: Colors.grey[300], fontWeight: FontWeight.w500),),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildBody(double screenHeight, double screenWidth) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: screenWidth * 0.9,
            height: screenHeight * 0.075,
            child: Slider(
              value: _currentSliderValue,
              min: 7,
              max: 60,
              divisions: 4,
              activeColor: AppColors.btnColor2,
              inactiveColor: AppColors.mainColor,
              label: _currentSliderValue.round().toString() + ' days',
              onChanged: (double value) {
                setState(() {
                  _currentSliderValue = value;
                });
              },
            ),
          ), 
          Container(
            height: screenHeight * 0.625,
            width: screenWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0), 
                topRight: Radius.circular(30.0)
              ),
            ),
            child: Column(
              children: [
                Container( //Chart Indicator & Chart Selection button
                  height: 60.0,
                  padding: EdgeInsets.only(left: 20.0, top: 10.0, right: 20.0),
                  child: Row(
                    children: <Widget>[
                      _buildChartIndicator(),
                      Expanded(child: Container()),
                      _buildChartSelectBtn(Icons.show_chart, 0),
                      SizedBox(width: 10.0,),
                      _buildChartSelectBtn(Icons.bar_chart, 1),
                    ],
                  ),
                ),
                Expanded( //Expand vertical
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _selected[1] ? 
                      CarouselSlider.builder(
                        options: CarouselOptions(
                          height: double.infinity,
                          enlargeCenterPage: true,
                          viewportFraction: 1,
                          initialPage: 0,
                          onPageChanged: (index, reason) {
                            setState(() {
                              activeIndex = index;
                            });
                          },
                        ),
                        carouselController: sliderController,
                        itemCount: parameters.length,
                        itemBuilder: (BuildContext context, itemIndex, int pageViewIndex) =>
                          _getBarCharts(parameters[itemIndex], widget.dataList, _currentSliderValue.toInt()),
                      ) : CarouselSlider.builder(
                        options: CarouselOptions(
                          height: double.infinity,
                          enlargeCenterPage: true,
                          viewportFraction: 1,
                          initialPage: 0,
                          onPageChanged: (index, reason) {
                            setState(() {
                              activeIndex = index;
                            });
                          },
                        ),
                        carouselController: sliderController,
                        itemCount: parameters.length,
                        itemBuilder: (BuildContext context, itemIndex, int pageViewIndex) =>
                          _getLineCharts(parameters[itemIndex], widget.dataList, _currentSliderValue.toInt()),
                      ),
                    Row( //Left Right button row
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 30, height: 50, color: Colors.white,
                            child: IconButton(
                              icon: Icon(Icons.arrow_back_ios),
                              iconSize: 16.0,
                              padding: EdgeInsets.only(left: 20.0),
                              onPressed: previous,
                            ),
                          ),
                          Expanded(child: Container()),
                          Container(width: 30, height: 50, color: Colors.white,
                            child: IconButton(
                              icon: Icon(Icons.arrow_forward_ios),
                              iconSize: 16.0,
                              padding: EdgeInsets.only(right: 20.0),
                              onPressed: next,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  WaterBarChart _getBarCharts(String title, List<Data> dataList, int size) {
    List<double> testWater = [12.17, 11.15, 10.02, 11.21, 13.83, 14.16, 14.30];
    List<double> waterDataList = [];
    String sensorUnit = '';
    double reservedSize = 30.0;
    double barSize = 8.0;

    if (size > 30 ) {
      barSize = 2.4;
    } else if (size > 10) {
      barSize = 6.0;
    }

    //Select Graph Data
    switch (title) {
      case 'Temperature':
        sensorUnit = '(°C)';
        for (var i = 0; i < size; i++) { //7 is the number of days
          waterDataList.add(dataList[i].temp);
        }
        break;
      case 'Turbidity':
        sensorUnit = '(NTU)';
        for (var i = 0; i < size; i++) { //7 is the number of days
          waterDataList.add(dataList[i].turbidity);
        }
        reservedSize = 45.0;
        break;
      case 'pH':
        sensorUnit = '';
        for (var i = 0; i < size; i++) { //7 is the number of days
          waterDataList.add(dataList[i].pH);
        }
        reservedSize = 30.0;
        break;
      case 'Electrical Conductivity':
        sensorUnit = '(ms/cm)';
        for (var i = 0; i < size; i++) { //7 is the number of days
          waterDataList.add(dataList[i].eC);
        }
        reservedSize = 30.0;
        break;
      case 'Dissolved Oxygen':
        sensorUnit = '(mg/L)';
        for (var i = 0; i < size; i++) { //7 is the number of days
          waterDataList.add(dataList[i].dO);
        }
        reservedSize = 30.0;
        break;
      default:
        sensorUnit = '';
    }
    return WaterBarChart(dataList: waterDataList, title: title + sensorUnit, reservedSize: reservedSize, barSize: barSize,);
  }

  WaterLineChart2 _getLineCharts(String title, List<Data> dataList, int size) {
    List<double> testWater = [12.17, 11.15, 10.02, 11.21, 13.83, 14.16, 14.30];
    List<double> waterDataList = [];
    String sensorUnit = '';
    double reservedSize = 30.0;

    switch (title) {
      case 'Temperature':
        sensorUnit = '(°C)';
        for (var i = 0; i < size; i++) { //7 is the number of days
          waterDataList.add(dataList[i].temp);
        }
        break;
      case 'Turbidity':
        sensorUnit = '(NTU)';
        for (var i = 0; i < size; i++) { //7 is the number of days
          waterDataList.add(dataList[i].turbidity);
        }
        reservedSize = 45.0;
        break;
      case 'pH':
        sensorUnit = '';
        for (var i = 0; i < size; i++) { //7 is the number of days
          waterDataList.add(dataList[i].pH);
        }
        reservedSize = 30.0;
        break;
      case 'Electrical Conductivity':
        sensorUnit = '(mS/cm)';
        for (var i = 0; i < size; i++) { //7 is the number of days
          waterDataList.add(dataList[i].eC);
        }
        reservedSize = 30.0;
        break;
      case 'Dissolved Oxygen':
        sensorUnit = '(mg/L)';
        for (var i = 0; i < size; i++) { //7 is the number of days
          waterDataList.add(dataList[i].dO);
        }
        reservedSize = 30.0;
        break;
      default:
        sensorUnit = '';
    }
    return WaterLineChart2(dataList: waterDataList, title: title + sensorUnit, reservedSize: reservedSize, barSize: size);
  }

  Widget _buildChartIndicator() => AnimatedSmoothIndicator(
    activeIndex: activeIndex,
    count: parameters.length,
    effect: ExpandingDotsEffect(
      dotHeight: 10.0,
      dotWidth: 10.0,
      activeDotColor: AppColors.pageBackground,
      dotColor: Colors.blue.shade200,
    ),
  );

  Widget _buildChartSelectBtn(IconData iconType, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 2,
            offset: Offset(0, 2)
          ),
        ]
      ),
      child: CircleAvatar(
        radius: 20.0,
        backgroundColor: _selected[index]? AppColors.btnColor2 : Colors.grey[200],
        child: IconButton(
          icon: Icon(
            iconType, 
            color: _selected[index]? AppColors.mainColor : Colors.grey
          ), 
          onPressed: () => {
            setState(() {
              _selected = [false, false];
              _selected[index] = !_selected[index];
            })
          },
        ),
      ),
    );
  }

  void next() => sliderController.nextPage();

  void previous() => sliderController.previousPage();
}