import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:math';
import '../models/produk_model.dart';

class ApiService {
  final String _baseUrl = 'https://fakestoreapi.com/products';

  Future<List<dynamic>> fetchMenu() async {
    final res = await http.get(Uri.parse(_baseUrl)); // ambil data dari API
    if (res.statusCode == 200) {
      // cek apakah response ok
      final j = json.decode(res.body);

      // PERHATIKAN: KEY 'data' INI MUNGKIN BERUBAH DI API BARU
      // klo JIKAN itu ada di /top/anime, bagian respon body
      return (j as List)
          .map((e) => ProdukModel.fromJson(e))
          .toList(); // konversi ke List<ProdukModel>
    } else {
      // jika respon tidak ok
      throw Exception('Failed to load menu'); // lempar pesan error
    }
  }
}
