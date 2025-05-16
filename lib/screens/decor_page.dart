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
    final all      = await ItemService.getAllItems();
    final ownedIds = await ItemService.getOwnedItemIds();
    final coins    = await ItemService.getUserCoins();

    

    // 1️⃣ Try to load recent equipped model
    Item defaultIt;
    try {
      defaultIt = await ItemService.fetchRecentEquippedItem(); 
      defaultIt = await ItemService.getItemById(defaultIt.id); 
    } catch (_) {
      // 2️⃣ fallback to a hardcoded one if it fails
      defaultIt = await ItemService.getItemById(7); // fallback model
    }

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

  // 💰 Check coin balance first
  if (_coins < 50) {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Color(0xFFF2AC57)),
              const SizedBox(height: 16),
              const Text(
                '코인이 부족합니다',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              const Text(
                '프로젝트를 완료하고 보상을 받아보세요.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2AC57),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return;
  }

  setState(() => _isSpinning = true);

  try {
    // 1️⃣ Draw item
    final result = await ItemService.drawItem();
    final newId = (result['itemId'] as num).toInt();

    // 2️⃣ Update coin count
    final oldCoins = _coins;
    final updatedCoins = await ItemService.getUserCoins();
    setState(() => _coins = updatedCoins);
    //animateCoinChange(oldCoins, updatedCoins); // optional coin animation

    // 3️⃣ Update model
    
    final localNew = _allItems.firstWhere((i) => i.id == newId);
    setState(() {
      _ownedItemIds.add(newId);
      _currentModelSrc = localNew.imageUrl;
    });
    

    // 4️⃣ Equip (non-blocking)
    try {
      await ItemService.equipItem(newId);
    } catch (e) {
      debugPrint('⚠️ equipItem failed: $e');
    }

    // ✅ Coin amount now refreshed

    // ⏳ 5️⃣ Delay 5 seconds before celebration
    //await Future.delayed(const Duration(seconds: 1));
    

    // 6️⃣ Show celebration dialog
    await showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.celebration_outlined, size: 48, color: Color(0xFFF2AC57)),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  localNew.image2dUrl,
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '새로운 데코를 획득했습니다!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2AC57),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  } catch (e) { 
      await showDialog<void>(
        context: context,
        barrierColor: Colors.black26,
        builder: (_) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, size: 48, color: Color(0xFFF2AC57)),
                const SizedBox(height: 16),
                const Text(
                  '축하드립니다!\n보유 가능한 아이템을 전부 획득하셨습니다. 다음 아이템은 추후에 만나보실 수 있습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2AC57),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  } finally {
    // ALWAYS runs, even after `await showDialog`
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
          const SizedBox(height: 40),

          // 3D 모델 뷰어 (Key forces reload on URL change)
          Expanded(
            flex: 3,
            child: Center(
              child: _currentModelSrc != null
                  ? ModelViewer(
                      key: ValueKey(_currentModelSrc),
                      src: _currentModelSrc!,
                      
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
                const SizedBox(width: 8),
               Text(
                '$_coins 코인',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isSpinning ? null : _onDrawPressed,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, // ✅ sets text & icon color
                    backgroundColor: const Color(0xFFF2AC57),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSpinning
                      ? const SizedBox(
                          width: 16, height: 16,
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
