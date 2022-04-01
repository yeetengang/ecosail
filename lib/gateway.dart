import 'package:flutter/cupertino.dart';

//Model for more than one data (Need add for single data, the structure returned is different)
class Gateway {
  //final int statusCode;
  final List<Data> data;

  Gateway({required this.data});

  factory Gateway.fromJson(Map<String, dynamic> json) {
    return Gateway(
      //statusCode: json["statusCode"],
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
  double latitude;
  double longitude;
  double dO;
  double temp;
  double turbidity;
  double pH;
  double eC;
  double wind;
  String date;
  String time;
  List<String> boatID;

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
    required this.date,
    required this.time,
    required this.wind,
  });

  factory Data.fromJson(Map<String, dynamic> parsedJson) {
    return Data(
      timestamp: parsedJson['timestamp'], 
      tripID: parsedJson['tripID'],
      boatID: parseBoatID(parsedJson['boatID']),
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

  static List<String> parseBoatID(boatJson) {
    List<String> boatList = new List<String>.from(boatJson);
    return boatList;
  }
}