import 'package:hive/hive.dart';

part 'cart_item_model.g.dart';

@HiveType(typeId: 3)
class CartItemModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String image;

  @HiveField(3)
  late int quantity;

  @HiveField(4)
  late double price;

  @HiveField(5)
  late String userEmail;

  CartItemModel({
    required this.id,
    required this.title,
    required this.image,
    required this.quantity,
    required this.price,
    required this.userEmail,
  });
}
