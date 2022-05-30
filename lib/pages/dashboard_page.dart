import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecosail/WQIdata.dart';
import 'package:ecosail/gateway.dart';
import 'package:ecosail/others/colors.dart';
import 'package:ecosail/pages/wqi_details_page.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:ecosail/widgets/reponsive_text.dart';
import 'package:ecosail/widgets/responsive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:http/http.dart' as http;

Future<WQIData> getWQIData(String userID, String boatID, int dissolveOxy) async {
  
  try {
    final response = await http.post(
      Uri.parse('https://k3mejliul2.execute-api.ap-southeast-1.amazonaws.com/ecosail_stage2/ecosail_getsensor'),
      headers: <String, String>{
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'userID': "de65ea37490b4d2d8a4c1cd6ab52b266",
        'boatID': "b8:27:eb:9b:91:d2",
        'dissolveOxy': dissolveOxy.toString(),
        'pH': '6.65',
        'temp': '30',
        'turb': '5'
      }),
    );
    print(response.body);
    // The request will timeout the first time if long time no use, can recall again if this happend
    if (response.statusCode == 200) {
      return WQIData.fromJson(jsonDecode(response.body));
    } else {
      return getWQIData('123', '123', 80);
    }
  } on HttpException catch(e) {
    print('error cought: $e');
  }

  throw Exception("Error getting WQI data");
}

class DashboardPage extends StatefulWidget {
  final List<Data> dataList;
  final String selectedboatID;
  final String selectedboatName;
  
