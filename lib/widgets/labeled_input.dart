import 'package:flutter/material.dart';

class LabeledInput extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final bool obscureText;

  const LabeledInput({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 335,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1E1E1E),
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 240),
          child: Container(
            width: double.infinity,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              shadows: const [
                BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 16,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                decoration: InputDecoration.collapsed(
                  hintText: placeholder,
                  hintStyle: const TextStyle(
                    color: Color(0xFFB3B3B3),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
