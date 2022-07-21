
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:ecosail/bottom_nav_screen.dart';
import 'package:ecosail/others/show_toast.dart';
import 'package:ecosail/pages/forgot_password_page.dart';
import 'package:ecosail/pages/register_page.dart';
import 'package:ecosail/widgets/form_content.dart';
import 'package:ecosail/widgets/responsive.dart';
import 'package:flutter/material.dart';

import '../others/colors.dart';
import '../widgets/app_large_text.dart';
import '../widgets/reponsive_text.dart';
import '../widgets/responsive_btn.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<String> userlogin(String email, String password) async {
  String status = "User Login";

  /*final response = await http.post(
    Uri.parse('https://k3mejliul2.execute-api.ap-southeast-1.amazonaws.com/ecosail_stage/Ecosail_lambda2'),
    headers: <String, String>{
      'Accept': 'application/json',
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
  }*/

  final authDetails = AuthenticationDetails(
    username: email,
    password: password,
  );

  final userPool = CognitoUserPool(
    'ap-southeast-1_LPPgObixx', 
    '2fm8sfscl0uoah7eac3r7slabe'
  );

  final cognitoUser = CognitoUser(email, userPool);

  CognitoUserSession? session;
  try {
    session = await cognitoUser.authenticateUser(authDetails);
    //print(session?.getAccessToken().getJwtToken());
    //print(session?.getAccessToken().getSub()); // Get userID
    //print(session?.getAccessToken().getExpiration()); // Get token expiration time
    //int? test = session?.getAccessToken().getExpiration();

    //print(DateTime.fromMillisecondsSinceEpoch(test! * 1000));
    //Return userID
    return session!.getAccessToken().getSub().toString();
  } on CognitoUserNewPasswordRequiredException {
    // handle New Password challenge
  } on CognitoUserMfaRequiredException {
    // handle SMS_MFA challenge
  } on CognitoUserSelectMfaTypeException {
    // handle SELECT_MFA_TYPE challenge
  } on CognitoUserMfaSetupException {
    // handle MFA_SETUP challenge
  } on CognitoUserTotpRequiredException {
    // handle SOFTWARE_TOKEN_MFA challenge
  } on CognitoUserCustomChallengeException {
    // handle CUSTOM_CHALLENGE challenge
  } on CognitoUserConfirmationNecessaryException {
    // handle User Confirmation Necessary
  } on CognitoClientException {
    // handle Wrong Username and Password and Cognito Client
    return "0";
  } catch (e) {
    // Unexpected error occured
    return "0";
  }
  
  return "";
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
  bool obscure = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromARGB(255, 118, 197, 233),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _buildContent(screenSize),
          )
        ],
      ),
    );
  }

  SafeArea _buildContent(Size screenSize) {
    return SafeArea(
      child: Align(
        alignment: Alignment.center,
        child: Container(
          height: screenSize.height * 0.9,
        width: !Responsive.isMobile(context)? 420.0: double.infinity,
        margin: const EdgeInsets.all(24.0),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                  color: const Color.fromRGBO(0, 180, 216, 1),
                  size: 40,
                ),
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: AppColors.btnColor1,
                    borderRadius: BorderRadius.circular(20.0)
                  ),
                ),
              ],
            ),
            FormContent(
              label: 'EMAIL',
              controller: emailController,
              obscure: false, // No need to show this
              onTap: () {

              },  
            ),
            Column(
              children: [
                FormContent(
                  label: 'PASSWORD', 
                  controller: passwordController, 
                  obscure: obscure, 
                  onTap: () {
                    setState(() {
                      obscure = !obscure;
                    });
                  }
                ),
                Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 12.0),
                child: ResponsiveText(
                  text: "FORGOT PASSWORD",
                  isResponsive: true,
                  testAlign: TextAlign.right,
                  onTap: () {
                    Navigator.push(
                      context, 
                      PageRouteBuilder(pageBuilder: (_, __, ___) => ForgotPasswordPage()), //use MaterialPageRoute for animation
                    );
                  },
                ),
              ),
              
              ],
            ),
            ResponsiveButton(
              onTap: () async {

                //emailController.text = "yeetengang@gmail.com";
                //passwordController.text = "12345Ayt@601";

                if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                  showToast("Logging In...");

                  String userID = await userlogin(emailController.text, passwordController.text);
                  //String userID = "a65259f2-e752-4a9d-8470-78a02e6cd533"; // Later change back to dynamic
                  if (userID!="0"){
                    Navigator.pop(context);
                    Navigator.push(
                      context, 
                      PageRouteBuilder(pageBuilder: (_, __, ___) => BottomNavScreen(userID: userID, userEmail: emailController.text,)), //use MaterialPageRoute for animation
                    );
                  } else {
                    showToast("User does not exist or password incorrect!");
                  }
                  print(userID);
                } else {
                  showToast("Email & Password cannot be empty");
                }
              }, 
              width: 200.0,
              widget: Container(
                padding: const EdgeInsets.all(12.0),
                child: const Text(
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
                const Text("New to Ecosail?  "),
                ResponsiveText(
                  text: "Sign Up Now", 
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context, 
                      PageRouteBuilder(pageBuilder: (_, __, ___) => const RegisterPage()), //use MaterialPageRoute for animation
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
}