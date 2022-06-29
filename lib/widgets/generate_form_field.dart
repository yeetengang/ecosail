import 'package:ecosail/others/colors.dart';
import 'package:flutter/material.dart';

class GenerateFormField extends StatelessWidget {
  String label;
  TextEditingController controller;
  int? maxLength;
  bool? showObsure;
  void Function()? onPressedIcon;

  GenerateFormField({ 
    Key? key,
    required this.label,
    required this.controller,
    this.maxLength,
    this.showObsure = false,
    this.onPressedIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: maxLength,
      keyboardType: label.contains("CODE")? TextInputType.number: null,
      controller: controller,
      validator: (value){
        return value!.length < 6 ? 'At least 6 characters' : null;
      },
      obscureText: showObsure!,
      decoration: InputDecoration(
        helperText: label.contains("PASSWORD")? "6 Characters with Upper, Lower Cases and Symbols": "",
        helperStyle: const TextStyle(
          fontSize: 10.0
        ),
        isDense: true,
        labelText: label,
        suffixIcon: label.contains("PASSWORD") ? IconButton(
          padding: const EdgeInsets.only(top: 26),
          color: AppColors.mainColor,
          onPressed: onPressedIcon, 
          icon: Icon(
            showObsure!? Icons.visibility_off: Icons.visibility,
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