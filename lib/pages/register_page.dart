import 'dart:convert';

import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:ecosail/others/colors.dart';
import 'package:ecosail/others/show_toast.dart';
import 'package:ecosail/pages/login_page.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:ecosail/widgets/generate_form_field.dart';
import 'package:ecosail/widgets/reponsive_text.dart';
import 'package:ecosail/widgets/responsive.dart';
import 'package:ecosail/widgets/responsive_btn.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

Future<String> registerUser(String email, String password) async {
  //String datetime = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
  //String status = "User Register";

  final userPool = CognitoUserPool(
    'ap-southeast-1_LPPgObixx', 
    '2fm8sfscl0uoah7eac3r7slabe'
  );

  try {
    var data = await userPool.signUp(email, password);
    //print(data.user.username); //User Email
    //print(data.userSub); //User name in cognito, unique
    return data.userSub! + " " + "Registered Successfully!";
  } on CognitoClientException catch (e) {
    return e.message!;
  } catch (e) {
    //The catch should avoid the application from crash (Not Yet)
    print(e);
  }

  /*final response = await http.post(
    Uri.parse('https://k3mejliul2.execute-api.ap-southeast-1.amazonaws.com/ecosail_stage/Ecosail_lambda2'),
    headers: <String, String>{
      'Accept': 'application/json',
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
  }*/

  return "";
}

Future<bool> verifyUserEnabled(String email, String password) async {
  String status = "Check Email Enabled";
  final response = await http.post(
    Uri.parse('https://k3mejliul2.execute-api.ap-southeast-1.amazonaws.com/ecosail_stage/Ecosail_lambda2'),
    headers: <String, String>{
      'Accept': 'application/json',
    },
    body: jsonEncode(<String, String>{
      'email': email,
      'status': status,
    }),
  );
  return jsonDecode(response.body)['enabled'];
}

