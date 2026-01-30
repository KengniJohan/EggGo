import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/providers/cart_provider.dart';
import 'home/home_screen.dart';
import 'products/product_list_screen.dart';
import 'orders/orders_screen.dart';
import 'profile/profile_screen.dart';

/// Écran principal avec navigation par onglets
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ProductListScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
            },
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: cartProvider.nombreArticles > 0,
                  label: Text('${cartProvider.nombreArticles}'),
                  child: const Icon(Icons.egg_outlined),
                ),
                activeIcon: Badge(
                  isLabelVisible: cartProvider.nombreArticles > 0,
                  label: Text('${cartProvider.nombreArticles}'),
                  child: const Icon(Icons.egg),
                ),
                label: 'Produits',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: 'Commandes',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          );
        },
      ),
    );
  }
}
