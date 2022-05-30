import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:ecosail/others/colors.dart';
import 'package:ecosail/others/show_toast.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:ecosail/widgets/form_content.dart';
import 'package:ecosail/widgets/responsive.dart';
import 'package:ecosail/widgets/responsive_btn.dart';
import 'package:flutter/material.dart';

Future<String> forgotPasswordSendEmail(String email) async {

  final userPool = CognitoUserPool(
    'ap-southeast-1_LPPgObixx', 
    '2fm8sfscl0uoah7eac3r7slabe'
  );

  final cognitoUser = CognitoUser(email, userPool);

  var data;
  try {
    data = await cognitoUser.forgotPassword();
    return "Done";
  } catch (e) {
    print(e);
  }
  
  return "Error occured";
}

Future<bool> forgotPasswordResetPassword(String email, String confirmCode, String password) async {

  final userPool = CognitoUserPool(
    'ap-southeast-1_LPPgObixx', 
    '2fm8sfscl0uoah7eac3r7slabe'
  );

  final cognitoUser = CognitoUser(email, userPool);

  bool passwordConfirmed = false;
  try {
    passwordConfirmed = await cognitoUser.confirmPassword(
      confirmCode, password
    );
    return passwordConfirmed;
  } catch (e) {
    print(e);
  }
  print(passwordConfirmed);

  return false;
}

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({ Key? key }) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final codeController = TextEditingController();

  bool obscure = true;
  bool obscure2 = true;
  bool startVerification = false;
  
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
                  text: "FORGOT PASSWORD?", 
                  textAlign: TextAlign.center,
                  color: const Color.fromRGBO(0, 180, 216, 1),
                  size: 30,
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
            !startVerification? Column(
              children: [
                AppLargeText(
                  text: "Account Recovery",
                  color: Colors.black,
                  size: 16,
                ),
                const SizedBox(height: 12.0,),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "Enter the email associated with your account to receive a verification code to reset password",
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.4),
                      fontSize: 12.0
                    ),
                  ),
                ),
                const SizedBox(height: 30.0,),
                FormContent(
                  label: 'RECOVERY EMAIL',
                  controller: emailController,
                  obscure: false, // No need to show this
                  onTap: () {
                    
                  },  
                ),
              ],
            ): Column(
              children: [
                AppLargeText(
                  text: "Reset Password",
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
                      ),
                      TextSpan(
                        text: ' and create a new password',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.4),
                          fontSize: 12.0
                        )
                      )
                    ]
                  ),
                ),
                const SizedBox(height: 30.0,),
                FormContent(
                  label: 'VERIFICATION CODE',
                  controller: codeController,
                  obscure: false, // No need to show this
                  onTap: () {
                    
                  },  
                ),
                const SizedBox(height: 20.0,),
                FormContent(
                  label: 'NEW PASSWORD',
                  controller: passwordController,
                  obscure: obscure, // No need to show this
                  onTap: () {
                    setState(() {
                      obscure = !obscure;
                    });
                  } 
                ),
                const SizedBox(height: 20.0,),
                FormContent(
                  label: 'CONFIRM NEW PASSWORD',
                  controller: confirmController,
                  obscure: obscure2, // No need to show this
                  onTap: () {
                    setState(() {
                      obscure2 = !obscure2;
                    });
                  },  
                ),
              ],
            ),
            !startVerification? ResponsiveButton(
              onTap: () async {
                if (emailController.text.isNotEmpty) {
                  String message = await forgotPasswordSendEmail(emailController.text);
                  if (message == "Done") {
                    setState(() {
                      startVerification = true;
                    });
                  }
                } else {
                  showToast("Recovery Email field cannot be empty");
                }
              }, 
              width: 200.0,
              widget: Container(
                padding: const EdgeInsets.all(12.0),
                child: const Text(
                  "SEND CODE", 
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 20.0,
                    letterSpacing: 0.0
                  ),
                ),
              ),
            ): ResponsiveButton(
              onTap: () async {
                bool resetStatus = false;
                bool codeNotEmpty = false;
                bool passwordSame = false;
                if (!validateStructure(passwordController.text)) {
                  showToast("Current password format is not acceptable");
                }
                else if (passwordController.text != confirmController.text) {
                  showToast("New Password must match with Confirmed Password");
                } else {
                  passwordSame = true;
                }

                if (codeController.text == "") {
                  showToast("Verification Code field cannot be empty");
                } else {
                  codeNotEmpty = true;
                }

                if (codeNotEmpty==true && passwordSame==true) {
                  resetStatus = await forgotPasswordResetPassword(emailController.text, codeController.text, passwordController.text);
                  if (resetStatus==true && codeNotEmpty==true && passwordSame==true) {
                    showToast("Password Reset Successfully");
                    Navigator.pop(context);
                  } else {
                    showToast("Password Reset Failed");
                  }
                }
              }, 
              width: 200.0,
              widget: Container(
                padding: const EdgeInsets.all(12.0),
                child: const Text(
                  "RESET PASSWORD", 
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
          ],
        ),
      ),
      )
    );
  }

  bool validateStructure(String value){
    String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(value);
  }
}