import 'package:flutter/material.dart';

/// 하단 네비게이션 바 (홈, 프로젝트, 추가, 캐릭터, 프로필)
class BottomNavBar extends StatelessWidget {
  final int activeIndex; // 0=홈,1=프로젝트,2=추가,3=캐릭터,4=프로필

  const BottomNavBar({
    Key? key,
    required this.activeIndex,
  }) : super(key: key);

  static const _icons = [
    Icons.home,
    Icons.format_list_bulleted,
    Icons.control_point,
    Icons.pets,
    Icons.person_outline,
  ];
  static const _labels = ['홈', '프로젝트', '추가', '캐릭터', '프로필'];
  static const _routes = [
    '/dashboard',
    '/project',
    '/add',
    '/decor',
    '/profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Row(
        children: List.generate(5, (i) {
          final color = i == activeIndex
              ? const Color(0xFFBF622C)
              : const Color(0xFF9AA5B6);
          final weight = i == activeIndex ? FontWeight.w600 : FontWeight.w400;
          return Expanded(
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, _routes[i]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_icons[i], color: color, size: 24),
                  const SizedBox(height: 2),
                  Text(
                    _labels[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: weight,
                      color: color,
                      height: 1.08,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
