import 'package:ecosail/data/data.dart';
import 'package:ecosail/others/colors.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:ecosail/widgets/app_para_text.dart';
import 'package:ecosail/widgets/content_header.dart';
import 'package:ecosail/widgets/top_bar_contents.dart';
import 'package:ecosail/widgets/welcom_bar_contents.dart';
import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({ Key? key }) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  double _scrollOffset = 0.0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _scrollController.addListener((){
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size(screenSize.width, 70),
        child: WelcomeAppBar(scrollOffset: _scrollOffset,),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: ContentHeader(featuredContent: ecosailContent),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(top: 20.0),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      AppLargeText(text: about.title, color: AppColors.blackText,),
                      SizedBox(height: 30,),
                      Container(
                        width: screenSize.width-80,
                        alignment: Alignment.center,
                        child: AppParaText(text: about.description, color: AppColors.blackText,),
                      ),
                      SizedBox(height: 30,),
                      Container(
                        width: (screenSize.width*0.8),
                        height: 180.0,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.btnColor2,
                        ),
                        child: Column(
                          children: [
                            AppLargeText(text: "test", color: AppColors.blackText,),
                            AppLargeText(text: "test", color: AppColors.blackText,)
                          ],
                        ),
                      ),
                      SizedBox(height: 15,),
                      Container(
                        width: (screenSize.width*0.8),
                        height: 180.0,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.btnColor2,
                        ),
                        child: Column(
                          children: [
                            AppLargeText(text: "test", color: AppColors.blackText,),
                            AppLargeText(text: "test", color: AppColors.blackText,)
                          ],
                        ),
                      ),
                      SizedBox(height: 15,),
                      Container(
                        width: (screenSize.width*0.8),
                        height: 180.0,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.btnColor2,
                        ),
                        child: Column(
                          children: [
                            AppLargeText(text: "test", color: AppColors.blackText,),
                            AppLargeText(text: "test", color: AppColors.blackText,)
                          ],
                        ),
                      ),
                      SizedBox(height: 30,)
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
}