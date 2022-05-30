/*
import 'dart:async';
import 'dart:convert';

import 'package:ecosail/gateway.dart';
import 'package:ecosail/others/colors.dart';
import 'package:ecosail/pages/charts_page.dart';
import 'package:ecosail/pages/dashboard_page.dart';
import 'package:ecosail/pages/interpolation_maps_page.dart';
import 'package:ecosail/pages/location_page.dart';
import 'package:ecosail/pages/notification_page.dart';
import 'package:ecosail/pages/sailboat_register_page.dart';
import 'package:ecosail/widgets/custom_app_bar.dart';
import 'package:ecosail/widgets/notification_api.dart';
import 'package:ecosail/widgets/responsive_btn.dart';
import 'package:flutter/material.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:http/http.dart' as http;

// Use POST method to get sensor Data
Future<Gateway> getSensorData(String userID, String boatID) async{
  String status = "Get All";

  final response = await http.post(
    Uri.parse('https://k3mejliul2.execute-api.ap-southeast-1.amazonaws.com/ecosail_stage/Ecosail_lambda2'),
    headers: <String, String>{
      'Accept': 'application/json',
    },
    body: jsonEncode(<String, String>{
      'userID': userID.toString(),
      'status': status,
      'boatID': boatID
    }),
  );
  
  if (response.statusCode == 200) {
    return Gateway.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load gateway');
  }
}

class BottomNavScreen extends StatefulWidget {
  //final List<Data> dataList;

  const BottomNavScreen({Key? key});

  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {

  int currentIndex = 0;
  String _selectedSailboat = '';
  late Future<String> _future;
  late Timer t;
  late Future<Gateway> futureGateway;
  late List<Data> datalist;

  //A function for on click the tab
  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    futureGateway = getSensorData("123", "0xb827eb9b91d2");
    Timer.periodic(Duration(milliseconds: 5000), (t) {
      setState(() {
        futureGateway = getSensorData("123", "0xb827eb9b91d2");
      });
    });

    NotificationApi.init();
    listenNotifications();
  }

  @override
  void dispose() {
    t.cancel();
    super.dispose();
  }

  void listenNotifications() =>
    NotificationApi.onNotifications.stream.listen(onClickNotification);

  void onClickNotification(String? payload) {
    Navigator.push(
      context, 
      PageRouteBuilder(pageBuilder: (_, __, ___) => NotificationPage()), //use MaterialPageRoute for animation
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
        body: Center(
          child: FutureBuilder<Gateway>(
            future: futureGateway,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                datalist = snapshot.data!.data;
                _selectedSailboat = datalist[0].boatID;
                //_checkSensorValue(datalist);
                return Scaffold(
                  appBar: PreferredSize(
                    preferredSize: Size(screenSize.width, 60),
                    child: CustomAppBar(dataList: datalist,),
                  ),
                  body: getPages(currentIndex),
                  bottomNavigationBar: Container(
                    decoration: BoxDecoration(
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 2,
                          spreadRadius: 2,
                          offset: Offset(0, -2)
                        ),
                      ]
                    ),
                    child: BottomNavigationBar(
                      unselectedFontSize: 0,
                      selectedFontSize: 0,
                      //type: BottomNavigationBarType.shifting, //Will shift when click
                      type: BottomNavigationBarType.fixed, //No shift animation
                      backgroundColor: AppColors.mainColor,
                      onTap: onTap, 
                      currentIndex: currentIndex, 
                      selectedItemColor: AppColors.btnColor2,
                      unselectedItemColor: AppColors.btnColor2.withOpacity(0.5),
                      showSelectedLabels: false,
                      showUnselectedLabels: false,
                      elevation: 0,
                      items: [
                        BottomNavigationBarItem(
                          label:"Dashboard",
                          icon: Icon(Icons.home)),
                        BottomNavigationBarItem(
                          label:"Location",
                          icon: Icon(Icons.location_pin)),
                        BottomNavigationBarItem(
                          label:"Charts",
                          icon: Icon(Icons.bar_chart_rounded)),
                        BottomNavigationBarItem(
                          label:"Maps",
                          icon: Icon(Icons.water)),
                      ],
                    ),
                  ),
                  floatingActionButton: FloatingActionButton(
                    child: Icon(
                      Icons.sailing, 
                      color: AppColors.pageBackground,
                    ),
                    backgroundColor: AppColors.btnColor2,
                    onPressed: showSailboatSheet,
                  ),
                  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                );
              }
              else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              // By default, show a loading spinner.
              return Scaffold(
                backgroundColor: Colors.white,
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator()
                      ],
                    )
                  ],
                ),
              );
            }
          ),
        ),
    );
  }

  Future showSailboatSheet() => showSlidingBottomSheet(
    context,
    builder: (context) => SlidingSheetDialog(
      cornerRadius: 30.0,
      avoidStatusBar: true,
      snapSpec: SnapSpec(
        initialSnap: 0.5,
        snappings: [0.4, 0.5, 1],
      ),
      builder: buildSheet,
      headerBuilder: buildHeader,
    ),
  );

  Widget getPages(int index) {
    switch (index) {
      case 0:
        return DashboardPage(dataList: datalist);
      case 1:
        return LocationPage(dataList: datalist);
      case 2:
        return ChartsPage(dataList: datalist);
      case 3:
        return MapsPage();
      default:
        return DashboardPage(dataList: datalist);
    }
  }

  Widget buildSheet(context, state) => Material(
    child: Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
          child: Row(
            children: [
              Text(
                'Select Sailboat',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),
              ),
              Expanded(child: Container()),
              ResponsiveButton(
                widget: Icon(Icons.add), 
                colors: Colors.transparent, 
                onTap: () {
                  Navigator.push(
                    context, 
                    PageRouteBuilder(pageBuilder: (_, __, ___) => const SailboatRegisterPage()), //use MaterialPageRoute for animation
                  );
                }
              ),
            ],
          ),
        ),
        ListView.builder(
          padding: EdgeInsets.only(top: 5.0),
          shrinkWrap: true,
          primary: false,
          itemCount: _sailboat(datalist).length,
          itemBuilder: (BuildContext context, int Index) {
            return ListTile(
              contentPadding: EdgeInsets.only(left: 40.0),
              leading: Icon(Icons.sailing, color: AppColors.pageBackground,),
              selected: _sailboat(datalist)[Index] == _selectedSailboat,
              selectedTileColor: AppColors.sheetFocusColor,
              title: Text(
                _sailboat(datalist)[Index], 
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () {
                setState(() {
                  Navigator.pop(context); //Return context when tap
                  _selectedSailboat = _sailboat(datalist)[Index];
                });
              },
            );
          }
        ),
      ],
    )
  );

  Widget buildHeader(BuildContext context, SheetState state) => Material(
    child: Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 16.0),
          Center(
            child: Container(
              width: 32,
              height: 8,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.grey[400],
              ),
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    )
  );

  List<String> _sailboat(List<Data> dataList) {
    List<String> sailboat = [];
    int number;
    dataList.forEach((data) {
      if(!sailboat.contains(data.boatID)) {
        sailboat.add(data.boatID);
      }
    });
    return sailboat;
  }

  void _checkSensorValue(List<Data> dataList) {
    // Only the new sensor data will get notify
    double sensorLowerSecondLimit = 0.0; //Lowest Value
    double sensorUpperSecondLimit = 0.0; //Highest Value
    double sensorValue = 0.0;
    bool notify = false;
    String body = "";
    List<String> sensorName = ['Temperature', 'Turbidity', 'pH', 'EC', 'DO'];
    
    for(var i = 0; i< sensorName.length; i++) {
      switch (sensorName[i]) {
        case 'Temperature':
          sensorLowerSecondLimit = 0.0;
          sensorUpperSecondLimit = 40.0;
          sensorValue = dataList[0].temp;
          break;
        case 'Turbidity':
          sensorLowerSecondLimit = 300.0;
          sensorUpperSecondLimit = 2400.0;
          sensorValue = dataList[0].turbidity;
          break;
        case 'pH':
          sensorLowerSecondLimit = 3.0;
          sensorUpperSecondLimit = 12.0;
          sensorValue = dataList[0].pH;
          break;
        case 'EC':
          sensorLowerSecondLimit = 0.0;
          sensorUpperSecondLimit = 80.0;
          sensorValue = dataList[0].eC;
          break;
        case 'DO':
          // Need adjust, it is between 4 to 7 normal
          sensorLowerSecondLimit = 0.0;
          sensorUpperSecondLimit = 40.0;
          sensorValue = dataList[0].dO;
          break;
      }

      if (sensorValue <= sensorLowerSecondLimit || sensorValue > sensorUpperSecondLimit) {
        // In Development stage usually turbidity will be notify
        notify = true;
        body += sensorName[i] + ", ";
      }
    }

    if (notify) {
      body = body.substring(0, body.length - 2);
      NotificationApi.showNotification(
        title: 'Sensor Level Abnormal',
        body: body + " Sensor value exceed limit",
        payload: 'test'
      );
    }
  }
}
*/