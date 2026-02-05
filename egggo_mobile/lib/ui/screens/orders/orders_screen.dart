import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/providers/commande_provider.dart';
import '../../../data/models/commande.dart';

/// Écran de la liste des commandes
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les commandes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerCommandes();
    });
  }

  Future<void> _chargerCommandes() async {
    await context.read<CommandeProvider>().chargerCommandes(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes commandes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/main');
            }
          },
        ),
      ),
      body: Consumer<CommandeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.commandes.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.commandes.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _chargerCommandes,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.commandes.length,
              itemBuilder: (context, index) {
                final commande = provider.commandes[index];
                return _buildOrderCard(commande);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'Aucune commande',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vos commandes apparaîtront ici',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Commander maintenant'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Commande commande) {
    final statusInfo = _getStatusInfo(commande.statut);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.push('/order/${commande.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec référence et statut
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    commande.reference,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusInfo.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusInfo.icon,
                          size: 16,
                          color: statusInfo.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusInfo.label,
                          style: TextStyle(
                            color: statusInfo.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Date et nombre d'articles
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
                  const SizedBox(width: 16),
                  Icon(
                    Icons.egg,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${commande.lignes.length} article(s)',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              
              const Divider(height: 24),
              
              // Liste des produits (max 3)
              ...commande.lignes.take(3).map((ligne) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ligne.produitNom,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text('x${ligne.quantite}'),
                  ],
                ),
              )),
              
              if (commande.lignes.length > 3)
                Text(
                  '+ ${commande.lignes.length - 3} autre(s)',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              
              const Divider(height: 24),
              
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    commande.montantFormate,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  StatusInfo _getStatusInfo(StatutCommande statut) {
    switch (statut) {
      case StatutCommande.enAttente:
        return StatusInfo(
          label: 'En attente',
          color: Colors.orange,
          icon: Icons.hourglass_empty,
        );
      case StatutCommande.confirmee:
        return StatusInfo(
          label: 'Confirmée',
          color: Colors.blue,
          icon: Icons.check_circle,
        );
      case StatutCommande.enPreparation:
        return StatusInfo(
          label: 'En préparation',
          color: Colors.purple,
          icon: Icons.inventory,
        );
      case StatutCommande.prete:
        return StatusInfo(
          label: 'Prête',
          color: Colors.teal,
          icon: Icons.check_box,
        );
      case StatutCommande.enLivraison:
        return StatusInfo(
          label: 'En livraison',
          color: AppTheme.infoColor,
          icon: Icons.local_shipping,
        );
      case StatutCommande.livree:
        return StatusInfo(
          label: 'Livrée',
          color: AppTheme.successColor,
          icon: Icons.done_all,
        );
      case StatutCommande.annulee:
        return StatusInfo(
          label: 'Annulée',
          color: AppTheme.errorColor,
          icon: Icons.cancel,
        );
    }
  }
}

class StatusInfo {
  final String label;
  final Color color;
  final IconData icon;

  StatusInfo({
    required this.label,
    required this.color,
    required this.icon,
  });
}
