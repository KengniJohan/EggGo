import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/commande_provider.dart';
import '../../../data/providers/paiement_provider.dart';

/// Écran de paiement Mobile Money
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String _selectedOperateur = 'ORANGE_MONEY';

  @override
  void initState() {
    super.initState();
    context.read<PaiementProvider>().reset();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _initierPaiement() async {
    final commande = context.read<CommandeProvider>().commandeEnCours;
    if (commande == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune commande en cours'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final phone = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (phone.length != 9 || !phone.startsWith('6')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Numéro de téléphone invalide (format: 6XX XXX XXX)'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final paiementProvider = context.read<PaiementProvider>();
    await paiementProvider.initierPaiement(
      commandeId: commande.id,
      modePaiement: _selectedOperateur,
      numeroTelephone: phone,
      montant: commande.montantTotal,
    );
  }

  Future<void> _confirmerPaiement() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer le code OTP'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final paiementProvider = context.read<PaiementProvider>();
    final success = await paiementProvider.confirmerPaiement(otp);

    if (success && mounted) {
      // Rafraîchir la commande
      final commandeProvider = context.read<CommandeProvider>();
      await commandeProvider.chargerCommande(
        paiementProvider.paiementEnCours!.commandeId!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
      ),
      body: Consumer<PaiementProvider>(
        builder: (context, provider, child) {
          // Afficher l'état approprié
          switch (provider.etat) {
            case PaiementEtat.succes:
              return _buildSuccessState(provider);
            case PaiementEtat.echec:
            case PaiementEtat.expire:
            case PaiementEtat.annule:
              return _buildErrorState(provider);
            case PaiementEtat.attenteConfirmation:
              return _buildOtpState(provider);
            default:
              return _buildInitialState(provider);
          }
        },
      ),
    );
  }

  Widget _buildInitialState(PaiementProvider provider) {
    final commande = context.watch<CommandeProvider>().commandeEnCours;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Montant
          Center(
            child: Column(
              children: [
                const Text(
                  'Montant à payer',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  commande?.montantFormate ?? '0 FCFA',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),

          // Sélection opérateur
          const Text(
            'Choisir l\'opérateur',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildOperatorCard(
                  'ORANGE_MONEY',
                  'Orange Money',
                  AppTheme.orangeMoneyColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildOperatorCard(
                  'MTN_MOMO',
                  'MTN MoMo',
                  AppTheme.mtnMomoColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Numéro de téléphone
          const Text(
            'Numéro de téléphone',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: '6XX XXX XXX',
              prefixText: '+237 ',
              prefixIcon: Icon(Icons.phone),
            ),
          ),

          const SizedBox(height: 16),

          // Note simulation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.infoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.infoColor.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.infoColor),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mode simulation: Entrez n\'importe quel numéro valide',
                    style: TextStyle(
                      color: AppTheme.infoColor,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Bouton
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: provider.isLoading ? null : _initierPaiement,
              child: provider.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Initier le paiement'),
            ),
          ),

          if (provider.errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              provider.errorMessage!,
              style: const TextStyle(color: AppTheme.errorColor),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOperatorCard(String code, String label, Color color) {
    final isSelected = _selectedOperateur == code;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedOperateur = code),
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
        child: Column(
          children: [
            Icon(
              Icons.phone_android,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpState(PaiementProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Icône
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.warningColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sms,
              size: 50,
              color: AppTheme.warningColor,
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Validation du paiement',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          if (provider.messageOperateur != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                provider.messageOperateur!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          
          const SizedBox(height: 32),
          
          // Code OTP
          const Text(
            'Entrez le code de confirmation',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
            decoration: const InputDecoration(
              hintText: '• • • •',
            ),
          ),
          
          const SizedBox(height: 16),

          // Indices simulation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.infoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Codes de simulation:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• 1234 → Paiement réussi ✓'),
                Text('• 0000 → Paiement échoué ✗'),
                Text('• 9999 → Timeout'),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Bouton confirmer
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: provider.isLoading ? null : _confirmerPaiement,
              child: provider.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Confirmer'),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Bouton annuler
          TextButton(
            onPressed: () {
              provider.reset();
            },
            child: const Text('Annuler le paiement'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(PaiementProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppTheme.successColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 60,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 32),
            
            const Text(
              'Paiement réussi !',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.successColor,
              ),
            ),
            
            const SizedBox(height: 16),
            
            if (provider.messageOperateur != null)
              Text(
                provider.messageOperateur!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            
            const SizedBox(height: 32),
            
            if (provider.paiementEnCours != null) ...[
              Text(
                'Transaction: ${provider.paiementEnCours!.transactionId}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Montant: ${provider.paiementEnCours!.montantFormate}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            
            const SizedBox(height: 48),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => context.go(AppRoutes.orders),
                child: const Text('Voir mes commandes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(PaiementProvider provider) {
    String title;
    String message;
    IconData icon;
    Color color;

    switch (provider.etat) {
      case PaiementEtat.expire:
        title = 'Délai expiré';
        message = 'Le délai de validation a expiré. Veuillez réessayer.';
        icon = Icons.timer_off;
        color = AppTheme.warningColor;
        break;
      case PaiementEtat.annule:
        title = 'Paiement annulé';
        message = 'Le paiement a été annulé.';
        icon = Icons.cancel;
        color = Colors.grey;
        break;
      default:
        title = 'Paiement échoué';
        message = provider.messageOperateur ?? 'Une erreur est survenue.';
        icon = Icons.error;
        color = AppTheme.errorColor;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 60, color: color),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 48),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  provider.reset();
                },
                child: const Text('Réessayer'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            TextButton(
              onPressed: () => context.go(AppRoutes.orders),
              child: const Text('Voir mes commandes'),
            ),
          ],
        ),
      ),
    );
  }
}
