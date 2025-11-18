import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/produk_model.dart';

class ApiService {
  final String _baseUrl = 'https://fakestoreapi.com/products';

  Future<List<dynamic>> fetchMenu() async {
    final res = await http.get(Uri.parse(_baseUrl));
    if (res.statusCode == 200) {
      final j = json.decode(res.body);

      return (j as List).map((e) => ProdukModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load menu');
    }
  }
}
