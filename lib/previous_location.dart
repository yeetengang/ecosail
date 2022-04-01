class PreviousLocationData {
  final List<LocationDataItem> data;
  
  PreviousLocationData({
    required this.data,
  });

  factory PreviousLocationData.fromJson(Map<String, dynamic> json) {
    return PreviousLocationData(
      data: parseData(json),
    );
  }

  static List<LocationDataItem> parseData(dataJson) {
    var list = dataJson['data'] as List;
    List<LocationDataItem> dataList = list.map((data) => LocationDataItem.fromJson(data)).toList();
    return dataList;
  }
}

class LocationDataItem{
  int timestamp;
  String boatID;
  String date;
  String time;
  double latitude;
  double longitude;

  LocationDataItem({
    required this.timestamp,
    required this.boatID,
    required this.time,
    required this.date,
    required this.latitude,
    required this.longitude,
  });

  factory LocationDataItem.fromJson(Map<String, dynamic> parsedJson) {
    return LocationDataItem(
      timestamp: parsedJson['timestamp'],
      boatID: parsedJson['boatID'],
      date: parsedJson['date'],
      time: parsedJson['time'],
      latitude: parsedJson['latitude'],
      longitude: parsedJson['longitude']
    );
  }
}