import 'dart:convert';

import 'package:ecosail/gateway.dart';
import 'package:ecosail/previous_location.dart';
import 'package:ecosail/widgets/map_app.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

// Use POST method to get sensor Data
Future<PreviousLocationData> getPreviousLocationData(String userID, String boatID) async{
  String status = "Get Location Data";

  final response = await http.post(
    Uri.parse('https://k3mejliul2.execute-api.ap-southeast-1.amazonaws.com/ecosail_stage/Ecosail_lambda2'),
    headers: <String, String>{
      'Accept': 'application/json',
    },
    body: jsonEncode(<String, String>{
      "userID": userID,
      "status": status,
      "boatID": boatID
    }),
  );
  
  if (response.statusCode == 200) {
    return PreviousLocationData.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to retrieve data');
  }
}

class LocationPage extends StatefulWidget {
  final List<Data> dataList;
  final String selectedboatID;
  final String userID;
  const LocationPage({required this.dataList, required this.selectedboatID, required this.userID});

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  late Future<PreviousLocationData> futureLocation;

  @override
  void initState() {
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    LatLng pointer = LatLng(widget.dataList[0].latitude, widget.dataList[0].longitude); //The sailboat starting will have -0.0001, +0.0001 different
    if (widget.selectedboatID != "") {
      futureLocation = getPreviousLocationData(widget.userID, widget.selectedboatID);
      return Scaffold(
        /*body: MapApp(
          pointer: pointer, 
          boatID: widget.dataList[0].boatID,
          lastActiveDate: widget.dataList[0].date,
          lastActiveTime: widget.dataList[0].time,
        ),*/
        body: FutureBuilder<PreviousLocationData>(
          future: futureLocation,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // Later include the case where there is no any previous pointer in database
              return MapApp(
                pointer: pointer,
                boatLatitude: widget.dataList[0].latitude,
                boatLongitude: widget.dataList[0].longitude,
                boatID: widget.selectedboatID,
                userID: widget.userID,
                lastActiveDate: widget.dataList[0].date,
                lastActiveTime: widget.dataList[0].time,
                locationList: snapshot.data!.data,
              );
            }
            else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            return Scaffold(
              backgroundColor: Colors.white,
              body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator()
                    ],
                  )
                ],
              ),
            );
          }
        ),
      );
    } else {
      return Scaffold(
        body: MapApp(
          pointer: pointer,
          boatLatitude: widget.dataList[0].latitude,
          boatLongitude: widget.dataList[0].longitude,
          boatID: widget.selectedboatID,
          userID: widget.userID,
          lastActiveDate: widget.dataList[0].date,
          lastActiveTime: widget.dataList[0].time,
          locationList: const [],
        ),
      );
    }
    
    
  }

  
}

