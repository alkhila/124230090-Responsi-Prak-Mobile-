import 'dart:convert';

class ProdukModel {
  final int id;
  final String title;
  final double price;
  final String description;
  final String image;
  final double rating;

  ProdukModel({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.image,
    required this.rating,
  });

  Map<String, dynamic> toJson() {
    const double usdToIdrRate = 15000.0;

    final double convertedPrice = price * usdToIdrRate;

    return {
      'id': id,
      'title': title,
      'price': convertedPrice,
      'description': description,
      'image': image,
      'rating': {'rate': rating},
      'strMeal': title,
      'strMealThumb': image,
    };
  }

  factory ProdukModel.fromJson(Map<String, dynamic> j) {
    final double parsedPrice = double.tryParse(j['price'].toString()) ?? 0.0;
    final double parsedRating =
        double.tryParse(j['rating']?['rate'].toString() ?? '0.0') ?? 0.0;

    return ProdukModel(
      id: int.tryParse(j['id'].toString()) ?? 0,
      title: j['title'] ?? 'No Title',
      price: parsedPrice,
      description: j['description'] ?? 'No Description',
      image: j['image'] ?? '',
      rating: parsedRating,
    );
  }
}
