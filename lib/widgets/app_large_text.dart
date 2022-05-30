import 'package:flutter/material.dart';

class AppLargeText extends StatelessWidget {
  double size;
  final String text;
  final Color color;
  TextAlign? textAlign;
  TextDecoration? decoration;

  //This accept value parameter when being called
  AppLargeText({ 
      Key? key, 
      this.size = 30, //Default Size 
      required this.text, 
      this.textAlign,
      this.decoration,
      this.color = Colors.white //Default color is black
    }
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: color,
        fontSize: size,
        decoration: decoration,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}