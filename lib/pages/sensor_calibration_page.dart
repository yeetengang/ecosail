import 'dart:async';
import 'dart:convert';

import 'package:ecosail/gateway.dart';
import 'package:ecosail/others/colors.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:ecosail/widgets/inner_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<bool> uploadCalibration(String boatID, String command, int userID) async {
  String status = "Calibration";

  final response = await http.post(
    Uri.parse('https://k3mejliul2.execute-api.ap-southeast-1.amazonaws.com/ecosail_stage/Ecosail_lambda2'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, String>{
      'boatID': boatID,
      'command': command,
      'userID': userID.toString(),
      'status': status,
    }),
  );
  if (response.statusCode == 200) {
    //return LocationData.fromJson(jsonDecode(response.body));
    return false;
  } else {
    throw Exception('Failed to calibrate.');
  }
}

Future<CalibrationMsg> getCalibrationMsg(String boatID, String userID) async {
  String status = "Get Calibration Msg";

  final response = await http.post(
    Uri.parse('https://k3mejliul2.execute-api.ap-southeast-1.amazonaws.com/ecosail_stage/Ecosail_lambda2'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, String>{
      'boatID': boatID,
      'userID': userID.toString(),
      'status': status,
    }),
  );
  if (response.statusCode == 200) {
    return CalibrationMsg.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to calibrate.');
  }
}

class SensorCalibratePage extends StatefulWidget {
  final List<Data> dataList;
  final String boatID;
  final String userID;

  const SensorCalibratePage({required this.dataList, required this.boatID, required this.userID});

  @override
  _SensorCalibratePageState createState() => _SensorCalibratePageState();
}

class _SensorCalibratePageState extends State<SensorCalibratePage> {
  Timer t = Timer(Duration(milliseconds: 5000), () {});
  late Future<CalibrationMsg> futureCalibrationMessage;

