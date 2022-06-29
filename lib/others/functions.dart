import 'dart:math';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

abstract class FunctionClass extends StatelessWidget {
  const FunctionClass({ Key? key }) : super(key: key);

  static bool _getSensorActive(String date, String time) {
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

  static String _getDistance(double lat1, double long1, double lat2, double long2) {
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
}