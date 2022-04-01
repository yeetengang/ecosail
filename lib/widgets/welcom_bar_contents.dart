import 'package:ecosail/others/colors.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:flutter/material.dart';

class WelcomeAppBar extends StatelessWidget {
  final double scrollOffset;

  const WelcomeAppBar({ 
    Key? key,
    this.scrollOffset = 0.0 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 15, 
        horizontal: 28
      ),
      color: AppColors.mainColor.withOpacity((scrollOffset / 350).clamp(0, 1).toDouble()),
      child: SafeArea(
        child: Row(
          children: [
            //Icon(Icons.menu, color: Colors.white, size: 30,),
            //const SizedBox(width: 20,),
            Row(
              children: [
                AppLargeText(text: "EcoSail"),
              ],
            )
          ],
        ),
      ),
    );
  }
}