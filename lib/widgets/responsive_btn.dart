import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ResponsiveButton extends StatelessWidget {
  bool? isResponsive;
  double? width;
  double? height;
  String? text;
  double size;
  Color colors;
  Color textColor;
  Widget widget;
  void Function() onTap; //Temporary, will add change page function later

  ResponsiveButton({ 
    Key? key,
    this.width,
    this.height,
    this.size = 22,
    this.colors = const Color(0xFF0277BD), //AppColors.mainColor
    this.textColor = const Color(0xFFFFFFFF),
    this.text = '',
    required this.onTap,
    required this.widget,
    this.isResponsive = false,
  }) : super(key: key);

  void showToast() {
    Fluttertoast.showToast(
      msg: "This is Toast Message",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: colors,
        ),
        child: widget,
      ),
    );
  }
}