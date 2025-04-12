import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utils/constants.dart';

class WelcomeImage extends StatelessWidget {
  const WelcomeImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "WELCOME TO DOMO",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: defaultPadding * 2),
        Row(
          children: [
            const Spacer(),
            // Option 1: Directly set width and height in SvgPicture.asset
            Expanded(
              flex: 8,
              child: SvgPicture.asset(
                "assets/checklist.svg",
                width: 200.0,   // Increase these values as needed
                height: 200.0,
                fit: BoxFit.contain, // Adjust this property if needed
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: defaultPadding * 2),
      ],
    );
  }
}
