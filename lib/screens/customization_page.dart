import 'package:flutter/material.dart';
import 'package:domo/models/profile.dart';

class CustomizationPage extends StatelessWidget {
  const CustomizationPage({ Key? key, required this.profile }): super(key: key);
  
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: 393,
          height: 852,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Top bar with back button
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Character display area
              Expanded(
                flex: 4,
                child: Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        'Characte Placeholder',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              // Coins & button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.monetization_on, color: Color(0xFFFFC107)),
                    const SizedBox(width: 4),
                    Text(
                      '${profile.coins} 코인',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Handle purchase
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBF622C),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('새로운 데코 얻기 (40)'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Decor grid placeholder
              Expanded(
                flex: 5,
                child: Container(
                  color: const Color(0xFFFFF5E5),
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: 12,
                    itemBuilder: (_, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x19000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.image, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
              // Bottom nav
              const SizedBox(height: 56),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavButton(icon: Icons.home, label: '홈', route: '/dashboard'),
              _NavButton(icon: Icons.format_list_bulleted, label: '프로젝트', route: '/project'),
              const SizedBox(width: 56), // space for FAB
              _NavButton(icon: Icons.person_outline, label: '프로필', route: '/profile'),
              _NavButton(icon: Icons.pets, label: '캐릭터', route: '/decor'),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        backgroundColor: const Color(0xFFBF622C),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.label, required this.route});
  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route, arguments: profile),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: const Color(0xFF9AA5B6)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF9AA5B6))),
        ],
      ),
    );
  }
}
