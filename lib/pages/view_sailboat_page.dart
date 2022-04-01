import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecosail/others/colors.dart';
import 'package:ecosail/pages/sailboat_register_page.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:ecosail/widgets/inner_app_bar.dart';
import 'package:ecosail/widgets/responsive_btn.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../bottom_nav_screen.dart';
import '../gateway.dart';
import '../sailboat.dart';

Future<Sailboat> getSailboats(String userID) async{
  String status = "Get sailboat";

  final response = await http.post(
    Uri.parse('https://k3mejliul2.execute-api.ap-southeast-1.amazonaws.com/ecosail_stage/Ecosail_lambda2'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, String>{
      'userID': userID.toString(),
      'status': status,
    }),
  );
  if (response.statusCode == 200) {
    return Sailboat.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to display sailboat.');
  }
}

Future<String> deleteSailboat(String userID, String cloudID) async {
  String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  String datetime = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
  String status = "Delete sailboat";

  print(cloudID);

  final response = await http.post(
    Uri.parse('https://k3mejliul2.execute-api.ap-southeast-1.amazonaws.com/ecosail_stage/Ecosail_lambda2'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, String>{
      'userID': userID.toString(),
      'status': status,
      'cloudID': cloudID,
    }),
  );
  if (response.statusCode == 200) {
    return 'Sailboat deleted, now refreshing list...';
  } else {
    return "Failed to delete sailboat";
  }
}

class ViewSailboat extends StatefulWidget {
  final List<Data> dataList;
  final String userID;
  final String userEmail;
  const ViewSailboat({ Key? key, required this.dataList, required this.userID, required this.userEmail }) : super(key: key);

  @override
  _ViewSailboatState createState() => _ViewSailboatState();
}

class _ViewSailboatState extends State<ViewSailboat> {
  Timer t = Timer(Duration(milliseconds: 5000), () {});
  CarouselController sliderController = CarouselController();
  late Future<Sailboat> futureSailboatList;
  int activeIndex = 0;
  int parameters = 0;

  @override
  void initState() {
    super.initState();
    futureSailboatList = getSailboats(widget.userID);
    Timer.periodic(Duration(milliseconds: 5000), (t) {
      setState(() {
        futureSailboatList = getSailboats(widget.userID);
      });
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
          _buildBody(screenSize.height, screenSize.width),
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
              Icon(Icons.sailing, color: AppColors.btnColor2, size: 30.0,),
              SizedBox(height: 20.0),
              AppLargeText(text: 'Registered Sailboat', color: AppColors.bigTextColor, size: 26,),
              Expanded(child: Container()),
            ],
          ),
        ),
      )
    );
  }

  SliverToBoxAdapter _buildBody(double screenHeight, double screenWidth) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FutureBuilder<Sailboat>(
            future: futureSailboatList, //user ID
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                parameters = snapshot.data!.sailboats.length;
                return CarouselSlider.builder(
                  options: CarouselOptions(
                    height: screenHeight * 0.45,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: false,
                    viewportFraction: 0.65,
                    initialPage: 0,
                    onPageChanged: (index, reason) {
                      setState(() {
                        activeIndex = index;
                      });
                    },
                  ),
                  carouselController: sliderController,
                  itemCount: snapshot.data!.sailboats.length,
                  itemBuilder: (BuildContext context, itemIndex, int pageViewIndex) =>
                    Container(
                      margin: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 2,
                            offset: Offset(2, 2)
                          ),
                        ]
                      ),
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Container(
                            height: screenHeight * 0.45 * 0.35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                topRight: Radius.circular(10.0),
                              ),
                              image: DecorationImage(
                                image: AssetImage('images/sailboat_illustration_2.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 16.0,
                            left: 20.0,
                            child: Icon(Icons.sailing, color: AppColors.pageBackground,),
                          ),
                          Positioned(
                            top: (screenHeight * 0.45 * 0.35),
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 20.0),
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 5.0),
                                    child: Text('Sailboat Name:', style: TextStyle(fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 5.0),
                                    child: Text(snapshot.data!.sailboats[itemIndex].boatName, style: TextStyle(fontSize: 12.0,), textAlign: TextAlign.center,),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 5.0),
                                    child: Text('Sailboat ID:', style: TextStyle(fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 5.0),
                                    child: Text(snapshot.data!.sailboats[itemIndex].boatID, style: TextStyle(fontSize: 12.0,), textAlign: TextAlign.center,),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      String message = await deleteSailboat(widget.userID, snapshot.data!.sailboats[itemIndex].boatID);
                                      showToast(message);
                                    }, 
                                    icon: Icon(Icons.delete)
                                  ),
                                ],
                              ),
                            )
                          ),
                        ],
                      ),
                    ),
                );
              } 
              else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            }
          ),
          _buildChartIndicator(),
          Container(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: ResponsiveButton(
              onTap: () {
                Navigator.push(
                  context, 
                  PageRouteBuilder(pageBuilder: (_, __, ___) => SailboatRegisterPage(dataList: widget.dataList, userID: widget.userID, userEmail: widget.userEmail,)), //use MaterialPageRoute for animation
                );
              }, 
              widget: Container(
                width: screenWidth * 0.70,
                padding: EdgeInsets.all(12.0),
                child: Text(
                  "Register New Sailboat", 
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 18.0,
                    letterSpacing: 0.0
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 5.0),
            child: FloatingActionButton(
              backgroundColor: AppColors.btnColor2,
              child: Icon(
                Icons.clear, 
                color: AppColors.mainColor,
              ),
              onPressed: () {
                Navigator.pop(
                  context, 
                  PageRouteBuilder(pageBuilder: (_, __, ___) => BottomNavScreen(userID: widget.userID, userEmail: widget.userEmail,)), //use MaterialPageRoute for animation
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartIndicator() => AnimatedSmoothIndicator(
    activeIndex: activeIndex,
    count: parameters,
    effect: ExpandingDotsEffect(
      dotHeight: 8.0,
      dotWidth: 8.0,
      activeDotColor: AppColors.btnColor2,
      dotColor: AppColors.sheetFocusColor,
    ),
  );

  void showToast(String text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
    );
  }
}