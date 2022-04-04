import 'dart:convert';
import 'dart:math';

import 'package:ecosail/others/colors.dart';
import 'package:ecosail/others/dragmarker.dart';
import 'package:ecosail/previous_location.dart';
import 'package:ecosail/widgets/responsive_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import 'package:fluttertoast/fluttertoast.dart';

Future<String> uploadLocation(String boatID, double latitude, double longitude, int userID) async {
  String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  String datetime = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
  String status = "Not Complete";

  final response = await http.post(
    Uri.parse('https://k3mejliul2.execute-api.ap-southeast-1.amazonaws.com/ecosail_stage/Ecosail_lambda2'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, String>{
      'boatID': boatID,
      'timestamp': timestamp,
      'latitude': latitude.toStringAsFixed(8),
      'longitude': longitude.toStringAsFixed(8),
      'userID': userID.toString(),
      'datetime': datetime, //'12/01/2022 14:14:05'
      'status': status,
    }),
  );
  if (response.statusCode == 200) {
    //return LocationData.fromJson(jsonDecode(response.body));
    return "ok";
  } else {
    throw Exception('Failed to add location.');
  }
}

class MapApp extends StatefulWidget {
  LatLng pointer;
  double boatLatitude;
  double boatLongitude;
  String boatID;
  String lastActiveDate;
  String lastActiveTime;
  List<LocationDataItem> locationList;

  MapApp({
    Key? key, 
    required this.pointer,
    required this.boatLatitude,
    required this.boatLongitude, 
    required this.boatID,
    required this.lastActiveDate,
    required this.lastActiveTime,
    required this.locationList,
  }) : super(key: key);

  @override
  _MapAppState createState() => _MapAppState();
}

class _MapAppState extends State<MapApp> {
  Future<String>? _futureLocation;
  MapController _mapController = MapController();
  List<DragMarker> _markers = [];
  late double zoomValue;
  late LatLng centerPosition;
  late LatLng dragUpdatePosition;
  late LatLng sailboatPosition;
  bool _editable = false;
  List<LatLng> initialPoints = [];
  String currentDistance = "0.0";
  
