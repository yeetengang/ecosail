import 'dart:convert';

import 'package:ecosail/others/colors.dart';
import 'package:ecosail/pages/login_page.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:ecosail/widgets/reponsive_text.dart';
import 'package:ecosail/widgets/responsive.dart';
import 'package:ecosail/widgets/responsive_btn.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<String> registerUser(String email, String password) async {
  String datetime = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
  String status = "User Register";

  final response = await http.post(
    Uri.parse('https://k3mejliul2.execute-api.ap-southeast-1.amazonaws.com/ecosail_stage/Ecosail_lambda2'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, String>{
      'email': email,
      'password': password,
      'datetime': datetime, //'12/01/2022 14:14:05'
      'status': status,
    }),
  );
  if (response.statusCode == 200) {
    //return LocationData.fromJson(jsonDecode(response.body));
    return RegistrationMsg.fromJson(jsonDecode(response.body)).message;
  }else {
    return "";
  }
}

class RegistrationMsg {
  final String message;

  const RegistrationMsg({
    required this.message,
  });

  factory RegistrationMsg.fromJson(Map<String, dynamic> json) {
    return RegistrationMsg(message: json['data'] as String);
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({ Key? key }) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    if (screenSize.height < 600) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Color.fromARGB(255, 118, 197, 233),
        body: CustomScrollView(
          physics: ClampingScrollPhysics(),
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: _buildContent(),
            )
          ],
        ),
      );
    }
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Color.fromARGB(255, 118, 197, 233),
      body: _buildContent(),
    );
  }

  SafeArea _buildContent() {
    return SafeArea(
      child: Align(
        alignment: Alignment.center,
        child: Container(
          width: !Responsive.isMobile(context)? 420.0: double.infinity,
          margin: EdgeInsets.all(24.0),
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AppLargeText(
                text: "SIGN UP", 
                color: Color.fromRGBO(0, 180, 216, 1),
                size: 40,
              ),
              Container(
                width: 12,
                height: 12,
                margin: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: AppColors.btnColor1,
                  borderRadius: BorderRadius.circular(20.0)
                ),
              ),
              _generateFormContent('EMAIL', emailController),
              _generateFormContent('PASSWORD', passwordController),
              ResponsiveButton(
                onTap: () async {
                  if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                    showToast("Registering...");
                    String message = await registerUser(emailController.text, passwordController.text);
                    showToast(message);
                  } else {
                    showToast("Email & Password cannot be empty");
                  }
                }, 
                width: 200.0,
                widget: Container(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "SIGN UP", 
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 20.0,
                      letterSpacing: 0.0
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already registered?  "),
                  ResponsiveText(
                    text: "Click to Login", 
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context, 
                        PageRouteBuilder(pageBuilder: (_, __, ___) => LoginPage()), //use MaterialPageRoute for animation
                      );
                    }
                  ),
                ],
              )
            ],
          ),
        ),
      )
    );
  }

  TextFormField _generateFormContent(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        isDense: true,
        labelText: label,
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

  void showToast(String text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
    );
  }
}