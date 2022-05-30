import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../others/colors.dart';
import '../widgets/app_large_text.dart';

//Backup Code

class MapsPage extends StatefulWidget {
  const MapsPage({ Key? key }) : super(key: key);

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final List<bool> _selected = [false, true];
  CarouselController sliderController = CarouselController();
  int activeIndex = 0;
  double _currentSliderValue = 7;
  List<String> parameters = ['Temperature', 'Turbidity', 'pH', 'Electrical Conductivity', 'Dissolved Oxygen'];

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
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
            AppLargeText(text: 'Interpolation Maps', color: Colors.blue.shade100,size: 26,),
            Text('Spatial Analysis of Data', style: TextStyle(height: 1.6, color: Colors.grey[300], fontWeight: FontWeight.w500),),
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
            decoration: const BoxDecoration(
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
                  padding: const EdgeInsets.only(left: 20.0, top: 10.0, right: 20.0),
                  child: Row(
                    children: <Widget>[
                      _buildChartIndicator(),
                      Expanded(child: Container()),
                      /*_buildChartSelectBtn(Icons.show_chart, 0),
                      SizedBox(width: 10.0,),
                      _buildChartSelectBtn(Icons.bar_chart, 1),*/
                    ],
                  ),
                ),
                Expanded( //Expand vertical
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
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
                          //_getBarCharts(parameters[itemIndex], widget.dataList, _currentSliderValue.toInt()),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 18.0),
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('images/filename.png'),
                                //fit: BoxFit.cover,
                              ),
                            ),
                          ),
                      ),
                    Row( //Left Right button row
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 30, height: 50, color: Colors.white,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios),
                              iconSize: 16.0,
                              padding: const EdgeInsets.only(left: 20.0),
                              onPressed: previous,
                            ),
                          ),
                          Expanded(child: Container()),
                          Container(width: 30, height: 50, color: Colors.white,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_forward_ios),
                              iconSize: 16.0,
                              padding: const EdgeInsets.only(right: 20.0),
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

  void next() => sliderController.nextPage();

  void previous() => sliderController.previousPage();
}