  @override
  void initState() {
    super.initState();
    futureCalibrationMessage = getCalibrationMsg(widget.boatID, widget.userID);
    Timer.periodic(Duration(milliseconds: 5000), (t) {
      if (this.mounted) {
        setState(() {
          futureCalibrationMessage = getCalibrationMsg(widget.boatID, widget.userID);
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    t.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    List<String> sensors = ['pH', 'EC', 'DO']; //'Tur'
    
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: PreferredSize(
        preferredSize: Size(screenSize.width, 60),
        child: InnerAppBar(dataList: widget.dataList, currentPage: 'calibration',),
      ),
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: <Widget>[
          _buildHeader(screenSize.height),
          _buildBody(screenSize.height, sensors, context),
        ],
      ),
    );
  }
  
  SliverToBoxAdapter _buildHeader(double screenHeight) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: screenHeight * 0.2,
        child: Container(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0, bottom: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(child: Container()),
              Icon(Icons.memory, color: AppColors.btnColor2, size: 30.0,),
              SizedBox(height: 20.0),
              AppLargeText(text: 'Sensor Calibration', color: AppColors.bigTextColor, size: 26,),
              Expanded(child: Container()),
            ],
          ),
        ),
      )
    );
  }

  SliverFillRemaining _buildBody(double screenHeight, List<String> sensors, BuildContext context) {
    List<String> label = ['Sensor', 'Enter', 'Calibrate', 'Exit'];
    List<double> left = [0.0, 10.0, 30.0, 18.0];
    List<double> right = [8.0, 0.0, 18.0, 16.0];
    String currentSensor = "";

    List<Container> _generateFirstRow(List<String> label){
      List<Container> containers = [];
      label.asMap().forEach((index, name) {
        containers.add(
          Container(
            padding: EdgeInsets.only(left: left[index], right: right[index]),
            child: Text(name),
          )
        );
      });
      return containers;
    }

    return SliverFillRemaining(
      hasScrollBody: false,
      child: SizedBox(
        height: screenHeight * 0.7,
        child: Container(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 0.0, bottom: 10.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Current Saiboat', 
                style: TextStyle(
                  fontWeight: FontWeight.w500
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  'Sailboat ID\n' + widget.boatID, 
                  style: TextStyle(
                    fontWeight: FontWeight.w900, 
                    fontSize: 20.0,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              /*Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: _getSensorActive(widget.dataList[0].date, widget.dataList[0].time)?Colors.greenAccent[100] : Colors.red[100],
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(right: 10.0),
                          child: Text(
                            'Sensors', 
                            style: TextStyle(
                              color: _getSensorActive(widget.dataList[0].date, widget.dataList[0].time)?Colors.green[500] : Colors.red[900],
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        ),
                        Icon(
                          _getSensorActive(widget.dataList[0].date, widget.dataList[0].time)?
                            Icons.check_circle : Icons.error, size: 16.0, 
                          color: _getSensorActive(widget.dataList[0].date, widget.dataList[0].time)?
                            Colors.green[500] : Colors.red[900],
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 3.0),
                    decoration: BoxDecoration(
                      color: _getSensorActive(widget.dataList[0].date, widget.dataList[0].time)?
                          Colors.greenAccent[100]: Colors.red[100],
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.only(right: 10.0),
                          child: Text(
                            'Ready to Calibrate', 
                            style: TextStyle(
                              color: _getSensorActive(widget.dataList[0].date, widget.dataList[0].time)? 
                                Colors.green[500] : Colors.red[900],
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        ),
                        _getSensorActive(widget.dataList[0].date, widget.dataList[0].time)? 
                          Icon(Icons.check_circle, size: 16.0, color: Colors.green[500]):
                          Icon(Icons.error, size: 16.0, color: Colors.red[900]),
                      ],
                    ),
                  ),
                ],
              ),*/
              widget.boatID == ""? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 12.0),
                margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 6.0),
                decoration: BoxDecoration(
                  color: AppColors.btnColor2,
                  borderRadius: BorderRadius.circular(40.0)
                ),
                child: Text(
                  "No sailboat selected yet",
                  style: TextStyle(fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ):Container(
                constraints: BoxConstraints(minWidth: 200, maxWidth: 300),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 12.0),
                margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 6.0),
                decoration: BoxDecoration(
                  color: AppColors.btnColor2,
                  borderRadius: BorderRadius.circular(40.0)
                ),
                child: FutureBuilder<CalibrationMsg>(
                  future: futureCalibrationMessage,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return _getSensorActive(snapshot.data!.messages.date, snapshot.data!.messages.time)? snapshot.data!.messages.command == "No Calibration"? Text(
                        "Select one sensor to calibrate",
                        style: TextStyle(fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ): snapshot.data!.messages.command.contains("PH")? Text(
                        "pH(" + snapshot.data!.messages.ph.toString() + "): " + _getMessage(snapshot.data!.messages.message, "PH"),
                        style: TextStyle(fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ): snapshot.data!.messages.command.contains("EC")? Text(
                        "EC(" + snapshot.data!.messages.ec.toString() + "): " + _getMessage(snapshot.data!.messages.message, "EC"),
                        style: TextStyle(fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ): snapshot.data!.messages.command.contains("DO")? Text(
                        "DO(" + snapshot.data!.messages.dOxygen.toString() + "): " + _getMessage(snapshot.data!.messages.message, "DO"),
                        style: TextStyle(fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ): Text(
                        "Error retrieving data",
                        style: TextStyle(fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center
                      ): Text(
                        "IoT Node has not been activated",
                        style: TextStyle(fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      );
                    } 
                    else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }
                    // By default, show a loading spinner.
                    return const Text("Getting Sensor Ready...");
                  }
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // First Row
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: _generateFirstRow(label),
                    ),
                  ),
                  FutureBuilder<CalibrationMsg>(
                    future: futureCalibrationMessage,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            CalibrationRow( // Cal Remain + ENTERPH = Loading
                              title: "pH", 
                              activateEnter:  _getCalibrationBtnStatus(snapshot.data!.messages.message, "Enter") && snapshot.data!.messages.command == "No Calibration" && _getSensorActive(snapshot.data!.messages.date, snapshot.data!.messages.time), 
                              activateCal:  _getCalibrationBtnStatus(snapshot.data!.messages.message, "Cal") && snapshot.data!.messages.command.contains("PH"),
                              activateExit:  _getCalibrationBtnStatus(snapshot.data!.messages.message, "Exit") && snapshot.data!.messages.command.contains("PH"),
                            ),
                            CalibrationRow(
                              title: "EC", 
                              activateEnter:  _getCalibrationBtnStatus(snapshot.data!.messages.message, "Enter") && snapshot.data!.messages.command == "No Calibration" && _getSensorActive(snapshot.data!.messages.date, snapshot.data!.messages.time), 
                              activateCal:  _getCalibrationBtnStatus(snapshot.data!.messages.message, "Cal") && snapshot.data!.messages.command.contains("EC"),
                              activateExit:  _getCalibrationBtnStatus(snapshot.data!.messages.message, "Exit") && snapshot.data!.messages.command.contains("EC"),
                            ),
                            CalibrationRow(
                              title: "DO", 
                              activateEnter:  _getCalibrationBtnStatus(snapshot.data!.messages.message, "Enter") && snapshot.data!.messages.command == "No Calibration" && _getSensorActive(snapshot.data!.messages.date, snapshot.data!.messages.time), 
                              activateCal:  _getCalibrationBtnStatus(snapshot.data!.messages.message, "Cal") && snapshot.data!.messages.command.contains("DO"),
                              activateExit:  _getCalibrationBtnStatus(snapshot.data!.messages.message, "Exit") && snapshot.data!.messages.command.contains("DO"),
                            ),
                          ],
                        );
                      } 
                      else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }
                      // By default, show a loading spinner.
                      return const Text("Getting Sensor Ready...");
                    }
                  ),
                ]//_generateTable(sensors),
              ),
              /*Container(
                padding: EdgeInsets.only(top: 10.0),
                child: FloatingActionButton(
                  backgroundColor: AppColors.mainColor,
                  child: Icon(
                    Icons.clear, 
                    color: AppColors.btnColor2,
                  ),
                  onPressed: () {
                    Navigator.pop(
                      context, 
                      PageRouteBuilder(pageBuilder: (_, __, ___) => BottomNavScreen(dataList: widget.dataList)), //use MaterialPageRoute for animation
                    );
                  },
                ),
              ),*/
            ],
          ),
        ),
      )
    );
  }

  bool _getCalibrationBtnStatus(String message, String btnType) {
    
    if (message == "EnterDone" && (btnType == "Cal" || btnType == "Exit")) {
      // When the sensor ready to calibrate, activate calibrate button
      return true;
    } else if ((message == "ExitDone" || message == "CalRemain") && btnType == "Enter") {
      // When the sensor is not enter to calibrate, activate enter button
      return true;
    } else if (message == "CalError" && (btnType == "Cal" || btnType == "Exit")) {
      // The Arduino there should allow user to CALPH / CALEC / CALDO again
      // When the sensor failed to calibrate, activate calibrate button to allow Calibrate or Exit
      return true;
    } else if ((message == "CalDone7.0" && (btnType == "Exit")) || (message == "CalDone4.0" && (btnType == "Exit"))) {
      // When the sensor calibrate success, only remain the exit button
      return true;
    } else if ((message == "CalDone") && (btnType == "Exit" || btnType == "Cal")) {
      return true;
    } else if (message == "OnExit" && (btnType == "Exit")) {
      return true;
    }

    return false;
  }

  bool _getSensorActive(String date, String time) {
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
    if (deviceDateTime.difference(sensorLatestDateTime).inSeconds >= 15) { //Usually 15 seconds, but the emulator got time delay
      return false;
    }
    return true;
  }

  String _getMessage(String status, String sensor) {
    String message = "";
    switch (status) {
      case "EnterDone":
        message = "Enter Calibration Mode";
        break;
      case "CalDone7.0":
        message = "Calibration Success, Buffer pH 7.0, Exit to Save";
        break;
      case "CalDone4.0":
        message = "Calibration Success, Buffer pH 4.0, Exit to Save";
        break;
      case "CalDone":
        message = "Calibration Success, Exit to Save";
        break;
      case "CalError":
        message = "Calibration Failed";
        break;
      case "CalRemain":
        message = "Calibration Remained";
        break;
      case "ExitDone":
        message = "Calibration Ready/Complete";
        break;
    }
    return message;
  }
  
}

