class FunctionClass {
  bool _getSensorActive(String date, String time) {

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
}