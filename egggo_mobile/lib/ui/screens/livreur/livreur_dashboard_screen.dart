import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/livreur_provider.dart';
import '../../../data/models/livreur_dashboard.dart';
import '../../../core/theme/app_theme.dart';

/// Dashboard du livreur avec fonctionnalités complètes
class LivreurDashboardScreen extends StatefulWidget {
  const LivreurDashboardScreen({super.key});

  @override
  State<LivreurDashboardScreen> createState() => _LivreurDashboardScreenState();
}

class _LivreurDashboardScreenState extends State<LivreurDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LivreurProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DashboardTab(),
          _LivraisonsTab(),
          _ProfilTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppTheme.primaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Livraisons'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

/// Onglet Dashboard avec statistiques réelles
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;

    return SafeArea(
      child: Consumer<LivreurProvider>(
        builder: (context, livreurProvider, _) {
          final dashboard = livreurProvider.dashboard ?? LivreurDashboard.empty();
          final isLoading = livreurProvider.isLoading;

          return RefreshIndicator(
            onRefresh: () => livreurProvider.loadDashboard(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec toggle de disponibilité
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bonjour, ${user?.prenom ?? "Livreur"} 🚀',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: livreurProvider.disponible ? Colors.green : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  livreurProvider.disponible ? 'En service' : 'Hors ligne',
                                  style: TextStyle(
                                    color: livreurProvider.disponible ? Colors.green : Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: livreurProvider.disponible,
                        onChanged: (val) async {
                          await livreurProvider.setDisponibilite(val);
                        },
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Livraison en cours
                  if (dashboard.livraisonEnCours != null) ...[
                    _LivraisonEnCoursCard(livraison: dashboard.livraisonEnCours!),
                    const SizedBox(height: 24),
                  ] else if (livreurProvider.disponible) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Livraison en cours',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Aucune',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Vous n\'avez pas de livraison en cours.\nConsultez les livraisons en attente ci-dessous.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Statistiques du jour
                  Text(
                    'Statistiques du jour',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _StatCard(
                        icon: Icons.local_shipping,
                        value: dashboard.livraisonsJour.toString(),
                        label: 'Livraisons',
                        color: Colors.blue,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(
                        icon: Icons.monetization_on,
                        value: '${dashboard.gainsJour.toStringAsFixed(0)} FCFA',
                        label: 'Gains',
                        color: Colors.green,
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _StatCard(
                        icon: Icons.route,
                        value: '${dashboard.distanceJour.toStringAsFixed(1)} km',
                        label: 'Distance',
                        color: Colors.orange,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(
                        icon: Icons.star,
                        value: dashboard.noteMoyenne.toStringAsFixed(1),
                        label: 'Note',
                        color: Colors.amber,
                      )),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Livraisons en attente
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Livraisons en attente',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (dashboard.livraisonsEnAttente > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            dashboard.livraisonsEnAttente.toString(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (dashboard.livraisonsEnAttenteList.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              'Aucune livraison en attente',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...dashboard.livraisonsEnAttenteList.map(
                      (livraison) => _LivraisonAttenteCard(
                        livraison: livraison,
                        onAccepter: () async {
                          final success = await context.read<LivreurProvider>()
                              .accepterLivraison(livraison.id);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Livraison acceptée !'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            context.read<LivreurProvider>().loadDashboard();
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Carte de livraison en cours
class _LivraisonEnCoursCard extends StatelessWidget {
  final LivraisonEnCours livraison;

  const _LivraisonEnCoursCard({required this.livraison});

  Future<void> _ouvrirNavigation(double? lat, double? lng, String adresse) async {
    if (lat != null && lng != null) {
      final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green, Colors.green.shade700],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🚴 Livraison en cours',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  livraison.reference,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.person, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(
                livraison.clientNom,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  livraison.adresseLivraison,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final url = Uri.parse('tel:${livraison.clientTelephone}');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green,
                  ),
                  icon: const Icon(Icons.phone, size: 18),
                  label: const Text('Appeler'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _ouvrirNavigation(
                    livraison.clientLatitude,
                    livraison.clientLongitude,
                    livraison.adresseLivraison,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.green,
                  ),
                  icon: const Icon(Icons.navigation, size: 18),
                  label: const Text('Naviguer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Carte de livraison en attente
class _LivraisonAttenteCard extends StatelessWidget {
  final LivraisonAttente livraison;
  final VoidCallback onAccepter;

  const _LivraisonAttenteCard({
    required this.livraison,
    required this.onAccepter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                livraison.reference,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${livraison.fraisLivraison.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.store, color: Colors.blue, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  livraison.adresseRecuperation,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.arrow_downward, color: Colors.grey, size: 16),
          ),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  livraison.adresseLivraison,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ),
            ],
          ),
          if (livraison.distance != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.route, color: Colors.grey[400], size: 16),
                const SizedBox(width: 8),
                Text(
                  '${livraison.distance!.toStringAsFixed(1)} km',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAccepter,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Accepter'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Onglet Livraisons avec filtres
class _LivraisonsTab extends StatefulWidget {
  const _LivraisonsTab();

  @override
  State<_LivraisonsTab> createState() => _LivraisonsTabState();
}

class _LivraisonsTabState extends State<_LivraisonsTab> {
  String _selectedFilter = 'TOUTES';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LivreurProvider>().loadLivraisons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // En-tête
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mes livraisons',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => context.read<LivreurProvider>().loadLivraisons(),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          
          // Filtres
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('TOUTES', 'Toutes'),
                _buildFilterChip('ASSIGNEE', 'En attente'),
                _buildFilterChip('ACCEPTEE', 'Acceptées'),
                _buildFilterChip('EN_ROUTE', 'En cours'),
                _buildFilterChip('LIVREE', 'Terminées'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Liste des livraisons
          Expanded(
            child: Consumer<LivreurProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final livraisons = provider.livraisons.where((l) {
                  if (_selectedFilter == 'TOUTES') return true;
                  return l.statut == _selectedFilter;
                }).toList();

                if (livraisons.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_shipping, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune livraison',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadLivraisons(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: livraisons.length,
                    itemBuilder: (context, index) {
                      return _LivraisonCard(livraison: livraisons[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _selectedFilter = selected ? value : 'TOUTES');
        },
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
      ),
    );
  }
}

/// Carte de livraison complète
class _LivraisonCard extends StatelessWidget {
  final Livraison livraison;

  const _LivraisonCard({required this.livraison});

  Color _getStatutColor() {
    switch (livraison.statut) {
      case 'ASSIGNEE':
        return Colors.orange;
      case 'ACCEPTEE':
        return Colors.blue;
      case 'EN_ROUTE_PRODUCTEUR':
      case 'EN_ROUTE_CLIENT':
        return Colors.purple;
      case 'LIVREE':
        return Colors.green;
      case 'ECHOUEE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatutLabel() {
    switch (livraison.statut) {
      case 'ASSIGNEE':
        return 'En attente';
      case 'ACCEPTEE':
        return 'Acceptée';
      case 'EN_ROUTE_PRODUCTEUR':
        return 'Vers producteur';
      case 'EN_ROUTE_CLIENT':
        return 'Vers client';
      case 'LIVREE':
        return 'Livrée';
      case 'ECHOUEE':
        return 'Échouée';
      default:
        return livraison.statut;
    }
  }

  IconData _getStatutIcon() {
    switch (livraison.statut) {
      case 'ASSIGNEE':
        return Icons.hourglass_empty;
      case 'ACCEPTEE':
        return Icons.check_circle;
      case 'EN_ROUTE_PRODUCTEUR':
      case 'EN_ROUTE_CLIENT':
        return Icons.directions_bike;
      case 'LIVREE':
        return Icons.done_all;
      case 'ECHOUEE':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(_getStatutIcon(), color: _getStatutColor(), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    livraison.reference,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatutColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatutLabel(),
                  style: TextStyle(
                    color: _getStatutColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(livraison.clientNom),
              const SizedBox(width: 16),
              const Icon(Icons.phone, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(livraison.clientTelephone),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(child: Text(livraison.adresseLivraison, style: TextStyle(color: Colors.grey[600]))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateFormat.format(livraison.dateCreation),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              Text(
                '${livraison.fraisLivraison.toStringAsFixed(0)} FCFA',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
          
          // Boutons d'action selon le statut
          if (livraison.statut == 'ASSIGNEE' || 
              livraison.statut == 'ACCEPTEE' || 
              livraison.statut.contains('EN_ROUTE')) ...[
            const SizedBox(height: 12),
            _buildActionButtons(context),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final provider = context.read<LivreurProvider>();
    
    switch (livraison.statut) {
      case 'ASSIGNEE':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              await provider.accepterLivraison(livraison.id);
              provider.loadLivraisons();
            },
            child: const Text('Accepter'),
          ),
        );
      case 'ACCEPTEE':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              await provider.signalerRecuperation(livraison.id);
              provider.loadLivraisons();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Commande récupérée'),
          ),
        );
      case 'EN_ROUTE_PRODUCTEUR':
      case 'EN_ROUTE_CLIENT':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await provider.signalerArrivee(livraison.id);
                  provider.loadLivraisons();
                },
                child: const Text('Je suis arrivé'),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _showProblemeDialog(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Icon(Icons.warning),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showProblemeDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Signaler un problème'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Décrivez le problème...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await context.read<LivreurProvider>().signalerProbleme(
                  livraison.id,
                  controller.text,
                );
                if (ctx.mounted) Navigator.pop(ctx);
                context.read<LivreurProvider>().loadLivraisons();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Signaler'),
          ),
        ],
      ),
    );
  }
}

/// Carte de statistique
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// Onglet Profil livreur
class _ProfilTab extends StatelessWidget {
  const _ProfilTab();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: Text(
                user?.prenom.substring(0, 1).toUpperCase() ?? 'L',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.nomComplet ?? 'Livreur',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.telephone ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '🚴 LIVREUR',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _ProfileMenuItem(
              icon: Icons.bar_chart,
              title: 'Statistiques',
              subtitle: 'Voir mes performances',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.account_balance_wallet,
              title: 'Mes gains',
              subtitle: 'Historique des paiements',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.settings,
              title: 'Paramètres',
              subtitle: 'Configurer mon compte',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.help,
              title: 'Aide & Support',
              subtitle: 'Contacter l\'équipe EggGo',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Déconnexion'),
                      content: const Text('Voulez-vous vraiment vous déconnecter ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annuler'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Déconnexion'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await authProvider.logout();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Déconnexion'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
