import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/providers/commande_provider.dart';
import '../../../data/models/commande.dart';

/// Écran de détail d'une commande
class OrderDetailScreen extends StatefulWidget {
  final int commandeId;

  const OrderDetailScreen({
    super.key,
    required this.commandeId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommandeProvider>().chargerCommande(widget.commandeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail commande'),
      ),
      body: Consumer<CommandeProvider>(
        builder: (context, provider, child) {
          final commande = provider.commandeEnCours;

          if (provider.isLoading && commande == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (commande == null) {
            return const Center(
              child: Text('Commande non trouvée'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                _buildHeader(commande),
                const SizedBox(height: 24),

                // Statut timeline
                _buildStatusTimeline(commande.statut),
                const SizedBox(height: 24),

                // Adresse de livraison
                _buildSection(
                  title: 'Adresse de livraison',
                  icon: Icons.location_on,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (commande.adresseLivraison != null) ...[
                        Text(
                          commande.adresseLivraison!.quartier,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(commande.adresseLivraison!.rue),
                        if (commande.adresseLivraison!.complement != null &&
                            commande.adresseLivraison!.complement!.isNotEmpty)
                          Text(commande.adresseLivraison!.complement!),
                        Text(commande.adresseLivraison!.ville),
                      ] else
                        const Text('Adresse non disponible'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Articles
                _buildSection(
                  title: 'Articles commandés',
                  icon: Icons.egg,
                  child: Column(
                    children: commande.lignes.map((ligne) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[200]!),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.egg,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ligne.produitNom,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${ligne.prixUnitaire.toStringAsFixed(0)} FCFA x ${ligne.quantite}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${ligne.sousTotal.toStringAsFixed(0)} FCFA',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Récapitulatif
                _buildSection(
                  title: 'Récapitulatif',
                  icon: Icons.receipt,
                  child: Column(
                    children: [
                      _buildPriceRow('Sous-total', commande.sousTotal),
                      const SizedBox(height: 8),
                      _buildPriceRow(
                        'Frais de livraison',
                        commande.fraisLivraison ?? 500,
                      ),
                      const Divider(height: 24),
                      _buildPriceRow(
                        'Total',
                        commande.montantTotal,
                        isBold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Paiement
                _buildSection(
                  title: 'Mode de paiement',
                  icon: Icons.payment,
                  child: Row(
                    children: [
                      Icon(
                        _getPaymentIcon(commande.modePaiement),
                        color: _getPaymentColor(commande.modePaiement),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getPaymentLabel(commande.modePaiement),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Notes
                if (commande.notes != null && commande.notes!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Notes',
                    icon: Icons.note,
                    child: Text(commande.notes!),
                  ),
                ],

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Commande commande) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Commande',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    commande.reference,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                commande.montantFormate,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                commande.dateFormatee,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(StatutCommande statut) {
    final statuses = [
      StatutCommande.enAttente,
      StatutCommande.confirmee,
      StatutCommande.enPreparation,
      StatutCommande.enLivraison,
      StatutCommande.livree,
    ];

    final currentIndex = statuts.indexOf(statut);
    final isAnnulee = statut == StatutCommande.annulee;

    if (isAnnulee) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel, color: AppTheme.errorColor),
            SizedBox(width: 12),
            Text(
              'Commande annulée',
              style: TextStyle(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(statuses.length, (index) {
          final isCompleted = index <= currentIndex;
          final isCurrent = index == currentIndex;

          return Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.successColor
                      : Colors.grey[300],
                  shape: BoxShape.circle,
                  border: isCurrent
                      ? Border.all(
                          color: AppTheme.successColor,
                          width: 3,
                        )
                      : null,
                ),
                child: Icon(
                  _getStatusIcon(statuses[index]),
                  color: isCompleted ? Colors.white : Colors.grey[500],
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getStatusLabel(statuses[index]),
                style: TextStyle(
                  fontSize: 10,
                  color: isCompleted ? AppTheme.successColor : Colors.grey,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  List<StatutCommande> get statuts => [
    StatutCommande.enAttente,
    StatutCommande.confirmee,
    StatutCommande.enPreparation,
    StatutCommande.enLivraison,
    StatutCommande.livree,
  ];

  IconData _getStatusIcon(StatutCommande statut) {
    switch (statut) {
      case StatutCommande.enAttente:
        return Icons.hourglass_empty;
      case StatutCommande.confirmee:
        return Icons.check;
      case StatutCommande.enPreparation:
        return Icons.inventory;
      case StatutCommande.enLivraison:
        return Icons.local_shipping;
      case StatutCommande.livree:
        return Icons.done_all;
      case StatutCommande.annulee:
        return Icons.cancel;
    }
  }

  String _getStatusLabel(StatutCommande statut) {
    switch (statut) {
      case StatutCommande.enAttente:
        return 'Attente';
      case StatutCommande.confirmee:
        return 'Confirmée';
      case StatutCommande.enPreparation:
        return 'Préparation';
      case StatutCommande.enLivraison:
        return 'Livraison';
      case StatutCommande.livree:
        return 'Livrée';
      case StatutCommande.annulee:
        return 'Annulée';
    }
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isBold = false}) {
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
          '${amount.toStringAsFixed(0)} FCFA',
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppTheme.primaryColor : null,
          ),
        ),
      ],
    );
  }

  IconData _getPaymentIcon(ModePaiement? mode) {
    switch (mode) {
      case ModePaiement.orangeMoney:
        return Icons.phone_android;
      case ModePaiement.mtnMomo:
        return Icons.phone_android;
      case ModePaiement.cashLivraison:
        return Icons.payments;
      default:
        return Icons.payment;
    }
  }

  Color _getPaymentColor(ModePaiement? mode) {
    switch (mode) {
      case ModePaiement.orangeMoney:
        return AppTheme.orangeMoneyColor;
      case ModePaiement.mtnMomo:
        return AppTheme.mtnMomoColor;
      case ModePaiement.cashLivraison:
        return AppTheme.secondaryColor;
      default:
        return Colors.grey;
    }
  }

  String _getPaymentLabel(ModePaiement? mode) {
    switch (mode) {
      case ModePaiement.orangeMoney:
        return 'Orange Money';
      case ModePaiement.mtnMomo:
        return 'MTN Mobile Money';
      case ModePaiement.cashLivraison:
        return 'Cash à la livraison';
      default:
        return 'Non spécifié';
    }
  }
}
