import 'package:ecosail/assets.dart';
import 'package:ecosail/models/content_model.dart';
import 'package:ecosail/models/text_model.dart';

final Content ecosailContent = const Content (
  name: 'Ecosail',
  logoUrl: Assets.ecosailLogo,
  imageUrl: Assets.oceanPic,
);

final TextContent about = const TextContent(
  title: 'About', 
  description: 'Ecosail is an unmanned sailboat consisting of a control system and can navigate on its own to the location specified by users. The sailboat requires only electrical energy and the help of wind energy (sea breeze) to travel to the destination. The sailboat will upload gathered data to a cloud server to perform data analysis.',
);