  @override
  void initState() {
    super.initState();
    centerPosition = widget.pointer;
    dragUpdatePosition = widget.pointer;
    sailboatPosition = widget.pointer;

    _markers.add(
      DragMarker(
        point: widget.pointer,
        width: 80.0,
        height: 80.0,
        offset: Offset(0.0, -8.0),
        builder: (ctx) => widget.lastActiveDate == ""? Icon(
          Icons.sailing, 
          size: 0, 
          color: Colors.transparent,
        ): Icon(
          Icons.sailing, 
          size: 50, 
          color: _getSailboatActive(widget.lastActiveDate, widget.lastActiveTime)? AppColors.pageBackground: Colors.grey,
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

    if (widget.locationList.length > 0) {
      for (var items in widget.locationList) {
        initialPoints.add(LatLng(items.latitude, items.longitude));
        _markers.add(
          DragMarker(
            point: LatLng(items.latitude, items.longitude),
            width: 80.0,
            height: 80.0,
            offset: Offset(0.0, -8.0),
            builder: (ctx) => Icon(
              Icons.location_on, 
              size: 50, 
              color: Colors.indigo[700],
            ),
            draggable: false, //The sailboat current location is not editable
            onDragUpdate: (details, point) {
              /*setState(() {
                dragUpdatePosition = point;
              });*/
            }, //The Lat and Long when drag
            updateMapNearEdge: false,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<bool> _disabled = [false, false, false, false];

    setState(() {
      _markers[0].point = widget.pointer;
      if (widget.boatID != "") {
        currentDistance = _getDistance(_markers[0].point.latitude, _markers[0].point.longitude, _markers[1].point.latitude, _markers[1].point.longitude);
      }
    });

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            allowPanningOnScrollingParent: false,
            center: sailboatPosition, 
            onPositionChanged: (mapPosition, moved) { 
              centerPosition = mapPosition.center!; 
              zoomValue = mapPosition.zoom!;
            }, //Get the camera center? position
            onMapCreated: (c) {
              _mapController = c;
            },
            zoom: 18.0,
            plugins: [
              DragMarkerPlugin(),
            ],
            onTap: (tapPosition, p) {
              /*setState(() {
                widget.pointer = p;
              });*/
            },
            //onMapCreated: 
          ),
          //layers: [
          nonRotatedLayers: [
            TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
            ),
            /*MarkerLayerOptions(
              markers: [
                Marker(
                  width: 100.0,
                  height: 100.0,
                  point: widget.pointer,
                  builder: (context) => Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40.0,
                  ), 
                ),
              ]
            )*/
            DragMarkerPluginOptions(
              markers: _markers, 
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(20.0),
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              decoration: BoxDecoration(
                color: _editable? Colors.green : AppColors.mainColor,
                borderRadius: BorderRadius.circular(40.0),
              ),
              child: _editable? Text(
                'Latitude: ' + dragUpdatePosition.latitude.toStringAsFixed(8) + '\nLongtitude: ' + dragUpdatePosition.longitude.toStringAsFixed(8) + '\nDistance: ' + _getDistance(sailboatPosition.latitude, sailboatPosition.longitude, dragUpdatePosition.latitude, dragUpdatePosition.longitude), 
                style: TextStyle(color: Colors.white),
              ): Text(
                'Latitude: ' + widget.boatLatitude.toStringAsFixed(8) + '\nLongtitude: ' + widget.boatLongitude.toStringAsFixed(8) + '\nDistance: ' + currentDistance, 
                style: TextStyle(color: Colors.white),
              ),
            ),
            Expanded(child: Container()),
            Container(
              padding: EdgeInsets.only(top: 20.0, right: 12.0),
              child: Column(
                children: [
                  MapPageButton(
                    margin: EdgeInsets.only(bottom: 16.0), 
                    color: _editable? Colors.green : AppColors.mainColor,
                    widget: _editable? Icon(Icons.add_location, color: Colors.white,) : Icon(Icons.location_on, color: AppColors.btnColor2,), 
                    onTap: () {
                      if (!_editable) {
                        setState(() {
                          _editable = true;
                          showToast("Drag red marker to set location");
                          _createNewMarker(centerPosition);
                          _mapController.move(centerPosition, zoomValue);
                          dragUpdatePosition = centerPosition;
                        });
                      }else {
                        setState(() {
                          if (widget.boatID != "") {
                            print(uploadLocation(widget.boatID, dragUpdatePosition.latitude, dragUpdatePosition.longitude, 123));
                            showToast(dragUpdatePosition.latitude.toStringAsFixed(8) + ', '+ dragUpdatePosition.longitude.toStringAsFixed(8));
                          }
                          else {
                            showToast("You does not have any boat yet, location will not be saved");
                          }
                          _editable = false;
                          _markers[_markers.length-1].draggable = _editable;
                          _markers[_markers.length-1].builder = (ctx) => Icon(Icons.location_on, size: 50, color: Colors.indigo[700],);
                        });
                      }
                    }
                  ),
                  MapPageButton(
                    margin: EdgeInsets.only(bottom: 16.0), 
                    widget: Icon(Icons.cloud, color: AppColors.btnColor2,),
                    onTap: () {},
                  ),
                  MapPageButton(
                    margin: EdgeInsets.only(bottom: 16.0), 
                    widget: Icon(Icons.my_location, color: AppColors.btnColor2,),
                    onTap: () {
                      setState(() {
                        //Move the camera to follow the sailboat
                        _mapController.move(widget.pointer, 18.0);
                      });
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  void _createNewMarker(LatLng position) {
    _markers.add(
      DragMarker(
        point: position,
        width: 80.0,
        height: 80.0,
        offset: Offset(0.0, -8.0),
        draggable: _editable,
        builder: (ctx) => Icon(Icons.edit_location, size: 50, color: Colors.red,),
        onDragStart:  (details,point) => print("Start point $point"), //The Lat Long when hold to drag
        onDragEnd:    (details,point) => print("End point $point"), //The Lat Long when release
        onDragUpdate: (details,point) {
          setState(() {
            dragUpdatePosition = point;
          });
        }, //The Lat and Long when drag
        updateMapNearEdge: false,
      ),
    );
  }

  void mapCreated(controller) {
    setState(() {
      _mapController = controller;
    });
  }

  String _getDistance(double lat1, double long1, double lat2, double long2) {
    String unit;
    double R = 6371; //Radius of earth in km
    double dLat = degToRadian(lat2 - lat1); 
    double dLon = degToRadian(long2 - long1);
    double a = sin(dLat/2) * sin(dLat/2) +
                cos(degToRadian(lat1)) * cos(degToRadian(lat2)) *
                sin(dLon/2) * sin(dLon/2);
    
    double c = 2 * atan2(sqrt(a), sqrt(1-a));
    double distance = R * c; //in km

    if (distance < 1) {
      unit = 'm';
      distance = distance * 1000;
    } else {
      unit = 'km';
    }

    return distance.toStringAsFixed(3) + unit;
  }

  void showToast(String text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
    );
  }

  bool _getSailboatActive(String date, String time) {
    if (date == "" && time == "") {
      return false; // If the sailboat has no data at all return sensor is not active
    }

    List<String> dateSplit = date.split("/");
    List<String> timeSplit = time.split(':');
    DateTime sailboatLatestDateTime = DateTime(
      int.parse(dateSplit[2]),
      int.parse(dateSplit[1]),
      int.parse(dateSplit[0]),
      int.parse(timeSplit[0]),
      int.parse(timeSplit[1]),
      int.parse(timeSplit[2]),
    );
    DateTime deviceDateTime = DateTime.now();
    if (deviceDateTime.difference(sailboatLatestDateTime).inSeconds >= 15) {
      return false;
    }
    return true;
  }
}

class MapPageButton extends StatelessWidget {
  EdgeInsetsGeometry margin;
  Widget widget;
  Color color;
  void Function() onTap;

  MapPageButton({
    Key? key, 
    required this.margin,
    required this.widget,
    required this.onTap,
    this.color = const Color(0xFF0277BD),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 3,
            color: Colors.black.withOpacity(0.4),
            spreadRadius: 2,
            offset: Offset(1 ,1),
          ),
        ],
      ),
      child: ResponsiveButton(
        width: 50.0,
        height: 50.0,
        widget: widget,
        colors: color,
        onTap: onTap,
      ),
    );
  }
}

class LocationData {
  int timestamp;
  String boatID;
  String userID;
  String datetime;
  String status;
  double latitude;
  double longitude;
  
  LocationData({
    required this.timestamp,
    required this.boatID,
    required this.userID,
    required this.datetime,
    required this.status,
    required this.latitude,
    required this.longitude,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      timestamp: json['timestamp'],
      boatID: json['boatID'],
      userID: json['userID'],
      datetime: json['datetime'],
      status: json['status'],
      latitude: json['latitude'],
      longitude: json['longitude']
    );
  }
}