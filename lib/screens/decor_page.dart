// lib/screens/decor/decor_page.dart

import 'package:flutter/material.dart';
import 'package:domo/models/item.dart';
import 'package:domo/services/item_service.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:domo/widgets/bottom_nav_bar.dart';

class DecorPage extends StatefulWidget {
  const DecorPage({Key? key}) : super(key: key);

  @override
  DecorPageState createState() => DecorPageState();
}

class DecorPageState extends State<DecorPage> {
  String? _currentModelSrc;
  bool _loadingData = true, _isSpinning = false;
  int _coins = 0;
  List<Item> _allItems = [];
  Set<int> _ownedItemIds = {};

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final all       = await ItemService.getAllItems();
      final ownedIds  = await ItemService.getOwnedItemIds();
      final coins     = await ItemService.getUserCoins();
      final defaultIt = await ItemService.getItemById(9);

      setState(() {
        _allItems        = all;
        _ownedItemIds    = ownedIds;
        _coins           = coins;
        _currentModelSrc = defaultIt.imageUrl;
        _loadingData     = false;
      });
    } catch (e, st) {
      debugPrint('❌ Init error: $e\n$st');
    }
  }

  Future<void> _onDrawPressed() async {
    if (_isSpinning) return;
    setState(() => _isSpinning = true);

    try {
      // 1) snapshot old owned IDs
      final before = Set<int>.from(_ownedItemIds);

      // 2) trigger draw
      await ItemService.drawItem();

      // 3) immediately re-fetch coins
      final updatedCoins = await ItemService.getUserCoins();
      setState(() => _coins = updatedCoins);

      // 4) re-fetch owned IDs and diff to find new ID
      final after    = await ItemService.getOwnedItemIds();
      final newIds   = after.difference(before);
      if (newIds.isEmpty) throw Exception('새 아이템을 찾을 수 없어요.');
      final newId    = newIds.first;

      // 5) immediately update model from local cache
      final localNew = _allItems.firstWhere((i) => i.id == newId);
      setState(() {
        _ownedItemIds.add(newId);
        _currentModelSrc = localNew.imageUrl;
      });

      // 6) optional: inform server you “equipped” it
      await ItemService.equipItem(newId);

      // 7) celebrate
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('🎉 새로운 데코 획득!'),
          content: Text('${localNew.name} 데코를 획득했습니다!'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인')),
          ],
        ),
      );
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      debugPrint('❌ Draw error: $e');
    } finally {
      setState(() => _isSpinning = false);
    }
  }

  Future<void> _onEquipTapped(int itemId) async {
    if (!_ownedItemIds.contains(itemId)) return;
    try {
      await ItemService.equipItem(itemId);
      final item = _allItems.firstWhere((i) => i.id == itemId);
      setState(() => _currentModelSrc = item.imageUrl);
    } catch (e) {
      debugPrint('❌ Equip error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingData) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const SizedBox(height: 16),

          // 3D 모델 뷰어 (Key forces reload on URL change)
          Expanded(
            flex: 3,
            child: Center(
              child: _currentModelSrc != null
                  ? ModelViewer(
                      key: ValueKey(_currentModelSrc),
                      src: _currentModelSrc!,
                      alt: '3D 데코 모델',
                      autoRotate: true,
                      cameraControls: true,
                      disableZoom: true,
                      disablePan: true,
                      backgroundColor: Colors.transparent,
                    )
                  : const CircularProgressIndicator(),
            ),
          ),

          // 코인 & 뽑기 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset('assets/png/coin.png', width: 20, height: 20),
                const SizedBox(width: 4),
                Text('$_coins 코인'),
                const SizedBox(width: 14),
                ElevatedButton(
                  onPressed: _isSpinning ? null : _onDrawPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2AC57),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSpinning
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('새로운 데코 얻기 (50)'),
                ),
              ],
            ),
          ),

          // 전체 아이템 그리드 (잠긴 항목은 락/어둡게)
          Expanded(
            flex: 4,
            child: Container(
              color: const Color(0xFFFFF5E5),
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12
                ),
                itemCount: _allItems.length,
                itemBuilder: (ctx, i) {
                  final item       = _allItems[i];
                  final isOwned    = _ownedItemIds.contains(item.id);
                  final isSelected = item.imageUrl == _currentModelSrc;

                  return GestureDetector(
                    onTap: isOwned ? () => _onEquipTapped(item.id) : null,
                    child: Container(
                      decoration: BoxDecoration(
                        border: isSelected ? Border.all(color: Colors.amber, width: 2) : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(fit: StackFit.expand, children: [
                          Image.network(item.image2dUrl, fit: BoxFit.cover),
                          if (!isOwned)
                            Container(
                              color: Colors.black.withOpacity(0.5),
                              alignment: Alignment.center,
                              child: const Icon(Icons.lock, color: Colors.white70, size: 32),
                            ),
                        ]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom nav
          SizedBox(height: 68, child: BottomNavBar(activeIndex: 3)),
        ],
      ),
    );
  }
}