  const DashboardPage({
    Key? key,
    required this.dataList,
    required this.selectedboatID,
    required this.selectedboatName
  });

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin{
  bool sensorActive = false;
  int dissolveOxy = 0, pH = 0, temp = 0, turb = 0, wqiOverall = 0;
  double oriPh = 0, oriTemp = 0, oriTurb = 0, oriDO = 0;
  CarouselController sliderController = CarouselController();
  int activeIndex = 0;
  late Future<WQIData> futureWQIData;
  late Timer t = Timer(const Duration(milliseconds: 10), () {});
  DateTime now = DateTime.now();
  String formattedDate = "";
  
  @override
  void initState() {
    super.initState();
    
    // For WQI only retrieve every 5 minutes
    futureWQIData = getWQIData('123', '123', 80);
    formattedDate = DateFormat('EEE d MMM kk:mm a').format(now);
    Timer.periodic(const Duration(minutes: 5), (t) {
      if (mounted) {
        setState(() {
          now = DateTime.now().toLocal();
          formattedDate = DateFormat('EEE d MMM kk:mm a').format(now);
          futureWQIData = getWQIData('123', '123', 80);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    TabController _tabController = TabController(length: 3, vsync: this, initialIndex: activeIndex);

    futureWQIData.then((value) {
      setState(() {
        dissolveOxy = value.averDO;
        pH = value.averpH;
        temp = value.averTemp;
        turb = value.averTurb;
        wqiOverall = value.averWQI;
        oriDO = value.oriDO;
        oriPh = value.oripH;
        oriTemp = value.oriTemp;
        oriTurb = value.oriTurb;
      });
    });

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: <Widget>[
          _buildHeader(screenSize.height),
          _buildDashboardPages(screenSize.height, screenSize.width, _tabController),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildHeader(double screenHeight) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0, bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppLargeText(text: 'Dashboard', color: AppColors.bigTextColor,size: 26,),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildDashboardPages(double screenHeight, double screenWidth, TabController _tabController) {
    //print(screenHeight);
    //print(screenWidth);

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tab Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Responsive.isMobile(context) || Responsive.isTablet(context) || (screenHeight < 400.0 && Responsive.isTablet(context))? TabBar( 
                //Show tab bar when is Mobile / is Tablet / is Horizontal Mobile version
                labelPadding: const EdgeInsets.only(left: 20, right: 20,),
                controller: _tabController,
                labelColor: Colors.white, 
                unselectedLabelColor: Colors.grey[350], 
                isScrollable: true, 
                indicatorSize: TabBarIndicatorSize.label,
                indicator: CircleTabIndicator(color: AppColors.btnColor2, radius: 4),
                tabs: const [
                  Tab(text: "Sensors"),
                  Tab(text: "WQI"),
                  Tab(text: "Boat"),
                ],
                onTap: (value) {
                  //Value is the pressed tabs
                  activeIndex = value;
                  sliderController.jumpToPage(value);
                },
              ): null,
            ),
          ),
          // Carousel Slider
          Container(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 16.0, right: 16.0),
            alignment: Alignment.center,
            width: screenWidth,
            height: Responsive.isDesktop(context)? null: 500.0,
            child: !kIsWeb && (Responsive.isMobile(context) || screenHeight < 400.0)? CarouselSlider( 
              //When not a web version and is a mobile or horizontal mobile (Horizontal Mobile height will < 400.0)
              carouselController: sliderController,
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
              items: [
                Column(
                  children: <Widget>[
                    Flexible(
                      child: Row(
                        children: <Widget>[
                          Expanded(child: _buildSensorCards(screenWidth, 'Temperature', widget.dataList[0].temp)),
                          Expanded(child: _buildSensorCards(screenWidth, 'Turbidity', widget.dataList[0].turbidity)),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Row(
                        children: <Widget>[
                          Expanded(child: _buildSensorCards(screenWidth, 'pH', widget.dataList[0].pH)),
                          Expanded(child: _buildSensorCards(screenWidth, 'Electrical\nConductivity', widget.dataList[0].eC)),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Row(
                        children: <Widget>[
                          Expanded(child: _buildSensorCards(screenWidth, 'Dissolved\nOxygen', widget.dataList[0].dO)),
                        ],
                      ),
                    ),
                  ],
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
                      width: double.infinity,
                      /*decoration: BoxDecoration(
                        color: AppColors.btnColor2,
                        borderRadius: BorderRadius.circular(10.0),
                      ),*/
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 50,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Aver. WQI Prediction", 
                                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: AppColors.bigTextColor),
                                    ),
                                    ResponsiveText(
                                      text: 'See the details',
                                      colors: AppColors.sheetFocusColor,
                                      size: 14.0,
                                      onTap: () { 
                                        Navigator.push(
                                          context, 
                                          PageRouteBuilder(pageBuilder: (_, __, ___) => 
                                            WQIDetailsPage(
                                              boatID: widget.selectedboatID,
                                              boatName: widget.selectedboatName,
                                              latitude: 5.34938049,
                                              longitude: 100.29799652,
                                              overallWQI: wqiOverall,
                                            )
                                          ), //use MaterialPageRoute for animation
                                        );
                                      }
                                    ),
                                  ],
                                ),
                                Text(
                                  "Last Update: " + formattedDate, 
                                  style: TextStyle(
                                    fontSize: 14.0, 
                                    height: 2.0, 
                                    color: Colors.white.withOpacity(0.9)
                                  ), 
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 170,
                            margin: EdgeInsets.symmetric(vertical: 10.0),
                            decoration: BoxDecoration(
                              color: AppColors.btnColor2,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: const Offset(1, 1)
                                ),
                              ]
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 50 + 20 + 5,
                      child: Container(
                        height: 200,
                        width: 200,
                        child: SfRadialGauge(
                          enableLoadingAnimation: false,
                          animationDuration: 2500,
                          axes: <RadialAxis>[
                            RadialAxis(
                              radiusFactor: 1,
                              majorTickStyle: MajorTickStyle(color: AppColors.mainColor),
                              axisLabelStyle: GaugeTextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold
                              ),
                              startAngle: 180,
                              endAngle: 0,
                              minimum: 0, 
                              maximum: 100, 
                              pointers: <GaugePointer>[
                                NeedlePointer(
                                  value: wqiOverall.toDouble(), 
                                  enableAnimation: true,
                                  needleEndWidth: 5,
                                  knobStyle: KnobStyle(
                                    color: AppColors.mainColor,
                                    knobRadius: 0.05,
                                  ),
                                  needleColor: AppColors.mainColor,
                                )
                              ], 
                              ranges: <GaugeRange>[
                                GaugeRange(startValue: 0, endValue: 45, color: Colors.red,),
                                GaugeRange(startValue: 45, endValue: 65, color: Colors.orange,),
                                GaugeRange(startValue: 65, endValue: 80, color: Colors.yellow,),
                                GaugeRange(startValue: 80, endValue: 95, color: Colors.lightBlue,),
                                GaugeRange(startValue: 95, endValue: 100, color: Colors.lightGreen,)
                              ], 
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50 + 100 + 10 + 20 + 5, // 50 for Title, 100 for half of gauge, 10 for extra space, 20 for padding
                      child: Container(
                        height: 50,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: "WQI: ",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.0
                            ),
                            children: <TextSpan> [
                              TextSpan(
                                text: wqiOverall.toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold
                                )
                              ),
                              _getWQIClass(wqiOverall),
                            ]
                          ),
                        ),
                      )
                    ),
                    Positioned(
                      top: 100 + 145,
                      left: 15,
                      child: Container(
                        width: screenWidth - 57, 
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _getWQICard("pH", pH, oriPh.toDouble()),
                            _getWQICard("Temp", temp, oriTemp.toDouble()),
                            _getWQICard("Turb", turb, oriTurb.toDouble()),
                          ],
                        )
                      )
                    ),
                    Positioned(
                      top: 100 + 145 + 100 + 10,
                      left: 15,
                      child: Container(
                        width: screenWidth - 57, 
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _getWQICard("DO", dissolveOxy, oriDO.toDouble()),
                            Flexible(child: Container(), flex: 2,)
                          ],
                        )
                      )
                    ),
                  ],
                ),
                Column(
                  children: <Widget>[
                    _buildCurrentSailboatCard(screenHeight, widget.selectedboatID, widget.selectedboatName, context),
                    _buildBoatDataCards(screenHeight, 'Current Location', widget.dataList, context),
                    _buildBoatDataCards(screenHeight, 'Wind Direction', widget.dataList, context)
                  ],
                ),
              ],
            ): Responsive.isTablet(context) && kIsWeb? Column( //When is a web version and is tablet size
              children: <Widget>[
                Flexible(
                  child: Row(
                    children: <Widget>[
                      Expanded(child: _buildSensorCards(screenWidth, 'Temperature', widget.dataList[0].temp)),
                      Expanded(child: _buildSensorCards(screenWidth, 'Turbidity', widget.dataList[0].turbidity)),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    children: <Widget>[
                      Expanded(child: _buildSensorCards(screenWidth, 'pH', widget.dataList[0].pH)),
                      Expanded(child: _buildSensorCards(screenWidth, 'Electrical\nConductivity', widget.dataList[0].eC)),
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    children: <Widget>[
                      Expanded(child: _buildSensorCards(screenWidth, 'Dissolved\nOxygen', widget.dataList[0].dO)),
                    ],
                  ),
                ),
              ],
            ): Container( //When is a web version
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: SizedBox(
                          height: 200,
                          child: _buildSensorCards(screenWidth, 'Temperature', widget.dataList[0].temp),
                        )
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: SizedBox(
                          height: 200,
                          child: _buildSensorCards(screenWidth, 'Turbidity', widget.dataList[0].turbidity),
                        )
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: SizedBox(
                          height: 200,
                          child: _buildSensorCards(screenWidth, 'pH', widget.dataList[0].pH),
                        )
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: SizedBox(
                          height: 200,
                          child: _buildSensorCards(screenWidth, 'Electrical\nConductivity', widget.dataList[0].eC),
                        )
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: SizedBox(
                          height: 200,
                          child: _buildSensorCards(screenWidth, 'Dissolved\nOxygen', widget.dataList[0].dO),
                        )
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          (kIsWeb || Responsive.isTablet(context)) && screenHeight >= 400.0? Container(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
            alignment: Alignment.topLeft,
            child: const Text('Predicted WQI data',),
          ): Container(),
          (kIsWeb || Responsive.isTablet(context)) && screenHeight >= 400.0? Container(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
            child: Column(
              children: <Widget>[
                _buildCurrentSailboatCard(screenHeight, widget.selectedboatID, widget.selectedboatName, context),
                _buildBoatDataCards(screenHeight, 'Current Location', widget.dataList, context),
                _buildBoatDataCards(screenHeight, 'Wind Direction', widget.dataList, context)
              ],
            ),
          ): Container()
        ],
      ),
    );
  }

  Container _buildSensorCards(double screenWidth, String sensorName, double sensorData) {
    String sensorUnit;
    double sensorLowerSecondLimit = 0.0; //Lowest Value
    double sensorLowerFirstLimit = 0.0; //Second Lowest Value
    double sensorUpperFirstLimit = 0.0; //First Highest Value
    double sensorUpperSecondLimit = 0.0; //Highest Value
    Color sensorValueColor = Colors.black;

    switch (sensorName) {
      case 'Temperature':
        sensorUnit = '°C';
        sensorLowerSecondLimit = 15.0;
        sensorLowerFirstLimit = 16.0;
        sensorUpperFirstLimit = 25.0;
        sensorUpperSecondLimit = 26.0;
        break;
      case 'Turbidity':
        sensorUnit = 'NTU';
        sensorLowerSecondLimit = 0.0;
        sensorLowerFirstLimit = 100.0;
        sensorUpperFirstLimit = 1900.0;
        sensorUpperSecondLimit = 2000.0;
        break;
      case 'pH':
        sensorUnit = '';
        sensorLowerSecondLimit = 5.0;
        sensorLowerFirstLimit = 5.5;
        sensorUpperFirstLimit = 9.5;
        sensorUpperSecondLimit = 10.0;
        break;
      case 'Electrical\nConductivity':
        sensorUnit = 'ms/cm';
        sensorLowerSecondLimit = 0.0;
        sensorLowerFirstLimit = 10.0;
        sensorUpperFirstLimit = 45.0;
        sensorUpperSecondLimit = 55.0;
        break;
      case 'Dissolved\nOxygen':
        // Need adjust, it is between 4 to 7 normal
        sensorUnit = 'mg/L';
        sensorLowerSecondLimit = 4.0;
        sensorLowerFirstLimit = 4.5;
        sensorUpperFirstLimit = 11.5;
        sensorUpperSecondLimit = 12.0;
        break;
      default:
        sensorUnit = '';
    }
    
    if (sensorData <= sensorLowerSecondLimit || sensorData >= sensorUpperSecondLimit) {
      sensorValueColor = Colors.red;
    } else if ((sensorData >= sensorLowerSecondLimit && sensorData < sensorLowerFirstLimit) ||
     (sensorData >= sensorUpperFirstLimit && sensorData < sensorUpperSecondLimit)) {
      sensorValueColor = Colors.orange;
    }
  
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: AppColors.btnColor2,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Align(
            alignment: AlignmentDirectional.center,
            child: Text(
              sensorName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            child: Row(
              children: [
                const Text(
                  'OFF / ON',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12.0,
                  ),
                ),
                Expanded(child: Container()),
                _getSensorActive(widget.dataList[0].date, widget.dataList[0].time)? 
                const Icon(Icons.toggle_on, size: 35.0, color: AppColors.textColor1,): const Icon(Icons.toggle_off, size: 35.0, color: Colors.grey,),
              ],
          ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _getSensorActive(widget.dataList[0].date, widget.dataList[0].time)? sensorData.toString() + ' ' : '0.00 ' ,
                  style: TextStyle(
                    color: _getSensorActive(widget.dataList[0].date, widget.dataList[0].time)? sensorValueColor : Colors.black,
                    fontSize: 22.0,
                    overflow: TextOverflow.visible,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    sensorUnit,
                    style: TextStyle(
                      color: _getSensorActive(widget.dataList[0].date, widget.dataList[0].time)? sensorValueColor : Colors.black,
                      overflow: TextOverflow.visible,
                      fontSize: 14.0,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _getSensorActive(String date, String time) {

    if (date == "" && time == "") {
      return false; // If the sailboat has no data at all return sensor is not active
    }

    List<String> dateSplit = date.split("/");
    List<String> timeSplit = time.split(':');
    DateTime sensorLatestDateTime = DateTime(
      int.parse(dateSplit[2]), 
      int.parse(dateSplit[1]), 
      int.parse(dateSplit[0]),
      int.parse(timeSplit[0]),
      int.parse(timeSplit[1]),
      int.parse(timeSplit[2]),
    );
    DateTime deviceDateTime = DateTime.now();
    //print('data: ' + sensorLatestDateTime.toString());
    //print('now: ' + deviceDateTime.toString());
    //print('differences: ' + deviceDateTime.difference(sensorLatestDateTime).inSeconds.toString());
    if (deviceDateTime.difference(sensorLatestDateTime).inSeconds >= 15) { //Usually 15 seconds, but the emulator got time delay
      return false;
    }
    return true;
  }
}

SizedBox _buildCurrentSailboatCard(double screenHeight, String selectedBoatID, String selectedBoatName, BuildContext context) {
  String content = "";
  double heightValue = !kIsWeb && Responsive.isTablet(context)? screenHeight > 1000? screenHeight * 0.15 : screenHeight * 0.4: screenHeight * 0.18;

  if (selectedBoatID == "") {
    content = "No Sailboat Selected";
  } else {
    content = '\nName: ' + selectedBoatName + '\nID: '+ selectedBoatID;
  }

  return SizedBox(
    height: heightValue,
    child: Row(
      children: [
        Flexible(
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 7.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0),
                  ),
                  image: DecorationImage(
                    image: AssetImage('images/sailboat.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Positioned(
                top: 16.0,
                left: 20.0,
                child: Icon(Icons.sailing, color: Colors.white,),
              ),
            ],
          )
        ),
        Flexible(
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 7.0),
                decoration: const BoxDecoration(
                  color: AppColors.btnColor2,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Sailboat',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(content, style: const TextStyle(fontSize: 12.0, height: 1.5),),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    ),
  );
}

SizedBox _buildBoatDataCards(double screenHeight, String title, List<Data> dataList, BuildContext context) {
  IconData icon = Icons.location_pin;
  String data = '';

  switch (title) {
    case 'Current Location':
      icon = Icons.location_pin;
      data = dataList[0].latitude.toStringAsFixed(8) + '° N, '+ dataList[0].longitude.toStringAsFixed(8) + '° E';
      break;
    case 'Wind Direction':
      icon = Icons.cloud;
      data = dataList[0].wind.toString() + '° N';
      break;
  }

  return SizedBox(
    height: !kIsWeb && Responsive.isTablet(context)? screenHeight > 1000? screenHeight * 0.15 : screenHeight * 0.4: screenHeight * 0.225,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 7.0),
      decoration: const BoxDecoration(
        color: AppColors.btnColor2,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.215 * 0.1,),
              Text(title, style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),),
              Expanded(child: Container(),),
              Icon(icon, color: AppColors.mainColor, size: 50.0,),
              Expanded(child: Container(),),
              Text(data, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w800),),
              SizedBox(height: screenHeight * 0.215 * 0.1,),
            ],
          ),
        ],
      )
    ),
  );
}

