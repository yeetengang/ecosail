import 'package:ecosail/data/data.dart';
import 'package:ecosail/others/colors.dart';
import 'package:ecosail/widgets/app_large_text.dart';
import 'package:ecosail/widgets/app_para_text.dart';
import 'package:ecosail/widgets/content_header.dart';
import 'package:ecosail/widgets/responsive.dart';
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
            padding: const EdgeInsets.only(top: 30.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0),
                    child: 
                      Column(
                        children: [
                          AppLargeText(text: about.title, color: AppColors.blackText,),
                          SizedBox(height: 30,),
                          AppParaText(text: about.description, color: AppColors.blackText,),
                          SizedBox(height: 30,),
                          Responsive.isTablet(context) && !Responsive.isMobile(context)? 
                          Column(
                            children: [
                              DesciptionCards(
                                size: (screenSize.width*0.8),
                                margin: const EdgeInsets.symmetric(vertical: 10.0),
                                title: "Environment Monitoring", 
                                description: "Start monitoring\nthe ocean with real time data\nand receive notifications\nabout potential polluted areas."
                              ),
                              DesciptionCards(
                                size: (screenSize.width*0.8),
                                margin: const EdgeInsets.symmetric(vertical: 10.0),
                                title: "Autonomous Sailboat", 
                                description: "Unmanned Sailboat\nthat navigate to destination specified\nautonomously."
                              ),
                              DesciptionCards(
                                size: (screenSize.width*0.8),
                                margin: const EdgeInsets.symmetric(vertical: 10.0),
                                title: "Water Quality Analysis", 
                                description: "Collected water data\nwill be analyzed and visualize asgraphs and\ninterpolation maps."
                              ),
                            ],
                          ): Responsive.isDesktop(context) && !Responsive.isMobile(context)?
                          Row(
                            children: const [
                              Flexible(
                                flex: 1,
                                child: DesciptionCards(
                                  size: double.infinity,
                                  margin: EdgeInsets.all(10.0),
                                  title: "Environment Monitoring", 
                                  description: "Start monitoring\nthe ocean with real time data\nand receive notifications\nabout potential polluted areas."
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: DesciptionCards(
                                  size: double.infinity,
                                  margin: EdgeInsets.all(10.0),
                                  title: "Autonomous Sailboat", 
                                  description: "Unmanned Sailboat\nthat navigate to destination specified\nautonomously."
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: DesciptionCards(
                                  size: double.infinity,
                                  margin: EdgeInsets.all(10.0),
                                  title: "Water Quality Analysis", 
                                  description: "Collected water data\nwill be analyzed and visualize asgraphs and\ninterpolation maps."
                                ),
                              ),
                            ],
                          ) : Container()
                        ],
                      ),
                  ),
                  /*!Responsive.isMobile(context)? Container(
                    margin: EdgeInsets.only(top: 20.0),
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: 46.0,
                    color: AppColors.pageBackground,
                    child: Text(
                      "2021/2022 USM CAT400 NS21220108",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white
                      ),
                    ),
                  ): Container()*/
                ],
              )
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: !Responsive.isMobile(context)? Container(
                margin: EdgeInsets.only(top: 20.0),
                alignment: Alignment.center,
                width: double.infinity,
                height: 46.0,
                color: AppColors.pageBackground,
                child: Text(
                  "2021/2022 USM CAT400 NS21220108",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white
                  ),
                ),
              ): Container(),
            ),
          )
        ],
      )
    );
  }
}

class DesciptionCards extends StatelessWidget {
  final String title;
  final String description;
  final double size;
  final EdgeInsets? margin;

  const DesciptionCards({ 
    Key? key,
    required this.title,
    required this.description,
    required this.size,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: 180.0,
      padding: const EdgeInsets.all(20),
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.btnColor2,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AppLargeText(
            text: title, 
            color: AppColors.blackText,
            size: 24.0,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: AppParaText(
              text: description,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}