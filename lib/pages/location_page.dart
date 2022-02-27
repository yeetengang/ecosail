import 'package:ecosail/gateway.dart';
import 'package:ecosail/widgets/map_app.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class LocationPage extends StatefulWidget {
  final List<Data> dataList;
  const LocationPage({required this.dataList});

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    LatLng pointer = LatLng(widget.dataList[0].latitude, widget.dataList[0].longitude); //The sailboat starting will have -0.0001, +0.0001 different

    return Scaffold(
      body: MapApp(
        pointer: pointer, 
        boatID: widget.dataList[0].boatID,
        lastActiveDate: widget.dataList[0].date,
        lastActiveTime: widget.dataList[0].time,
      ),
    );
  }

  
}