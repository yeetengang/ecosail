
//Model for more than one data (Need add for single data, the structure returned is different)
class NotificationDetails {
  //final int statusCode;
  final List<Details> data;

  NotificationDetails({required this.data});

  factory NotificationDetails.fromJson(Map<String, dynamic> json) {
    return NotificationDetails(
      //statusCode: json["statusCode"],
      data: parseData(json),
    );
  }

  static List<Details> parseData(dataJson) {
    var list = dataJson['data'] as List;
    List<Details> dataList = list.map((data) => Details.fromJson(data)).toList();
    return dataList;
  }
}

class Details{
  String? tripID;
  String boatID; //The MAC Address of IoT Node
  String boatName;
  String datetime;
  String type;
  String dayName;
  String description;
  double longitude;
  double latitude;
  double? turbidity;
  double? temp;
  double? pH;
  double? eC;
  double? dO;
  
  Details({
    this.tripID,
    required this.boatID,
    required this.longitude,
    required this.latitude,
    required this.boatName,
    required this.description,
    this.turbidity,
    this.temp,
    this.pH,
    this.eC,
    this.dO,
    required this.dayName,
    required this.datetime,
    required this.type,
  });

  factory Details.fromJson(Map<String, dynamic> parsedJson) {
    return Details(
      tripID: parsedJson['tripID'],
      boatID: parsedJson['boatID'],
      boatName: parsedJson['boatName'],
      longitude: parsedJson['longitude'],
      latitude: parsedJson['latitude'],
      turbidity: parsedJson['turbidity'],
      temp: parsedJson['temp'],
      pH: parsedJson['pH'],
      eC: parsedJson['EC'],
      dO: parsedJson['DO'],
      datetime: parsedJson['datetime'],
      dayName: parsedJson['dayName'],
      type: parsedJson['type'],
      description: parsedJson['description']
    );
  }
}