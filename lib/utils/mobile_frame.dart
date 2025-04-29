import 'package:flutter/material.dart';

class MobileFrame extends StatelessWidget {
  final Widget child;
  final double designWidth;
  final double designHeight;

  const MobileFrame({
    Key? key,
    required this.child,
    this.designWidth = 393,
    this.designHeight = 852,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: FittedBox(
        fit: BoxFit.fitHeight,              
        alignment: Alignment.bottomCenter,  
        child: Container(                    // ← SizedBox → Container 로 변경
          width: designWidth,
          height: designHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8), // ← 코너를 살짝만 둥글게
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ),
    );
  }
}