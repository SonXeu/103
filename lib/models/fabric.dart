class Fabric {
  final String? id;  // Cho phép null vì Firestore sẽ tự động tạo ID
  final String name;
  final String category;
  final String material;
  final int quantity;
  final String imageUrl;

  Fabric({
    this.id,
    required this.name,
    required this.category,
    required this.material,
    required this.quantity,
    required this.imageUrl,
  });

  factory Fabric.fromFirestore(Map<String, dynamic> data, String id) {
    return Fabric(
      id: id,
      name: data['name'],
      category: data['category'],
      material: data['material'],
      quantity: data['quantity'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'Tên': name,
      'Loại vải':category,
      'Chất Liệu': material,
      'Số lượng': quantity,
      'imageUrl': imageUrl,
    };
  }
}
