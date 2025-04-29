import 'package:flutter/material.dart';

class StepProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double width;
  final double height;
  final double labelWidth;
  final double topPadding;

  const StepProgress({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    this.width = 335,
    this.height = 5,
    this.labelWidth = 335,
    this.topPadding = 55,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xFFEEEEEE);
    final fgColor = const Color(0xFFAB4E18);
    final progressWidth = width * (currentStep / totalSteps);

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // progress bar
          SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                Container(
                  decoration: ShapeDecoration(
                    color: bgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  child: Container(
                    width: progressWidth,
                    height: height,
                    decoration: BoxDecoration(color: fgColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // label
          SizedBox(
            width: labelWidth,
            child: Text(
              'Step $currentStep/$totalSteps',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