Flexible _getWQICard(String title, int wqiValue, double originalVal) {
  String sensorName = title;
  String sensorUnit = "";

  switch (sensorName) {
      case 'Temp':
        sensorUnit = '°C';
        break;
      case 'Turb':
        sensorUnit = 'NTU';
        break;
      case 'pH':
        sensorUnit = 'units';
        break;
      case 'DO':
        // Need adjust, it is between 4 to 7 normal
        sensorUnit = 'mg/L';
        break;
      default:
        sensorUnit = '';
    } 

  return Flexible(
    flex: 1,
    child: Container(
      height: 100,
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.only(right: 5.0),
      decoration: BoxDecoration(
        color: AppColors.btnColor2,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(1, 1)
          ),
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "WQI " + title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
              fontWeight: FontWeight.w500
            ),
          ),
          RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              text: wqiValue.toString(),
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.0
              ),
              children: <TextSpan> [
                TextSpan(
                  text: " / 100",
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontSize: 14.0,
                    height: 1.5
                  )
                ),
              ]
            ),
          ),
          Text(
            originalVal.toString() + " " + sensorUnit
          ),
        ],
      ),
    ),
  );
}

TextSpan _getWQIClass(int wqiOverall) {
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
  return TextSpan(
    text: '\nClass: ' + classNumber + " - " + classStatus,
    style: TextStyle(
      color: Colors.black,
      fontSize: 14.0,
      height: 1.5,
      fontWeight: FontWeight.bold
    )
  );
}

class CircleTabIndicator extends Decoration {
  final Color color; //Color of circle
  double radius; //Radius of circle
  CircleTabIndicator({required this.color, required this.radius});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CirclePainter(color: color, radius: radius);
  }
}

class _CirclePainter extends BoxPainter {
  final Color color; //Color of circle
  double radius; //Radius of circle
  _CirclePainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    Paint _paint = Paint();
    _paint.color = color;
    _paint.isAntiAlias = true;
    //configuration allow to access the details of the element that use this paint
    final Offset circleOffset = Offset(configuration.size!.width/2 - radius/2, configuration.size!.height - radius);

    canvas.drawCircle(offset+circleOffset, radius, _paint);
  }
}