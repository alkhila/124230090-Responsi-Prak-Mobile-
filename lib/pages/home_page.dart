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

const Color darkPrimaryColor = Color(0xFF703B3B);
const Color secondaryAccentColor = Color(0xFFA18D6D);
const Color lightBackgroundColor = Color(0xFFE1D0B3);

enum MenuFilter { all, makanan, minuman }

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
  MenuFilter _currentFilter = MenuFilter.all;

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

  Widget _buildFilterChip(String label, MenuFilter filter) {
    bool isSelected = _currentFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: darkPrimaryColor,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _currentFilter = filter;
          });
        }
      },
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : darkPrimaryColor,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected
              ? darkPrimaryColor
              : secondaryAccentColor.withOpacity(0.5),
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
