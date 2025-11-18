import 'dart:convert';

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
      id: int.tryParse(j['id'].toString()) ?? 0,
      title: j['title'] ?? 'No Title',
      price: int.tryParse(j['price'].toString()) ?? 0,
      description: j['description'] ?? 'No Description',
      image: j['image'] ?? '',
      rating: int.tryParse(j['rating']?['rate'].toString() ?? '0') ?? 0,
    );
  }
}
