import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/cart_provider.dart';
import '../../../data/providers/commande_provider.dart';
import '../../../data/models/commande.dart';

/// Écran de checkout (validation de commande)
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rueController = TextEditingController();
  final _quartierController = TextEditingController();
  final _villeController = TextEditingController(text: 'Douala');
  final _complementController = TextEditingController();
  final _notesController = TextEditingController();
  
  ModePaiement _modePaiement = ModePaiement.orangeMoney;
  double _fraisLivraison = 500;
  bool _isLoading = false;

  @override
  void dispose() {
    _rueController.dispose();
    _quartierController.dispose();
    _villeController.dispose();
    _complementController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _passerCommande() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final cart = context.read<CartProvider>();
    final commandeProvider = context.read<CommandeProvider>();

    final nouvelleAdresse = Adresse(
      rue: _rueController.text.trim(),
      quartier: _quartierController.text.trim(),
      ville: _villeController.text.trim(),
      complement: _complementController.text.trim(),
    );

    final commande = await commandeProvider.creerCommande(
      cart: cart.cart,
      nouvelleAdresse: nouvelleAdresse,
      modePaiement: _modePaiement,
      notes: _notesController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (commande != null && mounted) {
      // Vider le panier
      cart.vider();
      
      // Aller au paiement si mobile money, sinon aux commandes
      if (_modePaiement != ModePaiement.cashLivraison) {
        context.push(AppRoutes.payment);
      } else {
        // Afficher confirmation et aller aux commandes
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppTheme.successColor),
                SizedBox(width: 12),
                Text('Commande confirmée'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Référence: ${commande.reference}'),
                const SizedBox(height: 8),
                Text('Total: ${commande.montantFormate}'),
                const SizedBox(height: 8),
                const Text('Paiement à la livraison'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.go(AppRoutes.orders);
                },
                child: const Text('Voir mes commandes'),
              ),
            ],
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            commandeProvider.errorMessage ?? 'Erreur lors de la commande',
          ),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Valider la commande'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Adresse de livraison
              const Text(
                'Adresse de livraison',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _quartierController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Quartier *',
                  hintText: 'Ex: Akwa, Bonapriso, Bonamoussadi...',
                  prefixIcon: Icon(Icons.location_city),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre quartier';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _rueController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Rue / Adresse *',
                  hintText: 'Ex: Rue 123, près du marché...',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre adresse';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _villeController,
                      decoration: const InputDecoration(
                        labelText: 'Ville *',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requis';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _complementController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Complément (optionnel)',
                  hintText: 'Étage, bâtiment, point de repère...',
                  prefixIcon: Icon(Icons.info_outline),
                ),
              ),
              
              const SizedBox(height: 32),

              // Mode de paiement
              const Text(
                'Mode de paiement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildPaymentOption(
                ModePaiement.orangeMoney,
                'Orange Money',
                Icons.phone_android,
                AppTheme.orangeMoneyColor,
              ),
              const SizedBox(height: 12),
              _buildPaymentOption(
                ModePaiement.mtnMomo,
                'MTN Mobile Money',
                Icons.phone_android,
                AppTheme.mtnMomoColor,
              ),
              const SizedBox(height: 12),
              _buildPaymentOption(
                ModePaiement.cashLivraison,
                'Cash à la livraison',
                Icons.payments,
                AppTheme.secondaryColor,
              ),

              const SizedBox(height: 32),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Notes (optionnel)',
                  hintText: 'Instructions particulières pour la livraison...',
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 32),

              // Récapitulatif
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Sous-total', cart.totalFormate),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Frais de livraison',
                      '${_fraisLivraison.toStringAsFixed(0)} FCFA',
                    ),
                    const Divider(height: 24),
                    _buildSummaryRow(
                      'Total',
                      '${(cart.total + _fraisLivraison).toStringAsFixed(0)} FCFA',
                      isBold: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _passerCommande,
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _modePaiement == ModePaiement.cashLivraison
                          ? 'Confirmer la commande'
                          : 'Continuer vers le paiement',
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    ModePaiement mode,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _modePaiement == mode;
    
    return GestureDetector(
      onTap: () => setState(() => _modePaiement = mode),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppTheme.primaryColor : null,
          ),
        ),
      ],
    );
  }
}
