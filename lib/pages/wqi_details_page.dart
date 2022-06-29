import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecosail/WQIdata.dart';
import 'package:ecosail/others/dragmarker.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:ecosail/widgets/water_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import '../widgets/inner_app_bar.dart';

Future<Map<String, dynamic>> getWQISpatialImage(String userID, String boatID, int size, String dataType, String tripID) async {
  String status = "Get Interpolation"; //Cannot directly process and retrieve otherwise will cause error
  Map<String, dynamic> interpolationData;

  final response = await http.post(
    Uri.parse('https://k3mejliul2.execute-api.ap-southeast-1.amazonaws.com/ecosail_stage/Ecosail_lambda2'),
    headers: <String, String>{
      'Accept': 'application/json',
    },
    body: jsonEncode(<String, String>{
      'userID': userID,
      'status': status,
      'boatID': boatID,
      'tripID': tripID,
      'size': size.toString(),
      'type': dataType
    }),
  );
  
  interpolationData = {
    "interpolation_image": jsonDecode(response.body)['body'],
    "latitude_start": jsonDecode(response.body)['latitude_start'],
    "latitude_end": jsonDecode(response.body)['latitude_end'],
    "longitude_start": jsonDecode(response.body)['longitude_start'],
    "longitude_end": jsonDecode(response.body)['longitude_end']
  };

  if (response.statusCode == 200) {
    print(boatID + " " + dataType + " " + tripID);
    return interpolationData;
  } else {
    return getWQISpatialImage(userID, boatID, 20, dataType, tripID);
  }
}

class WQIDetailsPage extends StatefulWidget {
  final String boatName;
  final String boatID;
  final String userID;
  final int overallWQI;
  final String tripID;
  final List<WaterQualityData> WQIList;

  const WQIDetailsPage({ 
    Key? key,
    required this.boatName,
    required this.boatID,
    required this.tripID,
    required this.overallWQI,
    required this.WQIList,
    required this.userID
  }) : super(key: key);

  @override
  State<WQIDetailsPage> createState() => _WQIDetailsPageState();
}

class _WQIDetailsPageState extends State<WQIDetailsPage> {
  late Future<Map<String, dynamic>> interpolationData;
  late Timer t = Timer(const Duration(milliseconds: 10), () {});
  double latitudeCenter = 0.0;
  double longitudeCenter = 0.0;
  CarouselController sliderController = CarouselController();
  int activeIndex = 0;
  //MapController _mapController = MapController();
  final List<DragMarker> _markers = [];
  
  @override
  void initState() {
    super.initState();
    interpolationData = getWQISpatialImage(widget.userID, widget.boatID, 20, 'WQI', widget.tripID);
    
    Timer.periodic(const Duration(seconds: 65), (t) {
      if (mounted) {
        print("refreshing...");
        setState(() {
          interpolationData = getWQISpatialImage(widget.userID, widget.boatID, 20, 'WQI', widget.tripID);
        });
      }
    });
  }

