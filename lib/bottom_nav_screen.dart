import 'package:ecosail/gateway.dart';
import 'package:ecosail/others/colors.dart';
import 'package:ecosail/pages/charts_page.dart';
import 'package:ecosail/pages/dashboard_page.dart';
import 'package:ecosail/pages/interpolation_maps_page.dart';
import 'package:ecosail/pages/location_page.dart';
import 'package:ecosail/pages/sailboat_register_page.dart';
import 'package:ecosail/widgets/custom_app_bar.dart';
import 'package:ecosail/widgets/responsive_btn.dart';
import 'package:flutter/material.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

class BottomNavScreen extends StatefulWidget {
  final List<Data> dataList;

  const BottomNavScreen({required this.dataList});

  @override
  _BottomNavScreenState createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {

  int currentIndex = 0;
  String _selectedSailboat = '';
  int _selectedIndex = 0;

  //A function for on click the tab
  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedSailboat = widget.dataList[0].boatID;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(screenSize.width, 60),
        child: CustomAppBar(dataList: widget.dataList,),
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
              title:Text("Dashboard"),
              icon: Icon(Icons.home)),
            BottomNavigationBarItem(
              title:Text("Location"),
              icon: Icon(Icons.location_pin)),
            BottomNavigationBarItem(
              title:Text("Charts"),
              icon: Icon(Icons.bar_chart_rounded)),
            BottomNavigationBarItem(
              title:Text("Maps"),
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
        return DashboardPage(dataList: widget.dataList);
      case 1:
        return LocationPage(dataList: widget.dataList);
      case 2:
        return ChartsPage(dataList: widget.dataList);
      case 3:
        return MapsPage();
      default:
        return DashboardPage(dataList: widget.dataList);
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
          itemCount: _sailboat(widget.dataList).length,
          itemBuilder: (BuildContext context, int Index) {
            return ListTile(
              contentPadding: EdgeInsets.only(left: 40.0),
              leading: Icon(Icons.sailing, color: AppColors.pageBackground,),
              selected: _sailboat(widget.dataList)[Index] == _selectedSailboat,
              selectedTileColor: AppColors.sheetFocusColor,
              title: Text(
                _sailboat(widget.dataList)[Index], 
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onTap: () {
                setState(() {
                  Navigator.pop(context); //Return context when tap
                  _selectedSailboat = _sailboat(widget.dataList)[Index];
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
}