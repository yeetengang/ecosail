import 'package:ecosail/gateway.dart';
import 'package:ecosail/others/colors.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:flutter/material.dart';

class InnerAppBar extends StatefulWidget with PreferredSizeWidget{
  List<Data>? dataList;
  String? currentPage;

  InnerAppBar({this.dataList, this.currentPage});

  @override
  _InnerAppBarState createState() => _InnerAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _InnerAppBarState extends State<InnerAppBar> {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mainColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(0, 2)
          ),
        ]
      ),
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(),
            AppLargeText(text: "Ecosail", textAlign: TextAlign.center,),
            Positioned(
              left: 15.0,
              child: IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: const Icon(Icons.arrow_back), 
                iconSize: 30.0,
                color: AppColors.btnColor2,
                onPressed: () {
                  Navigator.pop(context);
                }, 
              )
            ),
          ],
        )
      ),
    );
  }
}