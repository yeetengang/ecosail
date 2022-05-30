import 'package:ecosail/others/colors.dart';
import 'package:flutter/material.dart';

class FormContent extends StatelessWidget {
  final String label; 
  final TextEditingController controller;
  final bool obscure;
  final Function()? onTap;
  final int? maxLength;

  const FormContent({
    required this.label,
    required this.controller, 
    required this.obscure,
    this.onTap,
    this.maxLength,
    Key? key 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool eyeIcons = false;
    if (label.contains("PASSWORD") ) {
      eyeIcons = true; //This Icon Button only available for PASSWORD
    }
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
      obscureText: eyeIcons? obscure: false,
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
        suffixIcon: eyeIcons? IconButton(
          padding: const EdgeInsets.only(top: 26),
          color: AppColors.mainColor,
          onPressed: onTap, 
          icon: Icon(
            obscure? Icons.visibility_off: Icons.visibility,
          )
        ) : null,
        labelStyle: const TextStyle(
          color: Colors.black
        ),
        floatingLabelStyle: const TextStyle(
          color: Colors.black
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.shade700
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.shade700
          ),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      cursorColor: Colors.grey[700],
      style: const TextStyle(
        color: Colors.black,
        height: 2.0
      ),
    );
  }
}