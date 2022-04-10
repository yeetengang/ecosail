import 'dart:async';
import 'dart:convert';

import 'package:ecosail/data/data.dart';
import 'package:ecosail/gateway.dart';
import 'package:ecosail/others/colors.dart';
import 'package:ecosail/others/show_toast.dart';
import 'package:ecosail/pages/notification_page.dart';
import 'package:ecosail/pages/sailboat_register_page.dart';
import 'package:ecosail/sailboat.dart';
import 'package:ecosail/widgets/NavigationDrawerWidget.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:ecosail/widgets/custom_app_bar.dart';
import 'package:ecosail/widgets/get_pages.dart';
import 'package:ecosail/widgets/notification_api.dart';
import 'package:ecosail/widgets/reponsive_text.dart';
import 'package:ecosail/widgets/responsive.dart';
import 'package:ecosail/widgets/responsive_btn.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:http/http.dart' as http;

// Use POST method to get sensor Data
Future<Gateway> getSensorData(String userID, String boatID) async{
  String status = "Get All";

  final response = await http.post(
    Uri.parse('https://k3mejliul2.execute-api.ap-southeast-1.amazonaws.com/ecosail_stage/Ecosail_lambda2'),
    headers: <String, String>{
      'Content-Type': 'application/json',
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
  final String userID;
  final String userEmail;

  const BottomNavScreen({Key? key, required this.userID, required this.userEmail});

  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {

  int currentIndex = 0;
  String _selectedSailboat = '';
  String _selectedSailboatName = '';
  late Future<String> _future;
  late Timer t = Timer(Duration(milliseconds: 10), () {});
  late Future<Gateway> futureGateway;
  late List<Data> datalist;
  late List<Boat> boatList;
  late Future<Sailboat> futureSailboat;
  GlobalKey<ScaffoldState> _key = GlobalKey();

  //A function for on click the tab
  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    futureGateway = getSensorData(widget.userID, _selectedSailboat);
    Timer.periodic(Duration(milliseconds: 5000), (t) {
        setState(() {
          futureGateway = getSensorData(widget.userID, _selectedSailboat);
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
      PageRouteBuilder(pageBuilder: (_, __, ___) => NotificationPage(userID: widget.userID, boatID: _selectedSailboat,)), //use MaterialPageRoute for animation
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
                print("Current Boat: " + _selectedSailboat);

                if (datalist[0].boatID.length > 0 && _selectedSailboat == '') {
                  _selectedSailboat = datalist[0].boatID[0];
                  _selectedSailboatName = datalist[0].boatName[0];
                }
                print(datalist[0].boatID.length);
                if (datalist[0].boatID.length == 0) {
                  _selectedSailboat = '';
                  _selectedSailboatName = '';
                }

                if (_selectedSailboat!= '') {
                  // If there is sailboat selected
                  bool isActive = _getSensorActive(datalist[0].date, datalist[0].time);
                  _checkSensorValue(datalist, isActive);
                }
                //print("test");
                return Scaffold(
                  key: _key,
                  drawer: Responsive.isTablet(context) && kIsWeb? NavigationDrawerWidget( //Drawer only take effect if it is a web version and is tablet size only
                    widgetList: _buildNavigationBar(screenSize, datalist[0].boatID),
                  ): null,
                  appBar: PreferredSize(
                    preferredSize: Size(screenSize.width, 60),
                    child: CustomAppBar(
                      dataList: datalist, 
                      userID: widget.userID, 
                      userEmail: widget.userEmail, 
                      boatID: _selectedSailboat, 
                      currkey: _key,
                      dropDownWidget: kIsWeb? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: AppColors.btnColor2,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                        child: DropdownButton(
                          value: _selectedSailboat, //This is the current sailboat ID
                          isDense: true,
                          elevation: 0,
                          icon: Icon(Icons.sailing, color: AppColors.pageBackground,),
                          items: datalist[0].boatID.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedSailboat = newValue!;
                              showToast("Refreshing sailboat collected data...");
                            });
                          }
                        ),
                      ): Container(),
                  ),
                  ),
                  body: Responsive.isDesktop(context)? Row( //Is Desktop Size then can show the row version, else show pages only as mobile and tablet got bottom nav bar
                    children: [
                      Container(
                        width: screenSize.width * 0.2,
                        color: AppColors.btnColor2,
                        alignment: Alignment.center,
                        child: Center(
                          child: ListView(
                            shrinkWrap: true,
                            controller: ScrollController(),
                            children: _buildNavigationBar(screenSize, datalist[0].boatID),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: screenSize.width*0.8,
                        child: getPages(currentIndex, datalist, _selectedSailboat, _selectedSailboatName, widget.userID),
                      ),
                    ],
                  ) : getPages(currentIndex, datalist, _selectedSailboat, _selectedSailboatName, widget.userID),
                  bottomNavigationBar: !kIsWeb? Container( //Show bottom Navigation Bar only if not a web version
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
                  ) : null,
                  floatingActionButton: !Responsive.isDesktop(context) && !kIsWeb ? FloatingActionButton(
                    child: Icon(
                      Icons.sailing, 
                      color: AppColors.pageBackground,
                    ),
                    backgroundColor: AppColors.btnColor2,
                    onPressed: showSailboatSheet,
                  ): null,
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

  List<Widget> _buildNavigationBar(Size screenSize, List<String> boatID) {
    return [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.0,
            height: 100.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(ecosailContent.logoUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10.0,),
          AppLargeText(
            text: "Ecosail",
            color: AppColors.pageBackground,
          ),
        ],
      ),
      const SizedBox(height: 30.0,),
      Container(
        height: screenSize.height * 0.35,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ResponsiveText(
              text: "Dashboard",
              colors: currentIndex == 0? AppColors.mainColor:Colors.black,
              onTap: () {
                setState(() {
                  currentIndex = 0;
                });
              },
            ),
            ResponsiveText(
              text: "Location",
              colors: currentIndex == 1? AppColors.mainColor:Colors.black,
              onTap: () {
                setState(() {
                  currentIndex = 1;
                });
              },
            ),
            ResponsiveText(
              text: "Charts",
              colors: currentIndex == 2? AppColors.mainColor:Colors.black,
              onTap: () {
                setState(() {
                  currentIndex = 2;
                });
              },
            ),
            ResponsiveText(
              text: "Analysis",
              colors: currentIndex == 3? AppColors.mainColor:Colors.black,
              onTap: () {
                setState(() {
                  currentIndex = 3;
                });
              },
            ),
          ],
        ),
      ),
    ];
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

  /*Widget getPages(int index) {
    switch (index) {
      case 0:
        //return DashboardPage(dataList: datalist);
        return DashboardPage(dataList: datalist, selectedboatID: _selectedSailboat, selectedboatName: _selectedSailboatName,);
      case 1:
        return LocationPage(dataList: datalist, selectedboatID: _selectedSailboat, userID: widget.userID);
      case 2:
        return ChartsPage(dataList: datalist);
      case 3:
        return MapsPage();
      default:
        //return DashboardPage(dataList: datalist);
        return DashboardPage(dataList: datalist, selectedboatID: _selectedSailboat, selectedboatName: _selectedSailboatName,);
    }
  }*/

  Widget buildSheet(context, state) => Material(
    child: Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
          child: Row(
            children: [
              Text(
                datalist[0].boatID.length > 0? 'Select Sailboat': 'No Sailboat',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold,),
              ),
              Expanded(child: Container()),
              ResponsiveButton(
                widget: Icon(Icons.add), 
                colors: Colors.transparent, 
                onTap: () {
                  Navigator.push(
                    context, 
                    PageRouteBuilder(pageBuilder: (_, __, ___) => SailboatRegisterPage(dataList: datalist, userID: widget.userID, userEmail: widget.userEmail,)), //use MaterialPageRoute for animation
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
          itemCount: datalist[0].boatID.length,
          itemBuilder: (BuildContext context, int Index) {
            return ListTile(
              contentPadding: EdgeInsets.only(left: 40.0),
              leading: Icon(Icons.sailing, color: AppColors.pageBackground,),
              selected: datalist[0].boatID.length > 0 ?datalist[0].boatID[Index] == _selectedSailboat:false, //If user have sailboat, auto select the first, else no need
              selectedTileColor: AppColors.sheetFocusColor,
              title: Text(
                datalist[0].boatID[Index], 
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () {
                if (datalist[0].boatID[Index] != _selectedSailboat) {
                  showToast("Refreshing sailboat collected data...");
                }
                setState(() {
                  Navigator.pop(context); //Return context when tap
                  _selectedSailboat = datalist[0].boatID[Index];
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

  void _checkSensorValue(List<Data> dataList, bool isActive) {
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

    if (notify && isActive) {
      body = body.substring(0, body.length - 2);
      NotificationApi.showNotification(
        title: 'Sensor Level Abnormal',
        body: body + " Sensor value exceed limit",
        payload: 'test'
      );
    }
  }

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
    print('differences: ' + deviceDateTime.difference(sensorLatestDateTime).inSeconds.toString());
    if (deviceDateTime.difference(sensorLatestDateTime).inSeconds >= 15) { //Usually 15 seconds, but the emulator got time delay
      return false;
    }
    return true;
  }
}