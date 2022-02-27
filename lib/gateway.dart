/*import 'dart:convert' show json;

class Gateway {
  final int statusCode;
  final List<Data> data;

  Gateway({required this.statusCode, required this.data});

  factory Gateway.fromJson(Map<String, dynamic> json) {
    return Gateway(
      statusCode: json["statusCode"],
      data: parseData(json),
    );
  }

  static List<Data> parseData(dataJson) {
    var list = dataJson['data'] as List;
    List<Data> dataList = list.map((data) => Data.fromJson(data)).toList();
    return dataList;
  }

}

class Data{
  int timestamp;
  String tripID;
  String longitude;
  String latitude;
  String dissolvedOxygen;
  String temp;
  String boatID;
  String pH;
  String electricConduct;
  String wind;
  String date;
  String time;

  Data({
    required this.timestamp,
    required this.tripID,
    required this.longitude,
    required this.latitude,
    required this.dissolvedOxygen,
    required this.temp,
    required this.boatID,
    required this.pH,
    required this.electricConduct,
    required this.wind,
    required this.date,
    required this.time
  });

  factory Data.fromJson(Map<String, dynamic> parsedJson) {
    return Data(
      timestamp: parsedJson['timestamp'], 
      tripID: parsedJson['tripID'],
      longitude: parsedJson['longitude'],
      latitude: parsedJson['latitude'],
      dissolvedOxygen: parsedJson['DO'],
      temp: parsedJson['temp'],
      boatID: parsedJson['boatID'],
      pH: parsedJson['pH'],
      electricConduct: parsedJson['EC'],
      wind: parsedJson['wind'],
      date: parsedJson['date'],
      time: parsedJson['time']
    );
  }
}*/

import 'package:flutter/cupertino.dart';

//Model for more than one data (Need add for single data, the structure returned is different)
class Gateway {
  final int statusCode;
  final List<Data> data;

  Gateway({required this.statusCode, required this.data});

  factory Gateway.fromJson(Map<String, dynamic> json) {
    return Gateway(
      statusCode: json["statusCode"],
      data: parseData(json),
    );
  }

  static List<Data> parseData(dataJson) {
    var list = dataJson['data'] as List;
    List<Data> dataList = list.map((data) => Data.fromJson(data)).toList();
    return dataList;
  }

}

class Data{
  int timestamp;
  String tripID;
  String boatID; //The MAC Address of IoT Node
  String date;
  String time;
  double longitude;
  double latitude;
  double turbidity;
  double temp;
  double pH;
  double eC;
  double dO;
  double wind;

  Data({
    required this.timestamp,
    required this.tripID,
    required this.boatID,
    required this.longitude,
    required this.latitude,
    required this.turbidity,
    required this.temp,
    required this.pH,
    required this.eC,
    required this.dO,
    required this.wind,
    required this.date,
    required this.time,
  });

  factory Data.fromJson(Map<String, dynamic> parsedJson) {
    return Data(
      timestamp: parsedJson['timestamp'], 
      tripID: parsedJson['tripID'],
      boatID: parsedJson['boatID'],
      longitude: parsedJson['longitude'],
      latitude: parsedJson['latitude'],
      turbidity: parsedJson['turbidity'],
      temp: parsedJson['temp'],
      pH: parsedJson['pH'],
      eC: parsedJson['EC'],
      dO: parsedJson['DO'],
      wind: parsedJson['wind'],
      date: parsedJson['date'],
      time: parsedJson['time'],
    );
  }
}