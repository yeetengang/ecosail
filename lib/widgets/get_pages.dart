
import 'package:ecosail/WQIdata.dart';
import 'package:ecosail/gateway.dart';
import 'package:ecosail/pages/charts_page.dart';
import 'package:ecosail/pages/dashboard_page.dart';
import 'package:ecosail/pages/interpolation_maps_page.dart';
import 'package:ecosail/pages/location_page.dart';
import 'package:flutter/material.dart';

Widget getPages(
  int index, 
  List<Data> datalist, 
  String _selectedSailboat, 
  String _selectedSailboatName, 
  String userID, 
  //Future<Map<String, dynamic>> interpolationData,
  Widget generateMaps,
  String formattedDate,
  //String tripID,
  //String dateTimeForInter,
  Future<WQIData> futureWQIData
  ) 

  {
  switch (index) {
    case 0:
      //return DashboardPage(dataList: datalist);
      return DashboardPage(
        dataList: datalist, 
        selectedboatID: _selectedSailboat, 
        selectedboatName: _selectedSailboatName, 
        userID: userID, 
        formattedDate: formattedDate,
        futureWQIData: futureWQIData,
      );
    case 1:
      return LocationPage(dataList: datalist, selectedboatID: _selectedSailboat, userID: userID);
    case 2:
      List<Data> reversedList = datalist.reversed.toList();
      return ChartsPage(dataList: reversedList);
    case 3:
      //return MapsPage(generateMaps: generateMaps, interpolationData: interpolationData,); //Avoid repeatly decode so that the image won't flash
      return MapsPage(generateMaps: generateMaps, userID: userID, selectedSailboat: _selectedSailboat,);
    default:
      //return DashboardPage(dataList: datalist);
      return DashboardPage(
        dataList: datalist, 
        selectedboatID: _selectedSailboat, 
        selectedboatName: _selectedSailboatName, 
        userID: userID, 
        formattedDate: formattedDate,
        futureWQIData: futureWQIData,
      );
  }
}