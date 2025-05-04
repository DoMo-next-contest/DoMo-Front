// lib/screens/profile_page.dart

import 'package:flutter/material.dart';
import 'package:domo/models/profile.dart';
import 'package:domo/screens/account_info_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key, required this.profile}) : super(key: key);

  final Profile profile;

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
              // Scrollable content
              Positioned.fill(
                bottom: 56, // leave room for nav bar
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
                            '유저 프로필',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Avatar + name + username
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 75,
                              height: 75,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.person, size: 40, color: Colors.white),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${profile.name} 님',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@${profile.username}',
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Cards
                      _buildCard('계정 관리', onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AccountInfoPage()),
                      ),),
                      const SizedBox(height: 12),
                      _buildCard('세분화 선호도', subtitle: profile.subtaskPreference ?? '-', onTap: () {}),
                      const SizedBox(height: 12),
                      _buildCard('시간 선호도', subtitle: profile.timePreference ?? '-', onTap: () {}),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom navigation bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SizedBox(
                  height: 68,
                  child: _BottomNavBar(activeIndex: 4), // 4 = profile
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String title, {String? subtitle, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x19000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
            if (subtitle != null) Text(subtitle, style: const TextStyle(color: Colors.grey)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

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
