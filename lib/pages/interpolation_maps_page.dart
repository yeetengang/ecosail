import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:ecosail/others/dragmarker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../others/colors.dart';
import '../widgets/app_large_text.dart';

Future<Map<String, dynamic>> getInterpolationImage2(String userID, String boatID, int size, String dataType, String tripID) async {
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
    "interpolation_temp": jsonDecode(response.body)['temp'],
    "interpolation_turb": jsonDecode(response.body)['turb'],
    "interpolation_pH": jsonDecode(response.body)['pH'],
    "interpolation_ec": jsonDecode(response.body)['ec'],
    "interpolation_do": jsonDecode(response.body)['do'],
    "latitude_start": jsonDecode(response.body)['latitude_start'],
    "latitude_end": jsonDecode(response.body)['latitude_end'],
    "longitude_start": jsonDecode(response.body)['longitude_start'],
    "longitude_end": jsonDecode(response.body)['longitude_end'],
    "datetime": jsonDecode(response.body)['datetime'],
    "tripID": jsonDecode(response.body)['tripID']
  };
  
  if (response.statusCode == 200) {
    return interpolationData;
  } else {
    return getInterpolationImage2(userID, boatID, 20, dataType, tripID);
  }
}

class MapsPage extends StatefulWidget {
  Widget generateMaps;
  String userID;
  String selectedSailboat;
  //String tripID;
  //String dateTime;

  MapsPage({ 
    Key? key,
    required this.generateMaps,
    required this.userID,
    required this.selectedSailboat,
    //required this.tripID,
    //required this.dateTime
  }) : super(key: key);

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late Future<Map<String, dynamic>> interpolationData;
  late Uint8List bytesTest;
  CarouselController sliderController = CarouselController();
  int activeIndex = 0;
  double latitudeCenter = 0.0;
  double longitudeCenter = 0.0;
  List<String> parameters = ['Temperature', 'Turbidity', 'pH', 'Electrical Conductivity', 'Dissolved Oxygen'];
  
