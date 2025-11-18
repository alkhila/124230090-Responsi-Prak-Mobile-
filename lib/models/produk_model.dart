class ProdukModel {
  final int id;
  final String title;
  final int price;
  final String description;
  final String image;
  final int rating;

  ProdukModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.image,
    required this.rating,
  });

  factory ProdukModel.fromJson(Map<String, dynamic> j) {
    return ProdukModel(
      id: j['id'],
      title: j['title'] ?? 'No Title',
      price: j['price'] ?? '0',
      description: j['description'] ?? 'No Description',
      image: j['image'] ?? '',
      rating: j['rating']?['rate'] ?? '0',
    );
  }
}
