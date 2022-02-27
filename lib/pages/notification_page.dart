import 'dart:convert';

import 'package:ecosail/notification.dart';
import 'package:ecosail/others/colors.dart';
import 'package:ecosail/pages/notification_details_page.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:ecosail/widgets/inner_app_bar.dart';
import 'package:ecosail/widgets/reponsive_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


// Use POST method to get sensor Data
Future<NotificationDetails> getNotification(String userID) async{
  String status = "Notification";

  final response = await http.post(
    Uri.parse('https://k3mejliul2.execute-api.ap-southeast-1.amazonaws.com/ecosail_stage/Ecosail_lambda2'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, String>{
      'userID': userID.toString(),
      'boatID': "0xb827eb9b91d2",
      'status': status,
    }),
  );
  
  if (response.statusCode == 200) {
    return NotificationDetails.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load gateway');
  }
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({ Key? key }) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<NotificationDetails> futureNotification;

  @override
  void initState() {
    super.initState();
    futureNotification = getNotification("123456");
    /*Timer.periodic(Duration(milliseconds: 5000), (t) {
      setState(() {
        futureCalibrationMessage = getCalibrationMsg("0xb827eb9b91d2", "123456");
      });
    });*/
  }
  
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: PreferredSize(
        preferredSize: Size(screenSize.width, 60),
        child: InnerAppBar(),
      ),
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: <Widget>[
          _buildHeader(),
          _buildBody(),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0, bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppLargeText(text: 'Notification', color: Colors.blue.shade100,size: 26,),
            Text('Pollution & Sailboat', style: TextStyle(height: 1.6, color: Colors.grey[300], fontWeight: FontWeight.w500),),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildBody() {
    return SliverToBoxAdapter(
      child: FutureBuilder<NotificationDetails>(
        future: futureNotification,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              shrinkWrap: true,
              primary: false,
              itemCount: snapshot.data!.data.length,
              itemBuilder: (BuildContext context, int Index) {
                if (snapshot.data!.data[Index].type == "Water Pollution") {
                  return NotificationCard(
                    type: snapshot.data!.data[Index].type,
                    color: Colors.red,
                    details: snapshot.data!.data[Index]
                  );
                } else if (snapshot.data!.data[Index].type == "Sensors & Sailboat") {
                  return NotificationCard(
                    type: snapshot.data!.data[Index].type,
                    color: Colors.amber.shade600,
                    details: snapshot.data!.data[Index]
                  );
                } else if (snapshot.data!.data[Index].type == "Navigation Complete") {
                  return NotificationCard(
                    type: snapshot.data!.data[Index].type,
                    color: Colors.blue.shade300,
                    details: snapshot.data!.data[Index]
                  );
                }
                return Container();
              }
            );
          }
          else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          // By default, show a loading spinner.
          //return const CircularProgressIndicator();
          return Container();
        }
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String type;
  final Color color;
  final Details details;

  const NotificationCard({ 
    Key? key,
    required this.type,
    required this.color,
    required this.details,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130.0,
      margin: const EdgeInsets.only(left: 30.0, right: 30.0, top: 12.0,),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0),
                bottomLeft: Radius.circular(8.0)
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    type,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Boat: ' + details.boatName + '\nID: ' + details.boatID,
                      style: TextStyle(
                        height: 1.5
                      ),
                    ),
                  ),
                  ResponsiveText(
                    text: 'See the details',
                    colors: Colors.blueAccent.shade700,
                    onTap: () {
                      Navigator.push(
                        context, 
                        PageRouteBuilder(pageBuilder: (_, __, ___) => 
                          NotificationDetailsPage(
                            title: type,
                            details: details,
                          ),
                        ), //use MaterialPageRoute for animation
                      );
                    }
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20.0, right: 20.0),
            child: Text(
              details.dayName.split("day")[0] + " " + DateFormat.jm().format(DateFormat("hh:mm:ss").parse(details.datetime.split(" ")[1])),
              style: TextStyle(
                color: Colors.blueAccent[700],
                fontWeight: FontWeight.w500,
                letterSpacing: -0.5,
              ),
            ),
          )
        ],
      ),
    );
  }

  bool _checkValue(double? sensorData, String sensorName) {
    double sensorLowerSecondLimit = 0.0; //Lowest Value
    double sensorUpperSecondLimit = 0.0; //Highest Value
    switch (sensorName) {
      case 'temp':
        sensorLowerSecondLimit = 0.0;
        sensorUpperSecondLimit = 40.0;
        break;
      case 'tur':
        sensorLowerSecondLimit = 300.0;
        sensorUpperSecondLimit = 2400.0;
        break;
      case 'pH':
        sensorLowerSecondLimit = 3.0;
        sensorUpperSecondLimit = 12.0;
        break;
      case 'EC':
        sensorLowerSecondLimit = 0.0;
        sensorUpperSecondLimit = 80.0;
        break;
      case 'DO':
        // Need adjust, it is between 4 to 7 normal
        sensorLowerSecondLimit = 0.0;
        sensorUpperSecondLimit = 40.0;
        break;
    }
    
    if (sensorData! <= sensorLowerSecondLimit || sensorData >= sensorUpperSecondLimit) {
      return true;
    } 
    
    return false;
  }
}