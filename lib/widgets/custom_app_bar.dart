import 'package:ecosail/gateway.dart';
import 'package:ecosail/others/colors.dart';
import 'package:ecosail/pages/notification_page.dart';
import 'package:ecosail/pages/sensor_calibration_page.dart';
import 'package:ecosail/pages/user_profile_page.dart';
import 'package:ecosail/widgets/NavigationDrawerWidget.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:ecosail/widgets/responsive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget with PreferredSizeWidget{
  final List<Data> dataList;
  final String userID;
  final String userEmail;
  final String boatID;
  String? currentPage;
  GlobalKey<ScaffoldState> currkey;

  CustomAppBar({required this.dataList, this.currentPage, required this.userID, required this.userEmail, required this.boatID, required this.currkey});

  @override
  _CustomAppBarState createState() => _CustomAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.mainColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 2,
            offset: Offset(0, 2)
          ),
        ]
      ),
      child: SafeArea(
        child: Row(
          children: [
            Responsive.isTablet(context) && kIsWeb? IconButton(onPressed: () {
              //Show navigation drawer menu when it is a web and is tablet size only
              widget.currkey.currentState?.openDrawer();
            }, icon: Icon(Icons.dehaze), color: Colors.white,) : Container(),
            const SizedBox(width: 10,),
            AppLargeText(text: "Ecosail"),
            Expanded(child: Container()),
            IconButton(
              icon: Icon(Icons.memory), 
              color: AppColors.btnColor2, 
              splashColor: Colors.transparent, 
              highlightColor: Colors.transparent, 
              iconSize: 30, 
              onPressed: () {
                Navigator.push(
                  context, 
                  PageRouteBuilder(pageBuilder: (_, __, ___) => SensorCalibratePage(dataList: widget.dataList, boatID: widget.boatID, userID: widget.userID,)), //use MaterialPageRoute for animation
                );
              },
            ),
            const SizedBox(width: 3,),
            IconButton(
              icon: Icon(Icons.notifications_none), 
              color: AppColors.btnColor2, 
              splashColor: Colors.transparent, 
              highlightColor: Colors.transparent,
              iconSize: 30, 
              onPressed: () {
                Navigator.push(
                  context, 
                  PageRouteBuilder(pageBuilder: (_, __, ___) => NotificationPage(userID: widget.userID, boatID: widget.boatID,)), //use MaterialPageRoute for animation
                );
              },
            ),
            const SizedBox(width: 3,),
            IconButton(
              icon: const Icon(Icons.person), 
              color: AppColors.btnColor2, 
              splashColor: Colors.transparent, 
              highlightColor: Colors.transparent,
              iconSize: 30, 
              onPressed: () {
                Navigator.push(
                  context, 
                  PageRouteBuilder(pageBuilder: (_, __, ___) => UserProfile(dataList: widget.dataList, userID: widget.userID, userEmail: widget.userEmail,)), //use MaterialPageRoute for animation
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}