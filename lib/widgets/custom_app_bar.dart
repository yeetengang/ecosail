import 'package:ecosail/gateway.dart';
import 'package:ecosail/others/colors.dart';
import 'package:ecosail/pages/sensor_calibration_page.dart';
import 'package:ecosail/pages/user_profile_page.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget with PreferredSizeWidget{
  final List<Data> dataList;
  String? currentPage;

  CustomAppBar({required this.dataList, this.currentPage});

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
                print(widget.currentPage);
                if (widget.currentPage != 'calibration' && widget.currentPage != 'profile') {
                  Navigator.push(
                    context, 
                    PageRouteBuilder(pageBuilder: (_, __, ___) => SensorCalibratePage(dataList: widget.dataList)), //use MaterialPageRoute for animation
                  );
                }
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
                if (widget.currentPage != 'profile' && widget.currentPage != 'calibration') {
                  //When user not locating at profile/notification/calibration page, they can do this
                  Navigator.push(
                    context, 
                    PageRouteBuilder(pageBuilder: (_, __, ___) => UserProfile(dataList: widget.dataList)), //use MaterialPageRoute for animation
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}