  @override
  void initState() {
    super.initState();

    interpolationData = getInterpolationImage2(widget.userID, widget.selectedSailboat, 20, 'All', '');
    Timer.periodic(const Duration(seconds: 65), (t) {
      if (mounted) {
        setState(() {
          interpolationData = getInterpolationImage2(widget.userID, widget.selectedSailboat, 20, 'All', '');
        });
      }
    });
    /*bytes = widget.interpolationData.then((value) {
      return const Base64Codec().decode(value['interpolation_image']);
    });*/
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: <Widget>[
          _buildHeader(),
          kIsWeb? _buildWebContent(screenSize): _buildContent(screenSize),
        ],
      ),
    );
  }

  SliverFillRemaining _buildWebContent(Size screenSize) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Container(
        //height: screenSize.height * 0.625,
        width: screenSize.width,
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Row(
                children: <Widget>[
                  _buildChartIndicator(),
                  Expanded(child: Container()),
                  //_buildChartSelectBtn(Icons.show_chart, 0),
                  const SizedBox(width: 10.0,),
                  //_buildChartSelectBtn(Icons.bar_chart, 1),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                CarouselSlider.builder(
                  options: CarouselOptions(
                    height: 500,
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
                  itemBuilder: (BuildContext context, itemIndex, int pageViewIndex) {
                    return _buildInterpolationMap(parameters[itemIndex], itemIndex);
                    //widget.dataList[0].date == ""? const Text("No Data"): _getBarCharts(parameters[itemIndex], widget.dataList, _currentSliderValue.toInt()),
                  }
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
            )
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildContent(Size screenSize) {
    return SliverToBoxAdapter(
      child: Container(
        //height: screenSize.height * 0.625,
        width: screenSize.width,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0), 
            topRight: Radius.circular(30.0)
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container( //Chart Indicator & Chart Selection button
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Row(
                children: <Widget>[
                  _buildChartIndicator(),
                  Expanded(child: Container()),
                  //_buildChartSelectBtn(Icons.show_chart, 0),
                  const SizedBox(width: 10.0,),
                  //_buildChartSelectBtn(Icons.bar_chart, 1),
                ],
              ),
            ),
            CarouselSlider.builder(
              options: CarouselOptions(
                height: 500,
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
              itemBuilder: (BuildContext context, itemIndex, int pageViewIndex) {
                return _buildInterpolationMap(parameters[itemIndex], itemIndex);
                //widget.dataList[0].date == ""? const Text("No Data"): _getBarCharts(parameters[itemIndex], widget.dataList, _currentSliderValue.toInt()),
              }
            ),
          ],
        ),
      ),
    );
  }

  Container _buildInterpolationMap(String title, int index) {
    return Container(
      width: 400,
      padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          FutureBuilder<Map<String, dynamic>>(
            future: interpolationData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                latitudeCenter = (snapshot.data!['latitude_start'] + snapshot.data!['latitude_end']) / 2;
                longitudeCenter = (snapshot.data!['longitude_start'] + snapshot.data!['longitude_end']) / 2;
                latitudeCenter = latitudeCenter; // To adjust the location
                //_mapController.move(LatLng(latitudeCenter, longitudeCenter), 18);
                switch (index) {
                  case 0:
                    bytesTest = const Base64Codec().decode(snapshot.data!['interpolation_temp']);
                    return Column(
                      children: [
                        Text(
                          "Date: " + snapshot.data!['datetime'] + "\nTrip ID: " + snapshot.data!['tripID'],
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 300,
                              width: 300,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                              ),
                              child: new FlutterMap(
                                options: MapOptions(
                                  allowPanningOnScrollingParent: false,
                                  onPositionChanged: (mapPostion, moved) {null;},
                                  center: LatLng(latitudeCenter, longitudeCenter), 
                                  zoom: 18.0,
                                  plugins: [
                                    DragMarkerPlugin()
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
                            widget.selectedSailboat != ""? AspectRatio(
                              aspectRatio: 1, // Width to Height 1:1
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
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              height: 20,
                              width: 300,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: _getListColor(title),
                                )          
                              ),
                            ),
                            Container(
                              width: 315,
                              padding: EdgeInsets.only(top: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: _getColorBarLabel(title),
                              ),
                            ),
                          ],
                        )
                      ],
                    );
                  case 1:
                    bytesTest = const Base64Codec().decode(snapshot.data!['interpolation_turb']);
                    return Column(
                      children: [
                        Text(
                          "Date: " + snapshot.data!['datetime'] + "\nTripID: " + snapshot.data!['tripID'],
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 300,
                              width: 300,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                              ),
                              child: new FlutterMap(
                                options: MapOptions(
                                  allowPanningOnScrollingParent: false,
                                  onPositionChanged: (mapPostion, moved) {null;},
                                  center: LatLng(latitudeCenter, longitudeCenter), 
                                  zoom: 18.0,
                                  plugins: [
                                    DragMarkerPlugin()
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
                            widget.selectedSailboat != ""? AspectRatio(
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
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              height: 20,
                              width: 300,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: _getListColor(title),
                                )          
                              ),
                            ),
                            Container(
                              width: 315,
                              padding: EdgeInsets.only(top: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: _getColorBarLabel(title),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  case 2:
                    bytesTest = const Base64Codec().decode(snapshot.data!['interpolation_pH']);
                    return Column(
                      children: [
                        Text(
                          "Date: " + snapshot.data!['datetime'] + "\nTripID: " + snapshot.data!['tripID'],
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 300,
                              width: 300,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                              ),
                              child: new FlutterMap(
                                options: MapOptions(
                                  allowPanningOnScrollingParent: false,
                                  onPositionChanged: (mapPostion, moved) {null;},
                                  center: LatLng(latitudeCenter, longitudeCenter), 
                                  zoom: 18.0,
                                  plugins: [
                                    DragMarkerPlugin()
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
                            widget.selectedSailboat != ""? AspectRatio(
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
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              height: 20,
                              width: 300,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: _getListColor(title),
                                )          
                              ),
                            ),
                            Container(
                              width: 315,
                              padding: EdgeInsets.only(top: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: _getColorBarLabel(title),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  case 3:
                    bytesTest = const Base64Codec().decode(snapshot.data!['interpolation_ec']);
                    return Column(
                      children: [
                        Text(
                          "Date: " + snapshot.data!['datetime'] + "\nTripID: " + snapshot.data!['tripID'],
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 300,
                              width: 300,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                              ),
                              child: new FlutterMap(
                                options: MapOptions(
                                  allowPanningOnScrollingParent: false,
                                  onPositionChanged: (mapPostion, moved) {null;},
                                  center: LatLng(latitudeCenter, longitudeCenter), 
                                  zoom: 18.0,
                                  plugins: [
                                    DragMarkerPlugin()
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
                            widget.selectedSailboat != ""? AspectRatio(
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
                          ],
                        ),
                        Column(
                          children: [
                            Container(
                              height: 20,
                              width: 300,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: _getListColor(title),
                                )          
                              ),
                            ),
                            Container(
                              width: 315,
                              padding: EdgeInsets.only(top: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: _getColorBarLabel(title),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  case 4:
                    bytesTest = const Base64Codec().decode(snapshot.data!['interpolation_do']);
                    return Column(
                      children: [
                        Text(
                          "Date: " + snapshot.data!['datetime'] + "\nTripID: " + snapshot.data!['tripID'],
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 300,
                              width: 300,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                              ),
                              child: new FlutterMap(
                                options: MapOptions(
                                  allowPanningOnScrollingParent: false,
                                  onPositionChanged: (mapPostion, moved) {null;},
                                  center: LatLng(latitudeCenter, longitudeCenter), 
                                  zoom: 18.0,
                                  plugins: [
                                    DragMarkerPlugin()
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
                            widget.selectedSailboat != ""? AspectRatio(
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
                          ],
                        ),
                         Column(
                            children: [
                              Container(
                                height: 20,
                                width: 300,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: _getListColor(title),
                                  )          
                                ),
                              ),
                              Container(
                                width: 315,
                                padding: EdgeInsets.only(top: 2),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: _getColorBarLabel(title),
                                ),
                              ),
                            ],
                          ),
                      ],
                    );
                }
              }

              return CircularProgressIndicator();
            },
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0, bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AppLargeText(text: 'Interpolation Maps', color: Colors.blue.shade100,size: 26,),
                Text('Spatial Analysis of Data', style: TextStyle(height: 1.6, color: Colors.grey[300], fontWeight: FontWeight.w500),),
              ],
            ),
            //widget.generateMaps
          ],
        )
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

List<Color> _getListColor(String parameter) {
  List<Color> colorList = [];

  // ['Temperature', 'Turbidity', 'pH', 'Electrical Conductivity', 'Dissolved Oxygen']

  switch (parameter) {
    case "WQI":
      colorList = [Colors.black, Colors.red, Colors.orange, Colors.yellow, Colors.blue, Colors.green];
      break;
    default:
      colorList = [Colors.red, Colors.purpleAccent, Color.fromARGB(255, 34, 0, 255), Colors.purpleAccent, Colors.red];
      break;
  }

  return colorList;
}

List<Widget> _getColorBarLabel(String parameter) {
  List<Widget> listLabel = [];

  // ['Temperature', 'Turbidity', 'pH', 'Electrical Conductivity', 'Dissolved Oxygen']

  switch (parameter) {
    case "WQI":
      listLabel = [Text("0"),Text("45"),Text("65"),Text("80"),Text("95"),Text("100")];
      break;
    case "pH":
      listLabel = [Text("0.0"),Text("5.0"),Text("5.5"),Text("9.5"),Text("10.0")];
      break;
    case "Turbidity":
      listLabel = [Text("-200"),Text("0"),Text("100"),Text("1900"),Text("2000")];
      break;
    case "Dissolved Oxygen":
      listLabel = [Text("-20.0"),Text("0.0"),Text("10.0"),Text("45.0"),Text("55.0")];
      break;
    case "Temperature":
      listLabel = [Text("10.0"),Text("20.0"),Text("25.0"),Text("30.0"),Text("35.0")];
      break;
    case "Electrical Conductivity":
      listLabel = [Text("-20.0"),Text("0.0"),Text("10.0"),Text("45.0"),Text("80.0")];
      break;
    default:
      listLabel = [];
  }

  return listLabel;
}