import 'dart:async';
import 'dart:convert';

import 'package:ecosail/pages/welcome_page.dart';
import 'package:ecosail/gateway.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

// Use GET method to get sensor Data
Future<Gateway> fetchGateway() async {
  final response = await http
      .get(Uri.parse('https://k3mejliul2.execute-api.ap-southeast-1.amazonaws.com/ecosail_stage/ecosail_getsensor')
        ,headers: {"Accept":"application/json"});

  if (response.statusCode == 200) {
    return Gateway.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load gateway');
  }
}

// Use POST method to get sensor Data
Future<Gateway> getSensorData(String userID, String boatID) async{
  String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  String datetime = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Timer t;
  late Future<Gateway> futureGateway;
  List<double> tempList = <double>[];
  final testList = [12.17, 11.15, 10.02, 11.21, 13.83, 14.16, 14.30];
  late Future<String> _future;

  @override
  void initState() {
    super.initState();
    //futureGateway = fetchGateway(); //Avoid empty datalist during init
    /*futureGateway = getSensorData("123", "0xb827eb9b91d2");
    Timer.periodic(Duration(milliseconds: 5000), (t) {
      setState(() {
        futureGateway = getSensorData("123", "0xb827eb9b91d2");
      });
    });*/
    /*NotificationApi.init();
    listenNotifications();*/
  }

  @override
  void dispose() {
    t.cancel();
    super.dispose();
  }

  /*void listenNotifications() =>
    NotificationApi.onNotifications.stream.listen(onClickNotification);

  void onClickNotification(String? payload) {
    Navigator.push(
      context, 
      PageRouteBuilder(pageBuilder: (_, __, ___) => NotificationPage()), //use MaterialPageRoute for animation
    );
  }*/

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Ecosail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      /*home: Scaffold(
        appBar: AppBar(
          title: const Text('EcoSail'),
        ),
        body: Center(
          child: FutureBuilder<Gateway>(
            future: futureGateway,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                //return Text(snapshot.data!.data[1].tripID);
                //return Text(snapshot.data!.test);
                tempList.clear();
                for (var i = 0; i < 7; i++) { //7 is the number of days
                  tempList.add(snapshot.data!.data[i].temp);
                  print(snapshot.data!.data[i].temp);
                }

                return Container(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: WaterBarChart(dataList: tempList,), //
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),*/
      home: const WelcomePage(),
      /*home: Scaffold(
        body: Center(
          child: FutureBuilder<Gateway>(
            future: futureGateway,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print('test');
                //_checkSensorValue(snapshot.data!.data); // Put this here to allow every page can receive notification
                return BottomNavScreen(dataList: snapshot.data!.data,);
                //return Text(snapshot.data!.data.length.toString());
              } 
              else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            }
          ),
        ),
      ), //Bottom Nav Screen handle all the pages inside*/
    );
  }
}

/*
Future<Album> createAlbum(String title) async {
  final response = await http.post(
    Uri.parse('https://jsonplaceholder.typicode.com/albums'), //Here pu the post link
    headers: <String, String>{
      'Accept': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'title': title,
    }),
  );

  if (response.statusCode == 201) {
    // If the server did return a 201 CREATED response,
    // then parse the JSON.
    return Album.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Failed to create album.');
  }
}

class Album {
  final int id;
  final String title;

  Album({required this.id, required this.title});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'],
      title: json['title'],
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final TextEditingController _controller = TextEditingController();
  Future<Album>? _futureAlbum;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Create Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Create Data Example'),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: (_futureAlbum == null) ? buildColumn() : buildFutureBuilder(),
        ),
      ),
    );
  }

  Column buildColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextField(
          controller: _controller,
          decoration: const InputDecoration(hintText: 'Enter Title'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _futureAlbum = createAlbum(_controller.text);
            });
          },
          child: const Text('Create Data'),
        ),
      ],
    );
  }

  FutureBuilder<Album> buildFutureBuilder() {
    return FutureBuilder<Album>(
      future: _futureAlbum,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Text(snapshot.data!.title);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        return const CircularProgressIndicator();
      },
    );
  }
}*/