import 'package:flutter/material.dart';
import 'package:socialseed/utils/constants/color_const.dart';
import 'package:socialseed/utils/constants/text_const.dart';

class MilestoneScreen extends StatefulWidget {
  const MilestoneScreen({super.key});

  @override
  State<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends State<MilestoneScreen> {
  // Example milestone data
  final List<Milestones> milestones = [
    const Milestones(
      icon: 'https://cdn-icons-png.flaticon.com/128/2058/2058768.png',
      title: 'First Friend',
      currentValue: 300,
      targetValue: 500,
    ),
    const Milestones(
      icon: 'https://cdn-icons-png.flaticon.com/128/6081/6081941.png',
      title: 'Rising Star',
      currentValue: 1500,
      targetValue: 2000,
    ),
    const Milestones(
      icon: 'https://cdn-icons-png.flaticon.com/128/3032/3032220.png',
      title: 'First Post',
      currentValue: 120,
      targetValue: 200,
    ),
    // Add more milestones as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Milestones'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns in the grid
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: milestones.length,
          itemBuilder: (context, index) {
            final milestone = milestones[index];
            final progress = (milestone.currentValue / milestone.targetValue)
                .clamp(0.0, 1.0);

            return Column(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  padding: const EdgeInsets.all(10),
                  child: Image.network(
                    milestone.icon,
                    color: AppColor.redColor,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    milestone.title,
                    style: TextConst.headingStyle(
                      16,
                      AppColor.redColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          color: AppColor.redColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                            '${milestone.currentValue} / ${milestone.targetValue}'),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class Milestones {
  final String icon;
  final String title;
  final int currentValue;
  final int targetValue;

  const Milestones({
    required this.icon,
    required this.title,
    required this.currentValue,
    required this.targetValue,
  });
}
