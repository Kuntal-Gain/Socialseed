import 'package:flutter/material.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/page_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<Developer> devs = [
      Developer(
        imageId: 'assets/images/1.jpg',
        name: "Kuntal Gain",
        label: "Team Lead",
        role: "Flutter",
      ),
      Developer(
        imageId: 'assets/images/2.jpg',
        name: "Abhisekh Rajak",
        label: "Adaptive UI & Animation",
        role: "Flutter",
      ),
      Developer(
        imageId: 'assets/images/3.jpg',
        name: "Rupam Das",
        label: "Privacy & Security",
        role: "Flutter",
      ),
      Developer(
        imageId: 'assets/images/4.jpg',
        name: "Aisha Halder",
        label: "AI Implement",
        role: "AI / ML",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Socialseed'),
      ),
      body: Column(
        children: [
          Image.asset('assets/logo.png'),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Socialseed is a Modern Social Media Platform with adaptive layout and Modern AI Integration',
              style: TextConst.headingStyle(18, AppColor.redColor),
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: 4,
            itemBuilder: (ctx, idx) {
              return Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                height: 120,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: AppColor.whiteColor,
                    border: Border.all(color: AppColor.greyShadowColor)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: Image.asset(devs[idx].imageId),
                      ),
                    ),
                    sizeHor(10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                devs[idx].name,
                                style: TextConst.headingStyle(
                                    16, AppColor.redColor),
                              ),
                              sizeHor(5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 1),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: devs[idx].role != "Flutter"
                                      ? Colors.orange
                                      : Colors.blue,
                                ),
                                child: Text(
                                  devs[idx].role,
                                  style: TextConst.headingStyle(
                                    13,
                                    AppColor.whiteColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            devs[idx].label,
                            style:
                                TextConst.headingStyle(18, AppColor.blackColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ))
        ],
      ),
    );
  }
}

class Developer {
  final String imageId;
  final String name;
  final String role;
  final String label;

  Developer({
    required this.imageId,
    required this.name,
    required this.label,
    required this.role,
  });
}
