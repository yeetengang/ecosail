import 'package:flutter/material.dart';

class AppParaText extends StatelessWidget {
  double size;
  final String text;
  final Color color;

  //This accept value parameter when being called
  AppParaText({ 
      Key? key, 
      this.size = 14, //Default Size 
      required this.text, 
      this.color = Colors.white //Default color is black
    }
  ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 10,
      style: TextStyle(
        color: color,
        fontSize: size,
        overflow: TextOverflow.visible,
        fontWeight: FontWeight.normal,
      ),
    );
  }
}