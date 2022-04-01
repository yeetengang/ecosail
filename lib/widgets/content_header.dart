import 'package:ecosail/models/content_model.dart';
import 'package:ecosail/others/colors.dart';
import 'package:ecosail/pages/login_page.dart';
import 'package:ecosail/pages/register_page.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:ecosail/widgets/responsive_btn.dart';
import 'package:flutter/material.dart';

class ContentHeader extends StatelessWidget {
  final Content featuredContent;

  const ContentHeader({ 
    Key? key, 
    required this.featuredContent, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 500.0,
          height: 460.0,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(featuredContent.imageUrl),
              fit: BoxFit.cover)
          ),
        ),
        Positioned(
          bottom: 260.0,
          child: SizedBox(
            width: 100.0,
            child: Image.asset(featuredContent.logoUrl),
          ),
        ),
        Positioned(
          bottom: 200.0,
          child: AppLargeText(text: "WELCOME", size: 42,),
        ),
        Positioned(
          bottom: 130.0,
          child: ResponsiveButton(
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
            width: 200.0, 
            onTap: () {
              //Navigator.pop(context);
              Navigator.push(
                context, 
                PageRouteBuilder(pageBuilder: (_, __, ___) => LoginPage()), //use MaterialPageRoute for animation
              );
            },
          ),
        ),
        Positioned(
          bottom: 60.0,
          child: ResponsiveButton(
            width: 200.0, 
            widget: Container(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "SIGNUP", 
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 20.0,
                  letterSpacing: 0.0
                ),
              ),
            ),
            colors: AppColors.btnColor2,
            onTap: () {
              Navigator.push(
                context, 
                PageRouteBuilder(pageBuilder: (_, __, ___) => RegisterPage()), //use MaterialPageRoute for animation
              );
            },
          ),
        ),
      ],
    );
  }
}