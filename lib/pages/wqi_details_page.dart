import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecosail/others/dragmarker.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:ecosail/widgets/water_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../widgets/inner_app_bar.dart';

class WQIDetailsPage extends StatefulWidget {
  final String boatName;
  final String boatID;
  final double latitude;
  final double longitude;
  final int overallWQI;
  //final List<int> wqiList;

  const WQIDetailsPage({ 
    Key? key,
    required this.boatName,
    required this.boatID,
    required this.latitude,
    required this.longitude,
    required this.overallWQI,
    //required this.wqiList
  }) : super(key: key);

  @override
  State<WQIDetailsPage> createState() => _WQIDetailsPageState();
}

class _WQIDetailsPageState extends State<WQIDetailsPage> {
  late LatLng pointer;
  CarouselController sliderController = CarouselController();
  int activeIndex = 0;
  
  @override
  void initState() {
    super.initState();
    pointer = LatLng(widget.latitude, widget.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size(screenSize.width, 60),
        child: InnerAppBar(),
      ),
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
        padding: const EdgeInsets.only(top: 20.0, bottom: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: AppLargeText(text: "Water Quality Analysis", color: Colors.black, size: 26,),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Boat Name: ' + widget.boatName + '\nBoat ID: ' + widget.boatID, style: const TextStyle(height: 1.3),),
                  Text('Num. Sampling Data: ' + 20.toString() + '\nCollection Date: ' + '26 May 2022', style: const TextStyle(height: 1.3),),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30.0,),
              child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  text: 'Average WQI of that area: ',
                  style: TextStyle(
                    height: 1.3,
                    color: Colors.black
                  ),
                  children: <TextSpan> [
                    TextSpan(
                      text: widget.overallWQI.toString(),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    TextSpan(
                      text: ' - ' + _getWQIClass(widget.overallWQI),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ]
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverFillRemaining _buildBody(double screenHeight, double screenWidth) {
    /*return SliverFillRemaining(
      hasScrollBody: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30.0,),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Divider(
                color: Colors.black.withOpacity(0.8),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: AppLargeText(
                text: "Spatial Analysis", 
                color: Colors.black, 
                size: 22,
                decoration: TextDecoration.underline,
              ),
            ),
            /*Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
                  height: 300,
                  color: Colors.blue,
                  child: FlutterMap(
                    options: MapOptions(
                      allowPanningOnScrollingParent: false,
                      onPositionChanged: (mapPostion, moved) {null;},
                      center: pointer, 
                      zoom: 18.0,
                      plugins: [
                        DragMarkerPlugin(),
                      ],
                    ),
                    nonRotatedLayers: [
                      TileLayerOptions(
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                      ),
                    ],
                  ),
                ),
                Center(
                  child: CircularProgressIndicator(),
                )
              ],
            ),*/
            Expanded(child: Container(
              //height: screenHeight * 0.6,
              width: screenWidth,
              color: Colors.red,
            ))
          ],
        ),
      ),
    );*/
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Container(
        height: screenHeight * 0.625,
        width: screenWidth,
        child: Column(
          children: [
            Container(
              child: Divider(
                color: Colors.black.withOpacity(0.8),
              ),
            ),
            Expanded( //Expand vertical
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CarouselSlider.builder(
                    options: CarouselOptions(
                      height: double.infinity,
                      enableInfiniteScroll: false,
                      enlargeCenterPage: true,
                      initialPage: 0,
                      onPageChanged: (index, reason) {
                        setState(() {
                          activeIndex = index;
                        });
                      },
                    ),
                    carouselController: sliderController,
                    itemCount: 2,
                    itemBuilder: (BuildContext context, itemIndex, int pageViewIndex) {
                      if (itemIndex == 0) {
                        return Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              child: AppLargeText(
                                text: "Spatial Analysis", 
                                color: Colors.black, 
                                size: 22,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 14.0),
                                  height: 300,
                                  width: 300,
                                  child: FlutterMap(
                                    options: MapOptions(
                                      allowPanningOnScrollingParent: false,
                                      onPositionChanged: (mapPostion, moved) {null;},
                                      center: LatLng(5.28181934 - 0.00052, 100.19457757 - 0.00000), 
                                      zoom: 18.0,
                                      plugins: [
                                        
                                      ],
                                    ),
                                    nonRotatedLayers: [
                                      TileLayerOptions(
                                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                        subdomains: ['a', 'b', 'c'],
                                      ),
                                    ],
                                  ),
                                ),
                                /*FutureBuilder<Uint8List>(
                                  future: bytes,
                                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    Uint8List test = snapshot.data;
                                    return Container(
                                      //width: 240,
                                      height: 240,
                                      margin: const EdgeInsets.symmetric(vertical: 7.0, horizontal: 18.0),
                                      /*decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage('images/filename_test.png'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),*/
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        image: DecorationImage(
                                          image: MemoryImage(test),
                                          fit: BoxFit.cover
                                        ),
                                      ),
                                    );
                                  }
                                )*/
                              ],
                            ),
                          ],
                        );
                      }
                      else {
                        return Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              child: AppLargeText(
                                text: "Chart Data", 
                                color: Colors.black, 
                                size: 22,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            Text("test")
                          ],
                        );
                      }
                    },
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
    );
  }

  SliverToBoxAdapter _buildChart() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: AppLargeText(text: "Chart Data", color: Colors.black, size: 22,),
            ),
            //_getLineCharts(widget.wqiList, _currentSliderValue.toInt())
          ],
        ),
      ),
    );
  }

  void next() => sliderController.nextPage();

  void previous() => sliderController.previousPage();
}

