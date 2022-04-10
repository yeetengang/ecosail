import 'dart:convert';

import 'package:ecosail/gateway.dart';
import 'package:ecosail/others/colors.dart';
import 'package:ecosail/pages/view_sailboat_page.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:ecosail/widgets/inner_app_bar.dart';
import 'package:ecosail/widgets/responsive_btn.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

Future<String> registerSailboat(String boatID, String boatName, String userID) async {
  String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  String datetime = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
  String status = "Register Sailboat";

  final response = await http.post(
    Uri.parse('https://k3mejliul2.execute-api.ap-southeast-1.amazonaws.com/ecosail_stage/Ecosail_lambda2'),
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, String>{
      'boatID': boatID,
      'boatName': boatName,
      'timestamp': timestamp,
      'userID': userID.toString(),
      'datetime': datetime, //'12/01/2022 14:14:05'
      'status': status,
    }),
  );
  if (response.statusCode == 200) {
    //return LocationData.fromJson(jsonDecode(response.body));
    return jsonDecode(response.body)["message"];
  } else {
    return "Connection Error!";
  }
}

class SailboatRegisterPage extends StatefulWidget {
  final List<Data> dataList;
  final String userID;
  final String userEmail;
  
  SailboatRegisterPage({ Key? key, required this.dataList, required this.userID, required this.userEmail }) : super(key: key);

  @override
  _SailboatRegisterPageState createState() => _SailboatRegisterPageState();
}

class _SailboatRegisterPageState extends State<SailboatRegisterPage> {
  final idController = TextEditingController();
  final nameController = TextEditingController();

  void dispose() {
    idController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final idController = TextEditingController();
    final nameController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size(screenSize.width, 60),
        child: InnerAppBar(),
      ),
      body: CustomScrollView(
        physics: ClampingScrollPhysics(),
        slivers: <Widget>[
          _buildSailboatForm(screenSize, context),
        ],
      )
    );
  }

  SliverToBoxAdapter _buildSailboatForm(Size screenSize, BuildContext context) {
    return SliverToBoxAdapter(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Container(
                height: screenSize.height * 0.35,
                width: screenSize.width, //If the screensize is more than mobile size, then fix this size
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('images/register_sailboat.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                width: screenSize.width * 0.8, //If more than mobile screen size then fix the size
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: AppLargeText(
                  text: 'Register Sailboat', 
                  textAlign: TextAlign.center, 
                  size: 22, 
                  color: AppColors.mainColor,
                ),
              ),
              Container(
                width: screenSize.width * 0.7, //If more than mobile screen size then fix the size
                child: Column(
                  children: [
                    _generateFormContent('SAILBOAT ID', 14, idController),
                    _generateFormContent('SAILBOAT NAME', 14, nameController),
                    Container(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: _generateFormButton(
                        'Register', 
                        screenSize.width * 0.7, 
                        AppColors.mainColor,
                        Colors.white,
                        () async {
                          //Button to register sailboat
                          showToast("Registering sailboat...");
                          String message = await registerSailboat(idController.text, nameController.text, widget.userID);
                          showToast(message);
                        }
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: _generateFormButton(
                        'View Registered Sailboat', 
                        screenSize.width * 0.7, 
                        AppColors.btnColor2, 
                        Colors.black,
                        () {
                          //Button to View Registered Sailboat
                          Navigator.push(
                            context, 
                            PageRouteBuilder(pageBuilder: (_, __, ___) => ViewSailboat(dataList: widget.dataList, userID: widget.userID, userEmail: widget.userEmail,)), //use MaterialPageRoute for animation
                          );
                        }
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 14.0),
                      child: ResponsiveButton(
                        widget: Text(
                          'Cancel', 
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                        colors: Colors.transparent,
                    ),
                    )
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  TextFormField _generateFormContent(String label, int maxLength, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLength: maxLength,
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

  ResponsiveButton _generateFormButton(String label, double width, Color buttonColor, Color labelColor, Function() onTap) {
    return ResponsiveButton(
      colors: buttonColor,
      onTap: onTap,
      widget: Container(
        width: width,
        padding: EdgeInsets.all(12.0),
        child: Text(
          label, 
          textAlign: TextAlign.center,
          style: TextStyle(
            color: labelColor,
            fontWeight: FontWeight.w500,
            fontSize: 14.0,
            letterSpacing: 0.0
          ),
        ),
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