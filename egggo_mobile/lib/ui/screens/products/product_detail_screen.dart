import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/produit_provider.dart';
import '../../../data/providers/cart_provider.dart';
import '../../../data/models/produit.dart';

/// Écran détail d'un produit
class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Produit? _produit;
  bool _isLoading = true;
  int _quantite = 1;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final provider = context.read<ProduitProvider>();
    final produit = await provider.chargerProduitById(widget.productId);
    
    if (mounted) {
      setState(() {
        _produit = produit;
        _isLoading = false;
        _quantite = produit?.quantiteMinimale ?? 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _produit == null
              ? _buildErrorState()
              : _buildContent(),
      bottomNavigationBar: _produit != null && _produit!.enStock && !_isLoading
          ? _buildBottomBar()
          : null,
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Sélecteur quantité
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _quantite > (_produit!.quantiteMinimale)
                        ? () => setState(() => _quantite--)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '$_quantite',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _quantite < _produit!.stockDisponible
                        ? () => setState(() => _quantite++)
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Bouton ajouter
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final cart = context.read<CartProvider>();
                  cart.ajouterProduit(_produit!, quantite: _quantite);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$_quantite x ${_produit!.nom} ajouté au panier'),
                      action: SnackBarAction(
                        label: 'Voir panier',
                        onPressed: () => context.push(AppRoutes.cart),
                      ),
                    ),
                  );
                },
                child: Text(
                  'Ajouter • ${(_produit!.prix * _quantite).toStringAsFixed(0)} FCFA',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: 16),
          const Text('Produit non trouvé'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Retour'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final produit = _produit!;
    
    return CustomScrollView(
      slivers: [
        // Image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: AppTheme.primaryLight.withOpacity(0.3),
              child: produit.imageUrl != null
                  ? Image.network(
                      produit.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.egg_alt,
                            size: 120,
                            color: AppTheme.primaryColor,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(
                        Icons.egg_alt,
                        size: 120,
                        color: AppTheme.primaryColor,
                      ),
                    ),
            ),
          ),
          actions: [
            Consumer<CartProvider>(
              builder: (context, cart, child) {
                return IconButton(
                  onPressed: () => context.push(AppRoutes.cart),
                  icon: Badge(
                    isLabelVisible: cart.nombreArticles > 0,
                    label: Text('${cart.nombreArticles}'),
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                );
              },
            ),
          ],
        ),

        // Contenu
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nom et prix
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            produit.nom,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (produit.categorie != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                produit.categorie!.nom,
                                style: const TextStyle(
                                  color: AppTheme.primaryDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          produit.prixFormate,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          '/ ${produit.unite}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),

                // Disponibilité
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: produit.enStock 
                        ? AppTheme.successColor.withOpacity(0.1)
                        : AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        produit.enStock ? Icons.check_circle : Icons.cancel,
                        color: produit.enStock 
                            ? AppTheme.successColor 
                            : AppTheme.errorColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        produit.enStock 
                            ? '${produit.stockDisponible} ${produit.unite}s disponibles'
                            : 'Produit épuisé',
                        style: TextStyle(
                          color: produit.enStock 
                              ? AppTheme.successColor 
                              : AppTheme.errorColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Description
                if (produit.description != null) ...[
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    produit.description!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Producteur
                if (produit.producteurNom != null) ...[
                  const Text(
                    'Producteur',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.secondaryColor,
                          child: Text(
                            produit.producteurNom![0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          produit.producteurNom!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 100), // Espace pour le bouton
              ],
            ),
          ),
        ),
      ],
    );
  }
}
