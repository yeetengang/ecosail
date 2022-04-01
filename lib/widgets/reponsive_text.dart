import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ResponsiveText extends StatelessWidget {
  bool? isResponsive;
  double? width;
  double? height;
  TextAlign? testAlign;
  String text;
  double size;
  Color colors;
  Color textColor;
  void Function() onTap; //Temporary, will add change page function later

  ResponsiveText({ 
    Key? key,
    this.width,
    this.height,
    this.size = 14,
    this.colors = const Color(0xFF0277BD), //AppColors.mainColor
    this.textColor = const Color(0xFFFFFFFF),
    this.testAlign,
    required this.text,
    required this.onTap,
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
      child: Text(
        text,
        style: TextStyle(
          color: colors,
          fontWeight: FontWeight.w500,
          fontSize: size
        ),
        textAlign: testAlign,
      ),
    );
  }
}