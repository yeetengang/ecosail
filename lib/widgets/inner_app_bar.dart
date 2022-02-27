import 'package:ecosail/gateway.dart';
import 'package:ecosail/others/colors.dart';
import 'package:ecosail/pages/sensor_calibration_page.dart';
import 'package:ecosail/pages/user_profile_page.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:flutter/material.dart';

class InnerAppBar extends StatefulWidget with PreferredSizeWidget{
  List<Data>? dataList;
  String? currentPage;

  InnerAppBar({this.dataList, this.currentPage});

  @override
  _InnerAppBarState createState() => _InnerAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _InnerAppBarState extends State<InnerAppBar> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
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
            AppLargeText(text: "Ecosail"),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }
}