Future<bool> verifyUser(String code, String email, String password, String userID) async{
  bool confirmed = false;
  String datetime = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
  String status = "User Register";
  CognitoUserSession? session;
    
  final userPool = CognitoUserPool(
    'ap-southeast-1_LPPgObixx', 
    '2fm8sfscl0uoah7eac3r7slabe'
  );

  final cognitoUser = CognitoUser(email, userPool);
  final authDetails = AuthenticationDetails(
    username: email,
    password: password,
  );

  try {
    confirmed = await cognitoUser.confirmRegistration(code);
    
    if (confirmed) {
      try {
        session = await cognitoUser.authenticateUser(authDetails);
        userID = session!.getAccessToken().getSub().toString();
      } catch(e) {
        print(e);
      }
      final response = await http.post(
        Uri.parse('https://k3mejliul2.execute-api.ap-southeast-1.amazonaws.com/ecosail_stage/Ecosail_lambda2'),
        headers: <String, String>{
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'userID': userID,
          'datetime': datetime, //'12/01/2022 14:14:05'
          'status': status,
        }),
      );
      if (response.statusCode == 200) {
        //return LocationData.fromJson(jsonDecode(response.body));
        print(RegistrationMsg.fromJson(jsonDecode(response.body)).message);
      } else {
        confirmed = false;
        showToast("Failed to register user! Check internet connection status");
      }
    }
  } on CognitoClientException catch (e) {
    //showToast(e.message!);
  }

  return confirmed;
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
  final codeController = TextEditingController();
  String userID = "";
  String userEmail = "";
  bool obscure = true;
  bool showVerification = false;
  bool verifiedEmail = false;
  bool passLength = false, upperCase = false, lowerCase = false, digits = false, special = false;
  bool trigger = false;

  void _printLatestValue() {
    String  patternUpper = r'^(?=.*?[A-Z])';
    RegExp regExpUpper = RegExp(patternUpper);
    String  patternLower = r'^(?=.*?[a-z])';
    RegExp regExpLower = RegExp(patternLower);
    String  patternDigit = r'^(?=.*?[0-9])';
    RegExp regExpDigit = RegExp(patternDigit);
    String  patternSpecial = r'^(?=.*?[\"!,.:;`{}|<>\[\]@\-\/_=#\$&*~\?+%^\(\)\\])';
    RegExp regExpSpacial = RegExp(patternSpecial);

    setState(() {
      trigger = true;
    });
    if (passwordController.text.length >= 8) {
      setState(() {
        passLength = true;
      });
    } else if (passwordController.text.length < 8) {
      setState(() {
        passLength = false;
      });
    }

    if (regExpUpper.hasMatch(passwordController.text)) {
      setState(() {
        upperCase = true;
      });
    } else if (regExpUpper.hasMatch(passwordController.text) == false) {
      setState(() {
        upperCase = false;
      });
    }

    if (regExpDigit.hasMatch(passwordController.text)) {
      setState(() {
        digits = true;
      });
    } else if (regExpDigit.hasMatch(passwordController.text) == false) {
      setState(() {
        digits = false;
      });
    }

    if (regExpSpacial.hasMatch(passwordController.text)) {
      setState(() {
        special = true;
      });
    } else if (regExpSpacial.hasMatch(passwordController.text) == false) {
      setState(() {
        special = false;
      });
    }

    if (regExpLower.hasMatch(passwordController.text)) {
      setState(() {
        lowerCase = true;
      });
    } else if (regExpLower.hasMatch(passwordController.text)) {
      setState(() {
        lowerCase = false;
      });
    }
  }

  /*
  bool validateStructure(String value){
    String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~\?+%]).{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }
  */

  @override
  void initState() {
    super.initState();

    passwordController.addListener(_printLatestValue);
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
              AppLargeText(
                text: "SIGN UP", 
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
              showVerification && !verifiedEmail? Column(
                children: [
                  AppLargeText(
                    text: "Verify Your Email",
                    color: Colors.black,
                    size: 16,
                  ),
                  const SizedBox(height: 12.0,),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "Enter the verification code sent to ",
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.4),
                        fontSize: 12.0
                      ),
                      children: <TextSpan> [
                        TextSpan(
                          text: emailController.text,
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.4),
                            fontSize: 12.0
                          )
                        )
                      ]
                    ),
                  ),
                ],
              )
              : !showVerification && verifiedEmail? Column(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 50,
                    color: AppColors.mainColor,
                  ),
                  const SizedBox(height: 20,),
                  const Text(
                    "Verification Success!",
                    style: TextStyle(
                      fontSize: 16.0
                    ),
                  ),
                  const SizedBox(height: 10,),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "You can now login using this email",
                      style: TextStyle(
                        height: 2.0,
                        color: Colors.black.withOpacity(0.4),
                        fontSize: 14.0
                      ),
                      children: <TextSpan> [
                        TextSpan(
                          text: "\nEmail: " + userEmail,
                          style: TextStyle(
                            height: 2.0,
                            color: Colors.black.withOpacity(0.4),
                            fontSize: 14.0
                          )
                        )
                      ]
                    ),
                  ),
                ],
              )
              :Container(),
              !showVerification && !verifiedEmail? GenerateFormField(
                label: "EMAIL",
                controller: emailController,
              ) : !showVerification && verifiedEmail? Container()
              : GenerateFormField(
                label: "VERIFICATION CODE",
                controller: codeController,
                maxLength: 6,
              ),
              !showVerification && !verifiedEmail? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GenerateFormField(
                    label: "PASSWORD",
                    controller: passwordController,
                    showObsure: obscure,
                    onPressedIcon: () {
                      setState(() {
                        obscure = !obscure;
                      });
                    },
                  ),
                  RichText(
                    text: TextSpan(
                      //text: "Enter the verification code sent to ",
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.4),
                        fontSize: 12.0
                      ),
                      children: <TextSpan> [
                        TextSpan(
                          text: "8 Characters",
                          style: TextStyle(
                            color: passLength? Colors.black.withOpacity(0.5): trigger? Colors.red.withOpacity(0.8): Colors.black.withOpacity(0.5),
                            height: 1.5,
                            fontSize: 12.0
                          )
                        ),
                        TextSpan(
                          text: " with ",
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            height: 1.5,
                            fontSize: 12.0
                          )
                        ),
                        TextSpan(
                          text: "Upper",
                          style: TextStyle(
                            color: upperCase? Colors.black.withOpacity(0.5): trigger? Colors.red.withOpacity(0.8): Colors.black.withOpacity(0.5),
                            height: 1.5,
                            fontSize: 12.0
                          )
                        ),
                        TextSpan(
                          text: ", ",
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            height: 1.5,
                            fontSize: 12.0
                          )
                        ),
                        TextSpan(
                          text: "Lower",
                          style: TextStyle(
                            color: lowerCase? Colors.black.withOpacity(0.5): trigger? Colors.red.withOpacity(0.8): Colors.black.withOpacity(0.5),
                            height: 1.5,
                            fontSize: 12.0
                          )
                        ),
                        TextSpan(
                          text: ", ",
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            height: 1.5,
                            fontSize: 12.0
                          )
                        ),
                        TextSpan(
                          text: "Digits",
                          style: TextStyle(
                            color: digits? Colors.black.withOpacity(0.5): trigger? Colors.red.withOpacity(0.8): Colors.black.withOpacity(0.5),
                            height: 1.5,
                            fontSize: 12.0
                          )
                        ),
                        TextSpan(
                          text: ", and ",
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            height: 1.5,
                            fontSize: 12.0
                          )
                        ),
                        TextSpan(
                          text: "Special Characters",
                          style: TextStyle(
                            color: special? Colors.black.withOpacity(0.5): trigger? Colors.red.withOpacity(0.8): Colors.black.withOpacity(0.5),
                            height: 1.5,
                            fontSize: 12.0
                          )
                        ),
                        TextSpan(
                          text: "\nAcceptable Specials: \"!,.:;`{}|<>[]@-/_=#\$&*~?+%^()\\",
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            height: 1.5,
                            fontSize: 12.0
                          )
                        ),
                      ]
                    ),
                  ),
                ],
              ): Container(),
              !showVerification && !verifiedEmail? ResponsiveButton(
                onTap: () async {
                  if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                    showToast("Registering...");
                    if (validateStructure(passwordController.text) && passwordController.text.length >= 6) {
                      String message = await registerUser(emailController.text, passwordController.text);
                      //showToast(message.split(" ")[1]);
                      if (message.contains("Successfully")) {
                        userID = message.split(" ")[0];
                        setState(() {
                          showVerification = true;
                          userEmail = emailController.text;
                        });
                      } else if (message.contains("given email already")) {
                        bool enabled = await verifyUserEnabled(emailController.text, passwordController.text);
                        if (enabled) {
                          showToast("Email already registered");
                        }
                        else {
                          setState(() {
                            showVerification = true;
                            userEmail = emailController.text;
                          });
                        }
                      } else {
                        showToast(message);
                      }
                      print("register ok");
                    }
                    else {
                      if (!validateStructure(passwordController.text)) {
                        showToast("Current password format is not acceptable");
                      }
                      if (passwordController.text.length < 8) {
                        showToast("Password need at least 8 characters!");
                      }
                    }
                  } else {
                    showToast("Email & Password cannot be empty");
                  }
                }, 
                width: 200.0,
                widget: Container(
                  padding: const EdgeInsets.all(12.0),
                  child: const Text(
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
              ): !showVerification && verifiedEmail? Container():
              ResponsiveButton(
                widget: Container(
                  padding: const EdgeInsets.all(12.0),
                  width: 200.0,
                  child: const Text(
                    "VERIFY EMAIL", 
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 20.0,
                      letterSpacing: 0.0
                    ),
                  ),
                ),
                onTap: () async{
                  showToast("Verifiying...");
                  bool status = await verifyUser(codeController.text, emailController.text, passwordController.text, userID);
                  if (status) {
                    // If verified
                    showToast("Verification Success! You can proceed to log in now");
                    setState(() {
                      verifiedEmail = true;
                      showVerification = false;
                      emailController.clear();
                      passwordController.clear();
                      codeController.clear();
                    });
                  } else {
                    showToast("Invalid code provided, please try again.");
                  }
                }, 
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already registered?  "),
                  ResponsiveText(
                    text: "Click to Login", 
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context, 
                        PageRouteBuilder(pageBuilder: (_, __, ___) => const LoginPage()), //use MaterialPageRoute for animation
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

  bool validateStructure(String value){
    String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[\"!,.:;`{}|<>\[\]@\-\/_=#\$&*~\?+%^\(\)\\]).{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }
}