import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/auth_provider.dart';
import '../../ui/screens/splash_screen.dart';
import '../../ui/screens/onboarding_screen.dart';
import '../../ui/screens/auth/login_screen.dart';
import '../../ui/screens/auth/register_screen.dart';
import '../../ui/screens/products/product_list_screen.dart';
import '../../ui/screens/products/product_detail_screen.dart';
import '../../ui/screens/cart/cart_screen.dart';
import '../../ui/screens/checkout/checkout_screen.dart';
import '../../ui/screens/payment/payment_screen.dart';
import '../../ui/screens/orders/orders_screen.dart';
import '../../ui/screens/orders/order_detail_screen.dart';
import '../../ui/screens/profile/profile_screen.dart';
import '../../ui/screens/main_screen.dart';
import '../../ui/screens/producteur/producteur_dashboard_screen.dart';
import '../../ui/screens/livreur/livreur_dashboard_screen.dart';
import '../../ui/screens/admin/admin_dashboard_screen.dart';

/// Routes de l'application
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String home = '/home';
  static const String products = '/products';
  static const String productDetail = '/products/:id';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String payment = '/payment';
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:id';
  static const String profile = '/profile';
  
  // Routes par rôle
  static const String producteurDashboard = '/producteur';
  static const String livreurDashboard = '/livreur';
  static const String adminDashboard = '/admin';
}

/// Configuration du routeur
class AppRouter {
  /// Retourne la route du dashboard selon le rôle de l'utilisateur
  static String _getDashboardForRole(String? role) {
    switch (role?.toUpperCase()) {
      case 'ADMIN':
        return AppRoutes.adminDashboard;
      case 'PRODUCTEUR':
        return AppRoutes.producteurDashboard;
      case 'LIVREUR':
        return AppRoutes.livreurDashboard;
      case 'CLIENT':
      default:
        return AppRoutes.main;
    }
  }

  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      // Ne pas utiliser refreshListenable pour éviter les redirections en boucle
      // La navigation est gérée manuellement dans le splash screen
      redirect: (context, state) {
        final isAuth = authProvider.isAuthenticated;
        final status = authProvider.status;
        final isAuthRoute = state.matchedLocation == AppRoutes.login || 
                            state.matchedLocation == AppRoutes.register;
        final isSplash = state.matchedLocation == AppRoutes.splash;
        final isOnboarding = state.matchedLocation == AppRoutes.onboarding;

        // Toujours permettre l'accès au splash et onboarding
        if (isSplash || isOnboarding) {
          return null;
        }

        // Si en cours d'initialisation, ne pas rediriger
        if (status == AuthStatus.initial || status == AuthStatus.loading) {
          return null;
        }

        // Si non authentifié et essaie d'accéder à une route protégée
        if (!isAuth && !isAuthRoute) {
          return AppRoutes.login;
        }

        // Si authentifié et sur une route d'auth, rediriger vers le dashboard approprié
        if (isAuth && isAuthRoute) {
          return _getDashboardForRole(authProvider.user?.role);
        }

        return null;
      },
      routes: [
        // Splash
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        
        // Onboarding
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingScreen(),
        ),
        
        // Auth
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterScreen(),
        ),
        
        // Main (avec bottom navigation) - pour les clients
        GoRoute(
          path: AppRoutes.main,
          builder: (context, state) => const MainScreen(),
        ),
        
        // Producteur Dashboard
        GoRoute(
          path: AppRoutes.producteurDashboard,
          builder: (context, state) => const ProducteurDashboardScreen(),
        ),
        
        // Livreur Dashboard
        GoRoute(
          path: AppRoutes.livreurDashboard,
          builder: (context, state) => const LivreurDashboardScreen(),
        ),
        
        // Admin Dashboard
        GoRoute(
          path: AppRoutes.adminDashboard,
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        
        // Products
        GoRoute(
          path: AppRoutes.products,
          builder: (context, state) => const ProductListScreen(),
        ),
        GoRoute(
          path: AppRoutes.productDetail,
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return ProductDetailScreen(productId: id);
          },
        ),
        
        // Cart & Checkout
        GoRoute(
          path: AppRoutes.cart,
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: AppRoutes.checkout,
          builder: (context, state) => const CheckoutScreen(),
        ),
        GoRoute(
          path: AppRoutes.payment,
          builder: (context, state) => const PaymentScreen(),
        ),
        
        // Orders
        GoRoute(
          path: AppRoutes.orders,
          builder: (context, state) => const OrdersScreen(),
        ),
        GoRoute(
          path: AppRoutes.orderDetail,
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return OrderDetailScreen(commandeId: id);
          },
        ),
        // Alias pour /order/:id
        GoRoute(
          path: '/order/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return OrderDetailScreen(commandeId: id);
          },
        ),
        
        // Profile
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Page non trouvée: ${state.matchedLocation}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.main),
                child: const Text('Retour à l\'accueil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
