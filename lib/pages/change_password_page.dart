import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:ecosail/others/colors.dart';
import 'package:ecosail/others/show_toast.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:ecosail/widgets/generate_form_field.dart';
import 'package:ecosail/widgets/inner_app_bar.dart';
import 'package:ecosail/widgets/responsive.dart';
import 'package:ecosail/widgets/responsive_btn.dart';
import 'package:flutter/material.dart';

Future<bool> updateUserPassword(String email, String oldPassword, String newPassword) async {

  final userPool = CognitoUserPool(
    'ap-southeast-1_LPPgObixx', 
    '2fm8sfscl0uoah7eac3r7slabe'
  );
  print(email);
  final cognitoUser = CognitoUser(email, userPool);
  bool passwordChanged = false;
  CognitoUserSession? session;
  final authDetails = AuthenticationDetails(
    username: email,
    password: oldPassword,
  );

  try {
    session = await cognitoUser.authenticateUser(authDetails);
    passwordChanged = await cognitoUser.changePassword(oldPassword, newPassword);
  } on CognitoClientException catch (e) {
    print(e.message!);
    return false;
  } catch (e) {
    //The catch should avoid the application from crash (Not Yet)
    print(e);
  }

  return passwordChanged;
}

class ChangePasswordPage extends StatefulWidget {
  String userEmail;
  
  ChangePasswordPage({
    Key? key ,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  bool obscure = true;
  bool obscure2 = true;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size(screenSize.width, 60),
        child: InnerAppBar(currentPage: 'profile',),
      ),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: <Widget>[
          SliverFillRemaining(
            hasScrollBody: false,
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
            //height: screenSize.height - 120,
            width: !Responsive.isMobile(context)? 420.0: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AppLargeText(
                  textAlign: TextAlign.center,
                  text: "CHANGE PASSWORD", 
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
                GenerateFormField(
                  label: "ORIGINAL PASSWORD",
                  controller: oldPasswordController,
                  showObsure: obscure,
                  onPressedIcon: () {
                    setState(() {
                      obscure = !obscure;
                    });
                  },
                ),
                const SizedBox(height: 10.0,),
                GenerateFormField(
                  label: "NEW PASSWORD",
                  controller: newPasswordController,
                  showObsure: obscure2,
                  onPressedIcon: () {
                    setState(() {
                      obscure2 = !obscure2;
                    });
                  },
                ),
                const SizedBox(height: 10.0,),
                ResponsiveButton(
                  onTap: () async {
                    if (oldPasswordController.text.isNotEmpty && newPasswordController.text.isNotEmpty) {
                      showToast("Registering...");
                      if (validateStructure(newPasswordController.text) && newPasswordController.text.length >= 6) {
                        bool status = await updateUserPassword(widget.userEmail, oldPasswordController.text, newPasswordController.text);
                        
                        if (status) {
                          showToast("Password Changed Successfully");
                          Navigator.pop(context);
                        } else {
                          showToast("Failed to Change Password");
                        }
                      }
                      else {
                        if (!validateStructure(newPasswordController.text)) {
                          showToast("New password format is not acceptable");
                        }
                        if (newPasswordController.text.length < 6) {
                          showToast("Password need at least 6 characters!");
                        }
                      }
                    } else {
                      showToast("Fields cannot be empty");
                    }
                  }, 
                  width: 200.0,
                  widget: Container(
                    padding: const EdgeInsets.all(12.0),
                    child: const Text(
                      "CHANGE PASSWORD", 
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14.0,
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
}

bool validateStructure(String value){
  String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
  RegExp regExp = RegExp(pattern);
  return regExp.hasMatch(value);
}