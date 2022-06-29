import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:ecosail/gateway.dart';
import 'package:ecosail/others/colors.dart';
import 'package:ecosail/pages/change_password_page.dart';
import 'package:ecosail/pages/view_sailboat_page.dart';
import 'package:ecosail/pages/welcome_page.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:ecosail/widgets/inner_app_bar.dart';
import 'package:ecosail/widgets/responsive_btn.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatelessWidget {
  final List<Data> dataList;
  final String userID;
  final String userEmail;

  const UserProfile({ Key? key, required this.dataList, required this.userID, required this.userEmail}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: PreferredSize(
        preferredSize: Size(screenSize.width, 60),
        child: InnerAppBar(currentPage: 'profile',),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_circle,
                size: 120.0,
                color: AppColors.btnColor2,
              ),
              AppLargeText(
                text: userEmail,
                size: 24,
                color: AppColors.btnColor2,
              ),
              const SizedBox(height: 70.0,),
              Container(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ResponsiveButton(
                  onTap: () {
                    Navigator.push(
                      context, 
                      PageRouteBuilder(pageBuilder: (_, __, ___) => ChangePasswordPage(userEmail: userEmail,)), //use MaterialPageRoute for animation
                    );
                  }, 
                  widget: Container(
                    width: screenSize.width * 0.70,
                    padding: const EdgeInsets.all(12.0),
                    child: const Text(
                      "Change Password", 
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 18.0,
                        letterSpacing: 0.0
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ResponsiveButton(
                  widget: Container(
                    width: screenSize.width * 0.70,
                    padding: const EdgeInsets.all(12.0),
                    child: const Text(
                      "View Registered Sailboat", 
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 18.0,
                        letterSpacing: 0.0
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context, 
                      PageRouteBuilder(pageBuilder: (_, __, ___) => ViewSailboat(dataList: dataList, userID: userID, userEmail: userEmail,)), //use MaterialPageRoute for animation
                    );
                  }, 
                ),
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: ResponsiveButton(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const WelcomePage(),
                      ), 
                      (route) => false,
                    );
                  }, 
                  widget: Container(
                    width: screenSize.width * 0.70,
                    padding: const EdgeInsets.all(12.0),
                    child: const Text(
                      "Sign Out", 
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 18.0,
                        letterSpacing: 0.0
                      ),
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}