    @override
  void dispose() {
    super.dispose();
    t.cancel();
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
                  Text('Num. Sampling Data: ' + widget.WQIList.length.toString() + '\nCollection Date: ' + widget.WQIList[0].dataTime, style: const TextStyle(height: 1.3),),
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

  SliverToBoxAdapter _buildBody(double screenHeight, double screenWidth) {
    return SliverToBoxAdapter(
      child: Container(
        width: screenWidth,
        child: Column(
          children: [
            Container(
              child: Divider(
                color: Colors.black.withOpacity(0.8),
              ),
            ),
            Stack(
                alignment: Alignment.centerLeft,
                children: [
                  CarouselSlider.builder(
                    options: CarouselOptions(
                      height: 450,
                      enableInfiniteScroll: false,
                      viewportFraction: 1,
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
                        return buildInterpolationMap();
                      }
                      else {
                        return Container(
                          width: 400,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                                      child: AppLargeText(
                                        text: "Chart Data", 
                                        color: Colors.black, 
                                        size: 22, 
                                        decoration: TextDecoration.underline,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    _getLineCharts(widget.WQIList, widget.WQIList.length)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  Row( //Left Right button row
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      activeIndex == 1 ? Container(width: 30, height: 50, color: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          iconSize: 16.0,
                          padding: const EdgeInsets.only(left: 20.0),
                          onPressed: previous,
                        ),
                      ): Container(),
                      Expanded(child: Container()),
                      activeIndex == 0? Container(width: 30, height: 50, color: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          iconSize: 16.0,
                          padding: const EdgeInsets.only(right: 20.0),
                          onPressed: next,
                        ),
                      ): Container(),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Container buildInterpolationMap() {
    return Container(
      width: 400,
      child: Column(
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: interpolationData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                latitudeCenter = (snapshot.data!['latitude_start'] + snapshot.data!['latitude_end']) / 2;
                longitudeCenter = (snapshot.data!['longitude_start'] + snapshot.data!['longitude_end']) / 2;
                Uint8List bytesTest = const Base64Codec().decode(snapshot.data!['interpolation_image']);

                latitudeCenter = latitudeCenter;

                _markers.clear();
                _markers.add(
                  DragMarker(
                    point: LatLng(latitudeCenter, longitudeCenter),
                    width: 80.0,
                    height: 80.0,
                    offset: const Offset(0.0, -8.0),
                    builder: (ctx) => const Icon(
                      Icons.sailing, 
                      size: 20, 
                      color: Colors.blue,
                    ),
                    draggable: false, //The sailboat current location is not editable
                    onDragUpdate: (details, point) {
                      /*setState(() {
                        dragUpdatePosition = point;
                      });*/
                    }, //The Lat and Long when drags
                    updateMapNearEdge: false,
                  ),
                );

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 300,
                      width: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: FlutterMap(
                        //mapController: _mapController,
                        options: MapOptions(
                          allowPanningOnScrollingParent: false,
                          onPositionChanged: (mapPostion, moved) {null;},
                          center: LatLng(latitudeCenter, longitudeCenter), 
                          zoom: 18.0,
                          plugins: [
                            DragMarkerPlugin()
                          ],
                          /*onMapCreated: (c) {
                            _mapController = c;
                          },*/
                        ),
                        nonRotatedLayers: [
                          TileLayerOptions(
                            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                            subdomains: ['a', 'b', 'c'],
                          ),
                          DragMarkerPluginOptions(
                            markers: _markers, 
                          ),
                        ],
                      ),
                    ),
                    widget.boatID != ""? AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        width: 240,
                        margin: const EdgeInsets.only(right: 10, bottom: 2),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          image: DecorationImage(
                            image: MemoryImage(bytesTest),
                            fit: BoxFit.cover,
                            alignment: FractionalOffset.center
                          ),
                        ),
                      ),
                    ): Container(),
                    Positioned(
                      top: 0,
                      child: Container(
                        child: AppLargeText(
                          text: "Spatial Analysis", 
                          color: Colors.black, 
                          size: 22,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        height: 20,
                        width: 300,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _getListColor("WQI"),
                          )          
                        ),
                      ),
                    )
                  ],
                );
              } 
              return CircularProgressIndicator();
            },
          ),
          Container(
            width: 315,
            padding: EdgeInsets.only(top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _getColorBarLabel("WQI"),
            ),
          ),
        ],
      ),
    );
  }

  void next() => sliderController.nextPage();

  void previous() => sliderController.previousPage();
}

WaterLineChart2 _getLineCharts(List<WaterQualityData> WQIList, int size) {
    List<double> WQIDataList = [];
    List<String> dataTime = [];
    double reservedSize = 30.0;

    for (var i = 0; i < size; i++) { //7 is the number of days
      WQIDataList.add(WQIList[i].WQIval.toDouble());
      dataTime.add(WQIList[i].dataTime);
    }

    return WaterLineChart2(
      dataList: WQIDataList,
      timeList: dataTime, 
      title: "", 
      reservedSize: reservedSize, 
      barSize: size
    );
  }

List<Widget> _getColorBarLabel(String parameter) {
  List<Widget> listLabel = [];
  switch (parameter) {
    case "WQI":
      listLabel = [Text("0"),Text("45"),Text("65"),Text("80"),Text("95"),Text("100")];
      break;
    case "pH":
      listLabel = [Text("0.0"),Text("5.0"),Text("5.5"),Text("9.5"),Text("10.0")];
      break;
    case "turbidity":
      listLabel = [Text("-200"),Text("0"),Text("100"),Text("1900"),Text("2000")];
      break;
    case "DO":
      listLabel = [Text("-20.0"),Text("0.0"),Text("10.0"),Text("45.0"),Text("55.0")];
      break;
    case "temp":
      listLabel = [Text("10.0"),Text("20.0"),Text("25.0"),Text("30.0"),Text("35.0")];
      break;
    default:
      listLabel = [];
  }

  return listLabel;
}

List<Color> _getListColor(String parameter) {
  List<Color> colorList = [];

  switch (parameter) {
    case "WQI":
      colorList = [Colors.black, Colors.red, Colors.orange, Colors.yellow, Colors.blue, Colors.green];
      break;
  }

  return colorList;
}

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