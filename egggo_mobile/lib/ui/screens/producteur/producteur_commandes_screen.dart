import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/producteur_provider.dart';
import '../../../data/models/commande.dart';

/// Écran de gestion des commandes pour les producteurs
class ProducteurCommandesScreen extends StatefulWidget {
  const ProducteurCommandesScreen({super.key});

  @override
  State<ProducteurCommandesScreen> createState() => _ProducteurCommandesScreenState();
}

class _ProducteurCommandesScreenState extends State<ProducteurCommandesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  StatutCommande _selectedStatut = StatutCommande.enAttente;

  final List<StatutCommande> _statuts = [
    StatutCommande.enAttente,
    StatutCommande.confirmee,
    StatutCommande.enPreparation,
    StatutCommande.prete,
    StatutCommande.enLivraison,
    StatutCommande.livree,
    StatutCommande.annulee,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuts.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCommandes();
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedStatut = _statuts[_tabController.index];
      });
      _loadCommandes();
    }
  }

  void _loadCommandes() {
    context.read<ProducteurProvider>().loadCommandes(statut: _selectedStatut.code);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commandes'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCommandes,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: _statuts.map((s) => Tab(text: s.libelle)).toList(),
        ),
      ),
      body: Consumer<ProducteurProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.commandes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: _statuts.map((s) {
              final commandes = provider.commandes
                  .where((c) => c.statut == s)
                  .toList();
              return _buildOrdersList(commandes, s);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildOrdersList(List<Commande> commandes, StatutCommande statut) {
    if (commandes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Aucune commande ${statut.libelle.toLowerCase()}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadCommandes(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: commandes.length,
        itemBuilder: (context, index) {
          return _CommandeCard(
            commande: commandes[index],
            onRefresh: _loadCommandes,
          );
        },
      ),
    );
  }
}

/// Carte de commande pour le producteur
class _CommandeCard extends StatelessWidget {
  final Commande commande;
  final VoidCallback onRefresh;

  const _CommandeCard({
    required this.commande,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      commande.reference,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    _StatusBadge(statut: commande.statut),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Adresse livraison
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on, color: Colors.green, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        commande.adresseLivraison?.adresseComplete ?? 'Adresse non renseignée',
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Date et heure
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.access_time, color: Colors.orange, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(commande.dateCreation),
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
                
                // Liste des articles
                if (commande.lignes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  ...commande.lignes.take(3).map((ligne) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${ligne.quantite}x ${ligne.produitNom}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Text(
                          '${ligne.sousTotal.toStringAsFixed(0)} F',
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                      ],
                    ),
                  )),
                  if (commande.lignes.length > 3)
                    Text(
                      '+ ${commande.lignes.length - 3} autres articles',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                ],
              ],
            ),
          ),
          
          // Footer avec montant et actions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      '${commande.montantTotal.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                _buildActions(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    switch (commande.statut) {
      case StatutCommande.enAttente:
        return Row(
          children: [
            OutlinedButton(
              onPressed: () => _showAnnulerDialog(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('Annuler'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _confirmerCommande(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Confirmer'),
            ),
          ],
        );
      case StatutCommande.confirmee:
        return ElevatedButton.icon(
          onPressed: () => _showAssignerLivreurDialog(context),
          icon: const Icon(Icons.local_shipping, size: 18),
          label: const Text('Assigner livreur'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
        );
      case StatutCommande.enPreparation:
        return ElevatedButton.icon(
          onPressed: () => _marquerPrete(context),
          icon: const Icon(Icons.check_box, size: 18),
          label: const Text('Marquer prête'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
          ),
        );
      case StatutCommande.prete:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.hourglass_bottom, color: Colors.green, size: 18),
              SizedBox(width: 6),
              Text(
                'En attente livreur',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      case StatutCommande.enLivraison:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.indigo.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              Icon(Icons.delivery_dining, color: Colors.indigo, size: 18),
              SizedBox(width: 6),
              Text(
                'En route',
                style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      case StatutCommande.livree:
        return const Icon(Icons.check_circle, color: Colors.green, size: 28);
      case StatutCommande.annulee:
        return const Icon(Icons.cancel, color: Colors.red, size: 28);
    }
  }

  void _confirmerCommande(BuildContext context) async {
    final provider = context.read<ProducteurProvider>();
    final success = await provider.confirmerCommande(commande.id);
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande confirmée'),
          backgroundColor: Colors.green,
        ),
      );
      onRefresh();
    }
  }

  void _marquerPrete(BuildContext context) async {
    final provider = context.read<ProducteurProvider>();
    final success = await provider.marquerPrete(commande.id);
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande prête ! Le livreur peut maintenant la récupérer.'),
          backgroundColor: Colors.orange,
        ),
      );
      onRefresh();
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${provider.errorMessage ?? "Impossible de marquer la commande comme prête"}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAnnulerDialog(BuildContext context) {
    final motifController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler la commande'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Veuillez indiquer le motif d\'annulation :'),
            const SizedBox(height: 16),
            TextField(
              controller: motifController,
              decoration: const InputDecoration(
                labelText: 'Motif',
                border: OutlineInputBorder(),
                hintText: 'Produit indisponible, etc.',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Retour'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (motifController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez entrer un motif')),
                );
                return;
              }
              
              final provider = context.read<ProducteurProvider>();
              final success = await provider.annulerCommande(
                commande.id,
                motifController.text.trim(),
              );
              
              if (ctx.mounted) Navigator.pop(ctx);
              
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Commande annulée'),
                    backgroundColor: Colors.orange,
                  ),
                );
                onRefresh();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Annuler la commande'),
          ),
        ],
      ),
    );
  }

  void _showAssignerLivreurDialog(BuildContext context) async {
    final provider = context.read<ProducteurProvider>();
    
    // Charger les livreurs disponibles
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );
    
    final livreurs = await provider.getLivreursDisponibles();
    
    if (context.mounted) Navigator.pop(context);
    
    if (livreurs.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun livreur disponible pour le moment'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
    
    if (!context.mounted) return;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choisir un livreur',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...livreurs.map((livreur) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withAlpha(25),
                child: const Icon(Icons.person, color: Colors.blue),
              ),
              title: Text(livreur['nom'] ?? 'Livreur'),
              subtitle: Row(
                children: [
                  Icon(Icons.two_wheeler, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(livreur['typeVehicule'] ?? ''),
                  const SizedBox(width: 12),
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text('${livreur['note'] ?? 'N/A'}'),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final success = await provider.assignerLivreur(
                    commande.id,
                    livreur['id'],
                  );
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Livreur assigné'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    onRefresh();
                  }
                },
                child: const Text('Assigner'),
              ),
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Badge de statut
class _StatusBadge extends StatelessWidget {
  final StatutCommande statut;

  const _StatusBadge({required this.statut});

  @override
  Widget build(BuildContext context) {
    Color color;
    
    switch (statut) {
      case StatutCommande.enAttente:
        color = Colors.orange;
        break;
      case StatutCommande.confirmee:
        color = Colors.blue;
        break;
      case StatutCommande.enPreparation:
        color = Colors.purple;
        break;
      case StatutCommande.prete:
        color = Colors.teal;
        break;
      case StatutCommande.enLivraison:
        color = Colors.indigo;
        break;
      case StatutCommande.livree:
        color = Colors.green;
        break;
      case StatutCommande.annulee:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statut.libelle,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
