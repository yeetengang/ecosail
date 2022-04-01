import 'package:ecosail/notification.dart';
import 'package:ecosail/others/colors.dart';
import 'package:ecosail/others/dragmarker.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:ecosail/widgets/inner_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class NotificationDetailsPage extends StatefulWidget {
  final String title;
  final Details details;

  NotificationDetailsPage({
    Key? key,
    required this.title,
    required this.details,
  }) : super(key: key);

  _NotificationDetailsPageState createState() => _NotificationDetailsPageState();
}

class _NotificationDetailsPageState extends State<NotificationDetailsPage> {
  List<DragMarker> _markers = [];
  late LatLng pointer;
  

  @override
  void initState() {
    super.initState();
    pointer = LatLng(widget.details.latitude, widget.details.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    
    print(pointer.latitude);

    _markers.add(
      DragMarker(
        point: pointer,
        width: 200.0,
        height: 100.0,
        offset: Offset(0.0, -8.0),
        builder: (ctx) => Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              margin: EdgeInsets.only(bottom: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white,
              ),
              child: Text(pointer.latitude.toString() + ', ' + pointer.longitude.toString()),
            ),
            Icon(
              Icons.location_on, 
              size: 50, 
              color: Colors.red,
            ),
          ],
        ),
        draggable: false, //The sailboat current location is not editable
        updateMapNearEdge: false,
      ),
    );


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size(screenSize.width, 60),
        child: InnerAppBar(currentPage: 'calibration',),
      ),
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: <Widget>[
          _buildHeader(screenSize.height, context, pointer),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildHeader(double screenHeight, BuildContext context, LatLng _pointer) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: AppLargeText(text: widget.title, color: Colors.black, size: 26,),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
              child: Text('Boat Name: ' + widget.details.boatName + '\nBoat ID: ' + widget.details.boatID, style: TextStyle(height: 1.3),),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 14.0),
              height: screenHeight * 0.3,
              color: Colors.blue,
              child: FlutterMap(
                options: MapOptions(
                  allowPanningOnScrollingParent: false,
                  onPositionChanged: (mapPostion, moved) {null;},
                  center: _pointer, 
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
                  DragMarkerPluginOptions(
                    markers: _markers, 
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
              child: widget.title == "Water Pollution" ? 
                Text('Date & Time\t: ' + widget.details.dayName.split("day")[0] + " " + widget.details.datetime.split(" ")[0] + " " + DateFormat.jm().format(DateFormat("hh:mm:ss").parse(widget.details.datetime.split(" ")[1]))):
                Text('Last Seen\t: ' + widget.details.dayName.split("day")[0] + " " + widget.details.datetime.split(" ")[0] + " " + DateFormat.jm().format(DateFormat("hh:mm:ss").parse(widget.details.datetime.split(" ")[1]))),
            ),
            widget.title == "Water Pollution" ? Container(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 14.0),
              child: Text(
                'Sensor Value',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline
                ),
              ),
            ): Container(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
              child: widget.title == "Sensors & Sailboat"? Text("About: \n\nNavigation not complete yet no updates from sensors and sailboat."): 
                  Text("About: \n\nSailboat Navigation Complete!\nAll pinned location are traversed, sailboat is going back to starting point."),
            ),
            widget.title == "Water Pollution" ? Container(
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Temperature', style: TextStyle(height: 1.3),),
                      Text('pH', style: TextStyle(height: 1.3),),
                      Text('Electrical Conductivity', style: TextStyle(height: 1.3),),
                      Text('Turbidity', style: TextStyle(height: 1.3),),
                      Text('Dissolved Oxygen', style: TextStyle(height: 1.3),),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('   : ' + widget.details.temp.toString(), style: TextStyle(height: 1.3, color: _checkValue(widget.details.temp, "temp")? Colors.red: Colors.black),),
                      Text('   : ' + widget.details.pH.toString(), style: TextStyle(height: 1.3, color: _checkValue(widget.details.pH, "pH")? Colors.red: Colors.black),),
                      Text('   : ' + widget.details.eC.toString(), style: TextStyle(height: 1.3, color: _checkValue(widget.details.eC, "EC")? Colors.red: Colors.black),),
                      Text('   : ' + widget.details.turbidity.toString(), style: TextStyle(height: 1.3, color: _checkValue(widget.details.turbidity, "tur")? Colors.red: Colors.black),),
                      Text('   : ' + widget.details.dO.toString(), style: TextStyle(height: 1.3, color: _checkValue(widget.details.dO, "DO")? Colors.red: Colors.black),),
                    ],
                  ),
                ],
              )
            ): Container(),
            Container(
              padding: EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    backgroundColor: AppColors.mainColor,
                    child: Icon(
                      Icons.clear, 
                      color: AppColors.btnColor2,
                    ),
                    onPressed: () {
                      Navigator.pop(
                        context, 
                      );
                    },
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }

  bool _checkValue(double? sensorData, String sensorName) {
    double sensorLowerSecondLimit = 0.0; //Lowest Value
    double sensorUpperSecondLimit = 0.0; //Highest Value
    switch (sensorName) {
      case 'temp':
        sensorLowerSecondLimit = 15.0;
        sensorUpperSecondLimit = 26.0;
        break;
      case 'tur':
        sensorLowerSecondLimit = 0.0;
        sensorUpperSecondLimit = 2000.0;
        break;
      case 'pH':
        sensorLowerSecondLimit = 5.0;
        sensorUpperSecondLimit = 10.0;
        break;
      case 'EC':
        sensorLowerSecondLimit = 0.0;
        sensorUpperSecondLimit = 55.0;
        break;
      case 'DO':
        // Need adjust, it is between 4 to 7 normal
        sensorLowerSecondLimit = 4.0;
        sensorUpperSecondLimit = 12.0;
        break;
    }
    
    if (sensorData! <= sensorLowerSecondLimit || sensorData >= sensorUpperSecondLimit) {
      return true;
    } 
    
    return false;
  }
}