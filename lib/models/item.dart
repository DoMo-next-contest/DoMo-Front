class Item {
  final int    id;
  final String name;
  final String imageUrl;
  final String image2dUrl;

  Item({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.image2dUrl,
  });

  factory Item.fromJson(Map<String, dynamic> j) {
    // try both keys for each field:
    final rawId       = j['itemId']        ?? j['id'];
    final rawName     = j['itemName']      ?? j['name'];
    final rawImage    = j['itemImageUrl']  ?? j['imageUrl'];
    final rawImage2d  = j['item2dImageUrl']?? j['image2dUrl'];

    if (rawId == null || rawName == null || rawImage == null || rawImage2d == null) {
      throw FormatException('Invalid Item JSON: $j');
    }

    return Item(
      id:       (rawId as num).toInt(),
      name:     rawName    as String,
      imageUrl: rawImage   as String,
      image2dUrl:rawImage2d as String,
    );
  }
}