/*WaterLineChart2 _getLineCharts(List<Data> dataList, int size) {
    List<double> testWater = [12.17, 11.15, 10.02, 11.21, 13.83, 14.16, 14.30];
    List<double> waterDataList = [];
    List<String> waterDataDate = [];
    String sensorUnit = '';
    double reservedSize = 30.0;

    switch (title) {
      case 'Temperature':
        sensorUnit = '(°C)';
        for (var i = 0; i < size; i++) { //7 is the number of days
          waterDataList.add(dataList[i].temp);
          waterDataDate.add(dataList[i].time);
        }
        break;
      case 'Turbidity':
        sensorUnit = '(NTU)';
        for (var i = 0; i < size; i++) { //7 is the number of days
          waterDataList.add(dataList[i].turbidity);
          waterDataDate.add(dataList[i].time);
        }
        reservedSize = 45.0;
        break;
      case 'pH':
        sensorUnit = '';
        for (var i = 0; i < size; i++) { //7 is the number of days
          waterDataList.add(dataList[i].pH);
          waterDataDate.add(dataList[i].time);
        }
        reservedSize = 20.0;
        break;
      case 'Electrical Conductivity':
        sensorUnit = '(mS/cm)';
        for (var i = 0; i < size; i++) { //7 is the number of days
          waterDataList.add(dataList[i].eC);
          waterDataDate.add(dataList[i].time);
        }
        reservedSize = 34.0;
        break;
      case 'Dissolved Oxygen':
        sensorUnit = '(mg/L)';
        for (var i = 0; i < size; i++) { //7 is the number of days
          waterDataList.add(dataList[i].dO);
          waterDataDate.add(dataList[i].time);
        }
        reservedSize = 30.0;
        break;
      default:
        sensorUnit = '';
    }
    return WaterLineChart2(
      dataList: waterDataList,
      timeList: waterDataDate, 
      title: title + sensorUnit, 
      reservedSize: reservedSize, 
      barSize: size
    );
  }
*/
String _getWQIClass(int wqiOverall) {
  String classNumber = "";
  String classStatus = "";

  if (wqiOverall <= 100 && wqiOverall >= 95) {
    classNumber = 1.toString();
    classStatus = "Excellent";
  } else if (wqiOverall <= 94 && wqiOverall >= 80) {
    classNumber = 2.toString();
    classStatus = "Good";
  } else if (wqiOverall <= 79 && wqiOverall >= 65) {
    classNumber = 3.toString();
    classStatus = "Fair";
  } else if (wqiOverall <= 65 && wqiOverall >= 45) {
    classNumber = 4.toString();
    classStatus = "Marginal";
  } else {
    classNumber = 5.toString();
    classStatus = "Poor";
  }
  return classStatus;
}