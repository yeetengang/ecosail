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
Future<NotificationDetails> getNotification(String userID, String boatID) async{
  String status = "Notification";

  final response = await http.post(
    Uri.parse('https://k3mejliul2.execute-api.ap-southeast-1.amazonaws.com/ecosail_stage/Ecosail_lambda2'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, String>{
      'userID': userID,
      'boatID': boatID,
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
  final String userID;
  final String boatID;
  const NotificationPage({ Key? key, required this.userID, required this.boatID}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<NotificationDetails> futureNotification;

  @override
  void initState() {
    super.initState();
    
  }
  
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    if (widget.boatID != "") {
      futureNotification = getNotification(widget.userID, widget.boatID,);
    }

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
          widget.boatID == ""? SliverToBoxAdapter(child: Container(),): _buildBody(),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0, bottom: 18.0),
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
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            ],
          );
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
      margin: const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 12.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 20.0,),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0)
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        type == "Water Pollution"? "Sensor Level Abnormal": type,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width < 400? 12.0: 16.0,
                          fontWeight: FontWeight.w500,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width * 0.28,
                        child: Text(
                          details.dayName.split("day")[0] + " " + DateFormat.jm().format(DateFormat("hh:mm:ss").parse(details.datetime.split(" ")[1])),
                          style: TextStyle(
                            color: Colors.blueAccent[700],
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.5,
                            fontSize: MediaQuery.of(context).size.width < 400? 12.0: 16.0,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      )
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      type == "Water Pollution"? 'Boat: ' + details.boatName + '\nID: ' + details.boatID + '\n' + details.description
                        : 'Boat: ' + details.boatName + '\nID: ' + details.boatID,
                      style: TextStyle(
                        height: 1.5,
                        fontSize: MediaQuery.of(context).size.width < 400? 12.0: 14.0
                      ),
                    ),
                  ),
                  ResponsiveText(
                    text: 'See the details',
                    colors: Colors.blueAccent.shade700,
                    size: MediaQuery.of(context).size.width < 400? 12.0: 14.0,
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
          /*
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(top: 20.0, right: 20.0),
            child: Text(
              details.dayName.split("day")[0] + " " + DateFormat.jm().format(DateFormat("hh:mm:ss").parse(details.datetime.split(" ")[1])),
              style: TextStyle(
                color: Colors.blueAccent[700],
                fontWeight: FontWeight.w500,
                letterSpacing: -0.5,
              ),
            ),
          )*/
        ],
      ),
    );
  }
}