// lib/screens/profile/profile_page.dart

import 'package:flutter/material.dart';
import 'package:domo/models/profile.dart';
import 'package:domo/services/profile_service.dart';
import 'package:domo/screens/profile/detail_preference.dart';
import 'package:domo/screens/profile/time_preference.dart';
import 'package:domo/screens/profile/change_password_page.dart';
import 'package:domo/widgets/bottom_nav_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Profile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _refreshProfile();
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = ProfileService().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<Profile>(
        future: _profileFuture,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('에러: ${snap.error}'));
          }
          final profile = snap.data!;
          return _buildContent(profile);
        },
      ),
    );
  }

  Widget _buildContent(Profile profile) {
    return Center(
      child: Container(
        width: 393,
        height: 852,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // ─── Scrollable content ───
            Positioned.fill(
              bottom: 56,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
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
                        const Text('유저 프로필',
                            style:
                                TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
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
                              color: Colors.orange[100],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person,
                                size: 40, color: Colors.orange),
                          ),
                          const SizedBox(height: 12),
                          Text('${profile.name}님',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('@${profile.username}',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Account info (ID & Email)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x19000000),
                              blurRadius: 8,
                              offset: Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person_outline,
                                  color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              const Text('아이디',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              const Spacer(),
                              Text(profile.username,
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              const Icon(Icons.email,
                                  color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              const Text('이메일',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              const Spacer(),
                              Text(profile.email ?? '-',
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                     // Preferences
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x19000000),
                              blurRadius: 8,
                              offset: Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildListTile(
                            title: '세분화 선호도 변경',
                            subtitle: profile.subtaskPreference ?? '-',
                            onTap: () async {
                              final updated = await Navigator.push<Profile>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetailPreferencePage(profile: profile),
                                ),
                              );
                              if (updated != null) _refreshProfile();
                            },
                          ),
                          const Divider(height: 24),
                          _buildListTile(
                            title: '소요시간 계산 선호도 변경',
                            subtitle: profile.timePreference ?? '-',
                            onTap: () async {
                              final updated = await Navigator.push<Profile>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TimePreferencePage(profile: profile),
                                ),
                              );
                              if (updated != null) _refreshProfile();
                            },
                          ),
                          const Divider(height: 24),
                          _buildListTile(
                            title: '비밀번호 변경',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ChangePasswordPage()),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Coins & Completed Projects
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x19000000),
                              blurRadius: 8,
                              offset: Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text('보유 코인',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ),
                              Image.asset('assets/png/coin.png', width: 20, height: 20),
                              const SizedBox(width: 8),
                              Text('${profile.coins}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const Divider(height: 24),
                          InkWell(
                            onTap: () => Navigator.pushNamed(
                                context, '/completed'),
                            child: Row(
                              children: const [
                                Expanded(
                                    child: Text('완료한 프로젝트 보기',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600))),
                                Icon(Icons.chevron_right, color: Colors.grey),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Center(
                    child: TextButton(
                      onPressed: () async {
                        // 1) 로그아웃 처리 (토큰 삭제 등)
                        await ProfileService().logout();
                        // 2) 로그인 화면으로 이동
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black, // 필요에 따라 색상 변경
                      ),
                      child: const Text('로그아웃'),
                    ),
                  ),
                  const SizedBox(height: 16),

                    // Membership withdrawal
                    Center(
                      child: TextButton(
                        onPressed: () => _confirmDelete(),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('회원탈퇴하기'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ─── Bottom navigation ───
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                  height: 68, child: BottomNavBar(activeIndex: 4)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) =>
      InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                  child: Text(title,
                      style:
                          const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
              if (subtitle != null) Text(subtitle,
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      );

  void _confirmDelete() {
    showDialog<bool>(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 30, vertical: 200),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('회원탈퇴',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              const Text('정말 탈퇴하시겠습니까?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('취소'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context, true);
                      await ProfileService().deleteAccount();
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC78E48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child:
                        const Text('탈퇴', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
