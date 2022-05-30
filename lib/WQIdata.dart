class WQIData {
  //final int statusCode;
  final List<WaterQualityData> data;
  final String statusCode;
  final int averWQI;
  final int averpH;
  final int averDO;
  final int averTemp;
  final int averTurb;
  final double oripH;
  final double oriTemp;
  final double oriDO;
  final double oriTurb;

  WQIData({
    required this.data, 
    required this.statusCode,
    required this.averDO,
    required this.averTemp,
    required this.averTurb,
    required this.averWQI,
    required this.averpH,
    required this.oriDO,
    required this.oriTemp,
    required this.oriTurb,
    required this.oripH,
  });

  factory WQIData.fromJson(Map<String, dynamic> json) {
    return WQIData(
      statusCode: json["statusCode"],
      averDO: json["averDO"],
      averTemp: json["averTemp"],
      averTurb: json["averTurb"],
      averWQI: json["averWQI"],
      averpH: json["averpH"],
      oriDO: json["oriDO"],
      oriTemp: json["oriTemp"],
      oriTurb: json["oriTurb"],
      oripH: json["oripH"],
      data: parseData(json),
    );
  }

  static List<WaterQualityData> parseData(dataJson) {
    var list = dataJson['body'] as List;
    List<WaterQualityData> dataList = list.map((data) => WaterQualityData.fromJson(data)).toList();
    return dataList;
  }
}

class WaterQualityData{
  int WQIph;
  int WQIdo;
  int WQItemp;
  int WQIturb;
  int WQIval;

  WaterQualityData({
    required this.WQIph,
    required this.WQIdo,
    required this.WQItemp,
    required this.WQIturb,
    required this.WQIval,
  });

  factory WaterQualityData.fromJson(Map<String, dynamic> parsedJson) {
    return WaterQualityData(
      WQIdo: parsedJson['WQI oxy'],
      WQIph: parsedJson['WQI pH'],
      WQItemp: parsedJson['WQI temp'],
      WQIturb: parsedJson['WQI turb'],
      WQIval: parsedJson['Overall WQI']
    );
  }
}