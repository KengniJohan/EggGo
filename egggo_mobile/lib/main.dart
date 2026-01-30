import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'data/services/api_service.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/cart_provider.dart';
import 'data/providers/produit_provider.dart';
import 'data/providers/commande_provider.dart';
import 'data/providers/paiement_provider.dart';
import 'data/providers/producteur_provider.dart';
import 'data/providers/livreur_provider.dart';
import 'data/providers/admin_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EggGoApp());
}

class EggGoApp extends StatefulWidget {
  const EggGoApp({super.key});

  @override
  State<EggGoApp> createState() => _EggGoAppState();
}

class _EggGoAppState extends State<EggGoApp> {
  late final ApiService _apiService;
  late final AuthProvider _authProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _apiService = ApiService();
    _authProvider = AuthProvider(_apiService);
    _router = AppRouter.router(_authProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Service API (partagé)
        Provider<ApiService>.value(value: _apiService),
        
        // Providers
        ChangeNotifierProvider<AuthProvider>.value(
          value: _authProvider,
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProduitProvider(_apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => CommandeProvider(_apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => PaiementProvider(_apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => ProducteurProvider(_apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => LivreurProvider(_apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminProvider(_apiService),
        ),
      ],
      child: MaterialApp.router(
        title: 'EggGo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: _router,
      ),
    );
  }
}