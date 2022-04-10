import 'dart:convert';

import 'package:ecosail/bottom_nav_screen.dart';
import 'package:ecosail/pages/register_page.dart';
import 'package:ecosail/widgets/responsive.dart';
import 'package:flutter/material.dart';

import '../others/colors.dart';
import '../widgets/app_large_text.dart';
import '../widgets/reponsive_text.dart';
import '../widgets/responsive_btn.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

Future<String> userlogin(String email, String password) async {
  String status = "User Login";

  final response = await http.post(
    Uri.parse('https://k3mejliul2.execute-api.ap-southeast-1.amazonaws.com/ecosail_stage/Ecosail_lambda2'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, String>{
      'email': email,
      'password': password,
      'status': status,
    }),
  );
  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body)).userID;
  } else {
    return "";
  }
}

class User {
  final String userID;

  const User({
    required this.userID,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(userID: json['userID'] as String);
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({ Key? key }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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
            Column(
              children: [
                AppLargeText(
                  text: "LOGIN", 
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
              ],
            ),
            _generateFormContent('EMAIL', emailController),
            Column(
              children: [
                _generateFormContent('PASSWORD', passwordController),
                Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 12.0),
                child: ResponsiveText(
                  text: "FORGOT PASSWORD",
                  isResponsive: true,
                  testAlign: TextAlign.right,
                  onTap: () {},
                ),
              ),
              
              ],
            ),
            ResponsiveButton(
              onTap: () async {
                if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                  showToast("Logging In...");
                  String userID = await userlogin(emailController.text, passwordController.text);
                  if (userID!="0"){
                    Navigator.pop(context);
                    Navigator.push(
                      context, 
                      PageRouteBuilder(pageBuilder: (_, __, ___) => BottomNavScreen(userID: userID, userEmail: emailController.text,)), //use MaterialPageRoute for animation
                    );
                  } else {
                    showToast("User does not exist!");
                  }
                } else {
                  showToast("Email & Password cannot be empty");
                }
              }, 
              width: 200.0,
              widget: Container(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  "LOGIN", 
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
                Text("New to Ecosail?  "),
                ResponsiveText(
                  text: "Sign Up Now", 
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context, 
                      PageRouteBuilder(pageBuilder: (_, __, ___) => RegisterPage()), //use MaterialPageRoute for animation
                    );
                  }
                )
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