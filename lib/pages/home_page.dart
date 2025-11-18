import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import 'cart_page.dart';
import 'detail_page.dart';
import 'login_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'checkout_detail_page.dart';
import '../models/produk_model.dart';

const Color darkPrimaryColor = Color(0xFF703B3B);
const Color secondaryAccentColor = Color(0xFFA18D6D);
const Color lightBackgroundColor = Color(0xFFE1D0B3);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _userName = 'Pengguna';
  String _currentUserEmail = '';
  late Future<List<dynamic>> _menuFuture;

  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _menuFuture = _apiService.fetchMenu();
  }

  void _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'FastFoodie';
      _currentUserEmail = prefs.getString('current_user_email') ?? '';
    });
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Batal',
                style: TextStyle(color: darkPrimaryColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('current_user_email');

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  void _openDetailPage(Map<String, dynamic> item) {
    if (_currentUserEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon login terlebih dahulu.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DetailPage(item: item, currentUserEmail: _currentUserEmail),
      ),
    );
  }

  Widget _buildMenuCatalog() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome, $_userName",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: darkPrimaryColor,
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search...",
                  prefixIcon: Icon(Icons.search, color: darkPrimaryColor),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                ),
              ),

              const SizedBox(height: 15),
            ],
          ),
        ),

        Expanded(
          child: FutureBuilder<List<dynamic>>(
            future: _menuFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: darkPrimaryColor),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final rawMenuList = snapshot.data!;

                List<dynamic> filteredList = rawMenuList.where((item) {
                  final Map<String, dynamic> itemMap = (item as ProdukModel)
                      .toJson();

                  final String itemName = itemMap['title']?.toLowerCase() ?? '';
                  final bool matchesSearch = itemName.contains(
                    _searchQuery.toLowerCase(),
                  );

                  return matchesSearch;
                }).toList();

                if (filteredList.isEmpty) {
                  return Center(
                    child: Text(
                      'Menu tidak ditemukan.',
                      style: TextStyle(color: darkPrimaryColor),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final item = filteredList[index] as ProdukModel;
                    final itemMap = item.toJson();

                    final isLocalAsset = false;

                    return InkWell(
                      onTap: () => _openDetailPage(itemMap),
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: darkPrimaryColor.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                                child: Image.network(
                                  itemMap['strMealThumb'] ??
                                      'https://via.placeholder.com/150',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  8,
                                  10,
                                  8,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          itemMap['strMeal'] ?? 'Nama Menu',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: darkPrimaryColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Rp ${itemMap['price']?.toStringAsFixed(0) ?? 'N/A'}',
                                          style: const TextStyle(
                                            color: darkPrimaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),

                                        Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: darkPrimaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  child: Text(
                    'Tidak ada menu yang tersedia.',
                    style: TextStyle(color: darkPrimaryColor),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: darkPrimaryColor, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/alza.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person,
                          size: 60,
                          color: darkPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    'Alkhila Syadza Fariha / 124230090',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkPrimaryColor,
                    ),
                  ),

                  Text(
                    'Username: $_userName',
                    style: TextStyle(
                      fontSize: 18,
                      color: secondaryAccentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReceiptPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.history, color: Colors.white),
                    label: const Text(
                      'Riwayat Pembelian',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF703B3B),
                      foregroundColor: darkPrimaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: _confirmLogout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartPage() {
    return const CartPage();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      _buildMenuCatalog(),
      _buildCartPage(),
      _buildProfilePage(),
    ];

    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: AppBar(
        backgroundColor: lightBackgroundColor,
        elevation: 0,
        foregroundColor: darkPrimaryColor,

        title: Text(
          "MyToko",
          style: TextStyle(
            color: darkPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: widgetOptions.elementAt(_selectedIndex),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            label: 'Home',
            icon: Icon(Icons.home),
            backgroundColor: lightBackgroundColor,
          ),
          BottomNavigationBarItem(
            label: 'Keranjang',
            icon: Icon(Icons.shopping_cart),
            backgroundColor: lightBackgroundColor,
          ),
          BottomNavigationBarItem(
            label: 'Profil',
            icon: Icon(Icons.person),
            backgroundColor: lightBackgroundColor,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: darkPrimaryColor,
        unselectedItemColor: secondaryAccentColor,
        backgroundColor: lightBackgroundColor,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
