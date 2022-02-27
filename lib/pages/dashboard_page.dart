import 'package:ecosail/gateway.dart';
import 'package:ecosail/others/colors.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:ecosail/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  final List<Data> dataList;
  
  const DashboardPage({required this.dataList});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with TickerProviderStateMixin{
  bool sensorActive = false;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    TabController _tabController = TabController(length: 3, vsync: this);

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: <Widget>[
          _buildHeader(screenSize.height),
          _buildDashboardPages(screenSize.height, screenSize.width, _tabController),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildHeader(double screenHeight) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0, bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppLargeText(text: 'Dashboard', color: AppColors.bigTextColor,size: 26,),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildDashboardPages(double screenHeight, double screenWidth, TabController _tabController) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                labelPadding: const EdgeInsets.only(left: 20, right: 20,),
                controller: _tabController,
                labelColor: Colors.white, 
                unselectedLabelColor: Colors.grey[350], 
                isScrollable: true, 
                indicatorSize: TabBarIndicatorSize.label,
                indicator: CircleTabIndicator(color: AppColors.btnColor2, radius: 4),
                tabs: const [
                  Tab(text: "Sensors"),
                  Tab(text: "WQI"),
                  Tab(text: "Boat"),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            height: 480.0,
            child: TabBarView(
              controller: _tabController,
              children: [
                Column(
                  children: <Widget>[
                    Flexible(
                      child: Row(
                        children: <Widget>[
                          _buildSensorCards(screenWidth, 'Temperature', widget.dataList[0].temp),
                          _buildSensorCards(screenWidth, 'Turbidity', widget.dataList[0].turbidity),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Row(
                        children: <Widget>[
                          _buildSensorCards(screenWidth, 'pH', widget.dataList[0].pH),
                          _buildSensorCards(screenWidth, 'Electrical\nConductivity', widget.dataList[0].eC),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Row(
                        children: <Widget>[
                          _buildSensorCards(screenWidth, 'Dissolved\nOxygen', widget.dataList[0].dO),
                        ],
                      ),
                    ),
                  ],
                ),
                Text('Predicted WQI data'),
                Column(
                  children: <Widget>[
                    _buildCurrentSailboatCard(screenHeight, widget.dataList[0].boatID),
                    _buildBoatDataCards(screenHeight, 'Current Location', widget.dataList),
                    _buildBoatDataCards(screenHeight, 'Wind Direction', widget.dataList)
                  ],
                ),
              ],
            ),
          )          
        ],
      ),
    );
  }

  Expanded _buildSensorCards(double screenWidth, String sensorName, double sensorData) {
    String sensorUnit;
    double sensorLowerSecondLimit = 0.0; //Lowest Value
    double sensorLowerFirstLimit = 0.0; //Second Lowest Value
    double sensorUpperFirstLimit = 0.0; //First Highest Value
    double sensorUpperSecondLimit = 0.0; //Highest Value
    Color sensorValueColor = Colors.black;

    switch (sensorName) {
      case 'Temperature':
        sensorUnit = '°C';
        sensorLowerSecondLimit = 0.0;
        sensorLowerFirstLimit = 27.03;
        sensorUpperFirstLimit = 30.13;
        sensorUpperSecondLimit = 40.0;
        break;
      case 'Turbidity':
        sensorUnit = 'NTU';
        sensorLowerSecondLimit = 300.0;
        sensorLowerFirstLimit = 1200.0;
        sensorUpperFirstLimit = 1800.0;
        sensorUpperSecondLimit = 2400.0;
        break;
      case 'pH':
        sensorUnit = '';
        sensorLowerSecondLimit = 3.0;
        sensorLowerFirstLimit = 7.63;
        sensorUpperFirstLimit = 7.82;
        sensorUpperSecondLimit = 12.0;
        break;
      case 'Electrical\nConductivity':
        sensorUnit = 'ms/cm';
        sensorLowerSecondLimit = 0.0;
        sensorLowerFirstLimit = 30.0;
        sensorUpperFirstLimit = 60.0;
        sensorUpperSecondLimit = 80.0;
        break;
      case 'Dissolved\nOxygen':
        sensorUnit = 'mg/L';
        sensorLowerSecondLimit = 0.0;
        sensorLowerFirstLimit = 3.73;
        sensorUpperFirstLimit = 6.73;
        sensorUpperSecondLimit = 40.0;
        break;
      default:
        sensorUnit = '';
    }

    if (sensorData <= sensorLowerSecondLimit || sensorData >= sensorUpperSecondLimit) {
      sensorValueColor = Colors.red;
    } else if ((sensorData >= sensorLowerSecondLimit && sensorData < sensorLowerFirstLimit) ||
     (sensorData >= sensorUpperFirstLimit && sensorData < sensorUpperSecondLimit)) {
      sensorValueColor = Colors.orange;
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: AppColors.btnColor2,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.center,
              child: Text(
                sensorName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Text(
                    'OFF / ON',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12.0,
                    ),
                  ),
                  Expanded(child: Container()),
                  _getSensorActive(widget.dataList[0].date, widget.dataList[0].time)? 
                  IconButton(
                    icon: Icon(Icons.toggle_on, size: 35.0,), 
                    color: AppColors.textColor1,
                    onPressed: () {},
                  ): IconButton(
                    icon: Icon(Icons.toggle_off, size: 35.0,), 
                    color: Colors.grey,
                    onPressed: () {},
                  ),
                ],
            ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _getSensorActive(widget.dataList[0].date, widget.dataList[0].time)? sensorData.toString() + ' ' : '0.00 ' ,
                    style: TextStyle(
                      color: _getSensorActive(widget.dataList[0].date, widget.dataList[0].time)? sensorValueColor : Colors.black,
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 5.0),
                    child: Text(
                      sensorUnit,
                      style: TextStyle(
                        color: _getSensorActive(widget.dataList[0].date, widget.dataList[0].time)? sensorValueColor : Colors.black,
                        fontSize: 14.0,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
    //print('data: ' + sensorLatestDateTime.toString());
    //print('now: ' + deviceDateTime.toString());
    print('differences: ' + deviceDateTime.difference(sensorLatestDateTime).inSeconds.toString());
    if (deviceDateTime.difference(sensorLatestDateTime).inSeconds >= 15) { //Usually 15 seconds, but the emulator got time delay
      return false;
    }
    return true;
  }
}

SizedBox _buildCurrentSailboatCard(double screenHeight, String boatID) {
  return SizedBox(
    height: screenHeight * 0.18,
    child: Row(
      children: [
        Flexible(
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 7.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0),
                  ),
                  image: DecorationImage(
                    image: AssetImage('images/sailboat.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 16.0,
                left: 20.0,
                child: Icon(Icons.sailing, color: Colors.white,),
              ),
            ],
          )
        ),
        Flexible(
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 7.0),
                decoration: BoxDecoration(
                  color: AppColors.btnColor2,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Sailboat',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('\nName: Salboat 1' + '\nID: '+ boatID, style: TextStyle(fontSize: 12.0, height: 1.5),),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    ),
  );
}

SizedBox _buildBoatDataCards(double screenHeight, String title, List<Data> dataList) {
  IconData icon = Icons.location_pin;
  String data = '';

  switch (title) {
    case 'Current Location':
      icon = Icons.location_pin;
      data = dataList[0].latitude.toStringAsFixed(4) + '° N, '+ dataList[0].longitude.toStringAsFixed(4) + '° E';
      break;
    case 'Wind Direction':
      icon = Icons.cloud;
      data = dataList[0].wind.toString() + '° N';
      break;
  }

  return SizedBox(
    height: screenHeight * 0.215,
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 7.0),
      decoration: BoxDecoration(
        color: AppColors.btnColor2,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      ),
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.215 * 0.1,),
              Text(title, style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),),
              Expanded(child: Container(),),
              Icon(icon, color: AppColors.mainColor, size: 50.0,),
              Expanded(child: Container(),),
              Text(data, style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800),),
              SizedBox(height: screenHeight * 0.215 * 0.1,),
            ],
          ),
        ],
      )
    ),
  );
}

class CircleTabIndicator extends Decoration {
  final Color color; //Color of circle
  double radius; //Radius of circle
  CircleTabIndicator({required this.color, required this.radius});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CirclePainter(color: color, radius: radius);
  }
}

class _CirclePainter extends BoxPainter {
  final Color color; //Color of circle
  double radius; //Radius of circle
  _CirclePainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    Paint _paint = Paint();
    _paint.color = color;
    _paint.isAntiAlias = true;
    //configuration allow to access the details of the element that use this paint
    final Offset circleOffset = Offset(configuration.size!.width/2 - radius/2, configuration.size!.height - radius);

    canvas.drawCircle(offset+circleOffset, radius, _paint);
  }
}