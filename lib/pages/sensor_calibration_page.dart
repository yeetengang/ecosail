import 'package:ecosail/bottom_nav_screen.dart';
import 'package:ecosail/gateway.dart';
import 'package:ecosail/others/colors.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:ecosail/widgets/inner_app_bar.dart';
import 'package:flutter/material.dart';

class SensorCalibratePage extends StatefulWidget {
  final List<Data> dataList;

  const SensorCalibratePage({required this.dataList});

  @override
  _SensorCalibratePageState createState() => _SensorCalibratePageState();
}

class _SensorCalibratePageState extends State<SensorCalibratePage> {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    List<String> sensors = ['pH', 'EC', 'DO', 'Tur'];
    
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

  SliverToBoxAdapter _buildBody(double screenHeight, List<String> sensors, BuildContext context) {
    List<String> label = ['Sensor', 'Enter', 'Calibrate', 'Exit'];
    List<double> left = [10.0, 10.0, 40.0, 18.0];
    List<double> right = [20.0, 0.0, 18.0, 16.0];

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

    List<Container> _generateRows(String parameters){
      List<Container> containers = [];
      List<IconData> actionIcons = [Icons.exit_to_app, Icons.memory, Icons.launch];
      List<double> padding = [20.0, 20.0, 20.0];

      containers.add(
        Container(
          padding: EdgeInsets.symmetric(horizontal: 28.0),
          child: Text(
            parameters, 
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
        )
      );

      actionIcons.asMap().forEach((index, icon) {
        containers.add(
          Container(
            padding: EdgeInsets.symmetric(horizontal: padding[index]),
            child: CircleAvatar(
              radius: 20.0,
              backgroundColor: Colors.grey[200],
              child: IconButton(
                icon: Icon(icon, color: Colors.grey[500],), 
                onPressed: () {

                },
              ),
            ),
          )
        );
      });
      return containers;
    }

    List<Container> _generateTable(List<String> sensors) {
      List<Container> containers = [];
    
      containers.add(
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: _generateFirstRow(label),
          ),
        ),
      );

      sensors.asMap().forEach((index, parameters) {
        containers.add(
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _generateRows(parameters),
            ),
          ),
        );
      });

      return containers;
    }

    return SliverToBoxAdapter(
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
                  'Sailboat Name\n' + widget.dataList[0].boatID, 
                  style: TextStyle(
                    fontWeight: FontWeight.w900, 
                    fontSize: 20.0,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Row(
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
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _generateTable(sensors),
              ),
              Container(
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
              ),
            ],
          ),
        ),
      )
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