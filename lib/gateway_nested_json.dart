import 'dart:convert' show json;

class Gateway {
  final int statusCode;
  final Body body;
  final String test;
  
  Gateway({required this.statusCode, required this.body, required this.test});

  factory Gateway.fromJson(Map<String, dynamic> parsedJson) {
    return Gateway(
      statusCode: parsedJson['statusCode'],
      body: Body.fromJson(json.decode(parsedJson['body'])),
      test: parsedJson['body']
    );
  }
}

class Body {
  final String timestamp;
  final String tripID;
  final String longitude;
  final String latitude;
  final String DO;
  final String temp;
  final String boatID;
  final String pH;
  final String EC;
  final String wind;
  final String date;
  final String time;

  Body({
    required this.timestamp,
    required this.tripID,
    required this.longitude,
    required this.latitude,
    required this.DO,
    required this.temp,
    required this.boatID,
    required this.pH,
    required this.EC,
    required this.wind,
    required this.date,
    required this.time
  });

  factory Body.fromJson(Map<String, dynamic> parsedJson) {
    return Body(
      timestamp: parsedJson['timestamp'],
      tripID: parsedJson['tripID'],
      longitude: parsedJson['longitude'],
      latitude: parsedJson['latitude'],
      DO: parsedJson['DO'],
      temp: parsedJson['temp'],
      boatID: parsedJson['boatID'],
      pH: parsedJson['pH'],
      EC: parsedJson['EC'],
      wind: parsedJson['wind'],
      date: parsedJson['date'],
      time: parsedJson['time']
    );
  }
}