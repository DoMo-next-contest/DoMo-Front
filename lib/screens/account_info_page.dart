// lib/screens/account_info_page.dart

import 'package:flutter/material.dart';

class AccountInfoPage extends StatelessWidget {
  const AccountInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: 393,
          height: 852,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              // Scrollable content (leave room for nav bar)
              Positioned.fill(
                bottom: 56,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 53, left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top bar
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '계정 정보 관리',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Name field
                      _buildField(label: '이름', value: '홍길동'),
                      const SizedBox(height: 16),

                      // ID field
                      _buildField(label: 'ID', value: 'userid'),
                      const SizedBox(height: 16),

                      // Email field
                      _buildField(label: '이메일', value: 'example@gmail.com'),
                      const SizedBox(height: 24),

                      // Actions row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {/* TODO: delete account */},
                            child: const Text(
                              '회원탈퇴하기',
                              style: TextStyle(
                                color: Color(0xFFFF3B30),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {/* TODO: save changes */},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC78E48),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              child: Text(
                                '정보 업데이트',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom nav
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SizedBox(
                  height: 56,
                  child: _BottomNavBar(activeIndex: 4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(color: Color(0x19000000), blurRadius: 16, offset: Offset(0, 2)),
            ],
          ),
          child: Text(value, style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}

/// Reusable bottom‐nav bar
class _BottomNavBar extends StatelessWidget {
  final int activeIndex; // 0=home,1=project,2=add,3=char,4=profile

  const _BottomNavBar({required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons.home,
      Icons.format_list_bulleted,
      Icons.control_point,
      Icons.pets,
      Icons.person_outline,
    ];
    const labels = ['홈', '프로젝트', '추가', '캐릭터', '프로필'];
    const routes = ['/dashboard', '/project', '/add', '/decor', '/profile'];

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Row(
        children: List.generate(5, (i) {
          final color = i == activeIndex ? const Color(0xFFBF622C) : const Color(0xFF9AA5B6);
          final weight = i == activeIndex ? FontWeight.w600 : FontWeight.w400;
          return Expanded(
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, routes[i]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icons[i], color: color, size: 24),
                  const SizedBox(height: 2),
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontFamily: 'Inter',
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
