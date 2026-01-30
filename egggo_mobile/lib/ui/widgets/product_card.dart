import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/produit.dart';
import '../../data/providers/cart_provider.dart';

/// Carte de produit
class ProductCard extends StatelessWidget {
  final Produit produit;

  const ProductCard({super.key, required this.produit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/products/${produit.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withOpacity(0.3),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: produit.imageUrl != null
                          ? Image.network(
                              produit.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.egg_alt,
                                  size: 64,
                                  color: AppTheme.primaryColor,
                                );
                              },
                            )
                          : const Icon(
                              Icons.egg_alt,
                              size: 64,
                              color: AppTheme.primaryColor,
                            ),
                    ),
                    // Badge disponibilité
                    if (!produit.enStock)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Épuisé',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Infos
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produit.nom,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          produit.prixFormate,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        // Bouton ajouter
                        Consumer<CartProvider>(
                          builder: (context, cart, child) {
                            final inCart = cart.contientProduit(produit.id);
                            
                            return GestureDetector(
                              onTap: produit.enStock
                                  ? () {
                                      cart.ajouterProduit(produit);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${produit.nom} ajouté au panier'),
                                          duration: const Duration(seconds: 1),
                                          action: SnackBarAction(
                                            label: 'Voir',
                                            onPressed: () => context.push(AppRoutes.cart),
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: inCart 
                                      ? AppTheme.secondaryColor 
                                      : (produit.enStock 
                                          ? AppTheme.primaryColor 
                                          : Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  inCart ? Icons.check : Icons.add,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            );
                          },
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
  }
}
