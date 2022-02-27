class Sailboat {
  final int statusCode;
  final List<Boat> sailboats;

  Sailboat({required this.sailboats, required this.statusCode});

  factory Sailboat.fromJson(Map<String, dynamic> json) {
    return Sailboat(
      statusCode: json["statusCode"],
      sailboats: parseData(json),
    );
  }

  static List<Boat> parseData(dataJson) {
    var list = dataJson['data'] as List;
    List<Boat> dataList = list.map((data) => Boat.fromJson(data)).toList();
    return dataList;
  }
}

class Boat {
  String cloudID;
  String boatID;
  String boatName;
  String date;
  String time;

  Boat({
    required this.cloudID,
    required this.boatID,
    required this.boatName,
    required this.date,
    required this.time,
  });

  factory Boat.fromJson(Map<String, dynamic> parsedJson) {
    return Boat(
      cloudID: parsedJson['id'], 
      boatID: parsedJson['boatID'],
      boatName: parsedJson['boatName'],
      date: parsedJson['date'],
      time: parsedJson['time'],
    );
  }
}