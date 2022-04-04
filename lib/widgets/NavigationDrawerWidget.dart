import 'package:ecosail/gateway.dart';
import 'package:ecosail/others/colors.dart';
import 'package:ecosail/widgets/get_pages.dart';
import 'package:flutter/material.dart';

class NavigationDrawerWidget extends StatelessWidget {
  final List<Widget> widgetList;

  NavigationDrawerWidget({ 
    Key? key,
    required this.widgetList
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: Container(
        color: AppColors.btnColor2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widgetList,
        ),
      ),
    );
  }

  /*Widget _buildMenuItems({
      required String text,
      required IconData icon,
      VoidCallback? onTap,
  }) {
    final color = Colors.black;

    return ListTile(
      leading: Icon(icon, color: color,),
      title: Text(text, style: TextStyle(color: color),),
      onTap: onTap,
    );
  }*/
}