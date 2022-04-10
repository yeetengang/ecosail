import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


// Repeated functions that use to show toast
void showToast(String text) {
  Fluttertoast.showToast(
    msg: text,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.grey,
    textColor: Colors.white,
  );
}