class CalibrationRow extends StatefulWidget {
  final String title;
  bool activateEnter;
  bool activateCal;
  bool activateExit;

  CalibrationRow({
    Key? key, 
    required this.title,
    required this.activateEnter,
    required this.activateCal,
    required this.activateExit,
  }) : super(key: key);

  @override
  _CalibrationRowState createState() => _CalibrationRowState();
}

class _CalibrationRowState extends State<CalibrationRow> {
  late Timer t;
  late Future<CalibrationMsg> futureMessage;
  Color colorBackground = AppColors.btnColor2;
  Color colorIcon = AppColors.pageBackground;
  Color colorBackground2 = AppColors.btnColor2;
  Color colorIcon2 = AppColors.pageBackground;
  Color colorBackground3 = AppColors.btnColor2;
  Color colorIcon3 = AppColors.pageBackground;
  bool isPhDisabled = false;
  bool isEcDisabled = false;
  bool isDoDisabled = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.title, 
              style: const TextStyle(
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          Container(
            // pH button
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: CircleAvatar(
              radius: 20.0,
              backgroundColor: widget.activateEnter? colorBackground: Colors.grey[200] , //Colors.grey[200]
              child: IconButton(
                icon: Icon(
                  Icons.exit_to_app,
                  color: widget.activateEnter? colorIcon: Colors.grey[500] 
                ), 
                onPressed: () {
                  if (widget.activateEnter && !isPhDisabled) {
                    setState(() {
                      colorBackground = Colors.yellow.shade300;
                      colorIcon = Colors.yellow.shade900;
                      colorBackground2 = AppColors.btnColor2;
                      colorIcon2 = AppColors.pageBackground;
                      colorBackground3 = AppColors.btnColor2;
                      colorIcon3 = AppColors.pageBackground;
                      isPhDisabled = true; // Disable the button when it is loading
                      isDoDisabled = false;
                      isEcDisabled = false;
                    });
                    uploadCalibration("0xb827eb9b91d2", "ENTER" + widget.title.toUpperCase(), 123);
                  }
                },
              ),
            ),
          ),
          Container(
            // EC button
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: CircleAvatar(
              radius: 20.0,
              backgroundColor: widget.activateCal? colorBackground2: Colors.grey[200],
              child: IconButton(
                icon: Icon(
                  Icons.memory,
                  color: widget.activateCal? colorIcon2: Colors.grey[500]
                ), 
                onPressed: () {
                  if (widget.activateCal && !isEcDisabled) {
                    setState(() {
                      colorBackground2 = Colors.yellow.shade300;
                      colorIcon2 = Colors.yellow.shade900;
                      colorBackground = AppColors.btnColor2;
                      colorIcon = AppColors.pageBackground;
                      colorBackground3 = AppColors.btnColor2;
                      colorIcon3 = AppColors.pageBackground;
                      isPhDisabled = false;
                      isDoDisabled = false;
                      isEcDisabled = true;
                    });
                    uploadCalibration("0xb827eb9b91d2", "CAL" + widget.title.toUpperCase(), 123);
                  }
                },
              ),
            ),
          ),
          Container(
            // DO button
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: CircleAvatar(
              radius: 20.0,
              backgroundColor: widget.activateExit? colorBackground3: Colors.grey[200],
              child: IconButton(
                icon: Icon(
                  Icons.launch,
                  color: widget.activateExit? colorIcon3: Colors.grey[500]
                ), 
                onPressed: () {
                  if (widget.activateExit && !isDoDisabled) {
                    setState(() {
                      colorBackground2 = AppColors.btnColor2;
                      colorIcon2 = AppColors.pageBackground;
                      colorBackground = AppColors.btnColor2;
                      colorIcon = AppColors.pageBackground;
                      colorBackground3 = Colors.yellow.shade300;
                      colorIcon3 = Colors.yellow.shade900;
                      isPhDisabled = false;
                      isDoDisabled = true;
                      isEcDisabled = false;
                      widget.activateCal = false;
                    });
                    uploadCalibration("0xb827eb9b91d2", "EXIT" + widget.title.toUpperCase(), 123);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CalibrationMsg {
  final int statusCode;
  final CalMessage messages;

  CalibrationMsg({required this.messages, required this.statusCode});

  factory CalibrationMsg.fromJson(Map<String, dynamic> json) {
    return CalibrationMsg(
      statusCode: json["statusCode"],
      messages: CalMessage.fromJson(json["data"]),
    );
  }
}

class CalMessage {
  String message;
  String command;
  double ph;
  double ec;
  double dOxygen;
  String date;
  String time;

  CalMessage({
    required this.message,
    required this.command,
    required this.ph,
    required this.ec,
    required this.dOxygen,
    required this.date,
    required this.time,
  });

  factory CalMessage.fromJson(Map<String, dynamic> parsedJson) {
    return CalMessage(
      message: parsedJson['message'],
      command: parsedJson['command'],
      ph: parsedJson['pH'],
      ec: parsedJson['EC'],
      dOxygen: parsedJson['DO'],
      date: parsedJson['date'],
      time: parsedJson['time']
    );
  }
}