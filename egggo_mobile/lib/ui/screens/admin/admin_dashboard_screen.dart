import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/admin_provider.dart';
import '../../../data/models/admin_dashboard.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';

/// Dashboard de l'administrateur
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _DashboardTab(),
          _ValidationsTab(),
          _StatsTab(),
          _ProfilTab(),
        ],
      ),
      bottomNavigationBar: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          final pendingCount = (provider.dashboard?.producteursEnAttente ?? 0) +
              (provider.dashboard?.livreursEnAttente ?? 0);
          
          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.primaryColor,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: pendingCount > 0,
                  label: Text('$pendingCount'),
                  child: const Icon(Icons.verified_user),
                ),
                label: 'Validations',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.analytics),
                label: 'Stats',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Onglet Dashboard
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        final dashboard = provider.dashboard ?? AdminDashboard.empty();

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () => provider.loadAll(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Administration 🔐',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tableau de bord EggGo',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),

                  // Statistiques globales
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      _DashboardCard(
                        icon: Icons.people,
                        title: 'Clients',
                        value: '${dashboard.totalClients}',
                        color: Colors.blue,
                      ),
                      _DashboardCard(
                        icon: Icons.agriculture,
                        title: 'Producteurs',
                        value: '${dashboard.totalProducteurs}',
                        color: Colors.green,
                      ),
                      _DashboardCard(
                        icon: Icons.local_shipping,
                        title: 'Livreurs',
                        value: '${dashboard.totalLivreurs}',
                        color: Colors.orange,
                      ),
                      _DashboardCard(
                        icon: Icons.shopping_cart,
                        title: 'Commandes',
                        value: '${dashboard.totalCommandes}',
                        color: Colors.purple,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // CA du mois
                  Container(
                    width: double.infinity,
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
                        const Text(
                          'Chiffre d\'affaires du mois',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_formatMontant(dashboard.chiffreAffairesMois)} FCFA',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: dashboard.variationCA >= 0
                                    ? Colors.green.withOpacity(0.3)
                                    : Colors.red.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    dashboard.variationCA >= 0
                                        ? Icons.arrow_upward
                                        : Icons.arrow_downward,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  Text(
                                    ' ${dashboard.variationCA.abs().toStringAsFixed(1)}%',
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'vs mois précédent',
                              style: TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'CA du jour',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              '${_formatMontant(dashboard.chiffreAffairesJour)} FCFA',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Commandes en cours
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.pending_actions, color: Colors.purple),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Commandes en cours',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${dashboard.commandesEnCours} commandes en traitement',
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Alertes
                  Text(
                    'À traiter',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _AlertCard(
                    icon: Icons.agriculture,
                    title: 'Producteurs en attente',
                    count: dashboard.producteursEnAttente,
                    color: Colors.orange,
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _AlertCard(
                    icon: Icons.local_shipping,
                    title: 'Livreurs en attente',
                    count: dashboard.livreursEnAttente,
                    color: Colors.blue,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatMontant(double montant) {
    if (montant >= 1000000) {
      return '${(montant / 1000000).toStringAsFixed(1)}M';
    } else if (montant >= 1000) {
      return '${(montant / 1000).toStringAsFixed(0)}K';
    }
    return montant.toStringAsFixed(0);
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.value,
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
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const _AlertCard({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: count > 0 ? color : Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}

/// Onglet Validations
class _ValidationsTab extends StatefulWidget {
  const _ValidationsTab();

  @override
  State<_ValidationsTab> createState() => _ValidationsTabState();
}

class _ValidationsTabState extends State<_ValidationsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    final provider = context.read<AdminProvider>();
    provider.loadProducteursEnAttente();
    provider.loadLivreursEnAttente();
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
        title: const Text('Validations'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: [
            Consumer<AdminProvider>(
              builder: (context, provider, _) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Producteurs'),
                    if (provider.producteursEnAttente.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${provider.producteursEnAttente.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Consumer<AdminProvider>(
              builder: (context, provider, _) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Livreurs'),
                    if (provider.livreursEnAttente.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${provider.livreursEnAttente.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ProducteursEnAttenteList(onRefresh: _loadData),
          _LivreursEnAttenteList(onRefresh: _loadData),
        ],
      ),
    );
  }
}

class _ProducteursEnAttenteList extends StatelessWidget {
  final VoidCallback onRefresh;

  const _ProducteursEnAttenteList({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.producteursEnAttente.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.producteursEnAttente.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 64, color: Colors.green[200]),
                const SizedBox(height: 16),
                const Text(
                  'Aucun producteur en attente',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.producteursEnAttente.length,
          itemBuilder: (context, index) {
            final producteur = provider.producteursEnAttente[index];
            return _ProducteurCard(
              producteur: producteur,
              onRefresh: onRefresh,
            );
          },
        );
      },
    );
  }
}

class _ProducteurCard extends StatelessWidget {
  final ProducteurEnAttente producteur;
  final VoidCallback onRefresh;

  const _ProducteurCard({required this.producteur, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green.withOpacity(0.1),
                      child: const Icon(Icons.agriculture, color: Colors.green),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            producteur.nom,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            producteur.email,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (producteur.nomFerme != null) ...[
                  _buildInfoRow(Icons.home, 'Ferme: ${producteur.nomFerme}'),
                  const SizedBox(height: 4),
                ],
                if (producteur.localisation != null) ...[
                  _buildInfoRow(Icons.location_on, producteur.localisation!),
                  const SizedBox(height: 4),
                ],
                if (producteur.telephone != null)
                  _buildInfoRow(Icons.phone, producteur.telephone!),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.calendar_today, _formatDate(producteur.dateInscription)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRejeterDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Rejeter'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _valider(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Valider'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
        ),
      ],
    );
  }

  void _valider(BuildContext context) async {
    final success = await context.read<AdminProvider>().validerProducteur(producteur.id);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Producteur validé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      onRefresh();
    }
  }

  void _showRejeterDialog(BuildContext context) {
    final motifController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rejeter le producteur'),
        content: TextField(
          controller: motifController,
          decoration: const InputDecoration(
            labelText: 'Motif du rejet',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (motifController.text.isEmpty) return;
              Navigator.pop(ctx);
              final success = await context.read<AdminProvider>().rejeterProducteur(
                producteur.id,
                motifController.text,
              );
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Producteur rejeté'),
                    backgroundColor: Colors.orange,
                  ),
                );
                onRefresh();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _LivreursEnAttenteList extends StatelessWidget {
  final VoidCallback onRefresh;

  const _LivreursEnAttenteList({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.livreursEnAttente.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.livreursEnAttente.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 64, color: Colors.green[200]),
                const SizedBox(height: 16),
                const Text(
                  'Aucun livreur en attente',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.livreursEnAttente.length,
          itemBuilder: (context, index) {
            final livreur = provider.livreursEnAttente[index];
            return _LivreurCard(
              livreur: livreur,
              onRefresh: onRefresh,
            );
          },
        );
      },
    );
  }
}

class _LivreurCard extends StatelessWidget {
  final LivreurEnAttente livreur;
  final VoidCallback onRefresh;

  const _LivreurCard({required this.livreur, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: const Icon(Icons.delivery_dining, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            livreur.nom,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            livreur.email,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (livreur.typeVehicule != null) ...[
                  _buildInfoRow(Icons.two_wheeler, 'Véhicule: ${livreur.typeVehicule}'),
                  const SizedBox(height: 4),
                ],
                if (livreur.numeroPermis != null) ...[
                  _buildInfoRow(Icons.badge, 'Permis: ${livreur.numeroPermis}'),
                  const SizedBox(height: 4),
                ],
                if (livreur.zoneCouverture != null) ...[
                  _buildInfoRow(Icons.map, 'Zone: ${livreur.zoneCouverture}'),
                  const SizedBox(height: 4),
                ],
                if (livreur.telephone != null)
                  _buildInfoRow(Icons.phone, livreur.telephone!),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.calendar_today, _formatDate(livreur.dateInscription)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRejeterDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('Rejeter'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _valider(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Valider'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
        ),
      ],
    );
  }

  void _valider(BuildContext context) async {
    final success = await context.read<AdminProvider>().validerLivreur(livreur.id);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Livreur validé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
      onRefresh();
    }
  }

  void _showRejeterDialog(BuildContext context) {
    final motifController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rejeter le livreur'),
        content: TextField(
          controller: motifController,
          decoration: const InputDecoration(
            labelText: 'Motif du rejet',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (motifController.text.isEmpty) return;
              Navigator.pop(ctx);
              final success = await context.read<AdminProvider>().rejeterLivreur(
                livreur.id,
                motifController.text,
              );
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Livreur rejeté'),
                    backgroundColor: Colors.orange,
                  ),
                );
                onRefresh();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Onglet Statistiques
class _StatsTab extends StatelessWidget {
  const _StatsTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          final dashboard = provider.dashboard ?? AdminDashboard.empty();
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vue d\'ensemble',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _StatRow(label: 'Total clients', value: '${dashboard.totalClients}'),
                _StatRow(label: 'Total producteurs', value: '${dashboard.totalProducteurs}'),
                _StatRow(label: 'Total livreurs', value: '${dashboard.totalLivreurs}'),
                _StatRow(label: 'Total commandes', value: '${dashboard.totalCommandes}'),
                const Divider(height: 32),
                _StatRow(
                  label: 'CA du mois',
                  value: '${dashboard.chiffreAffairesMois.toStringAsFixed(0)} FCFA',
                  isHighlighted: true,
                ),
                _StatRow(
                  label: 'CA du jour',
                  value: '${dashboard.chiffreAffairesJour.toStringAsFixed(0)} FCFA',
                ),
                const Divider(height: 32),
                _StatRow(
                  label: 'Commandes en cours',
                  value: '${dashboard.commandesEnCours}',
                ),
                _StatRow(
                  label: 'Producteurs en attente',
                  value: '${dashboard.producteursEnAttente}',
                  color: Colors.orange,
                ),
                _StatRow(
                  label: 'Livreurs en attente',
                  value: '${dashboard.livreursEnAttente}',
                  color: Colors.blue,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlighted;
  final Color? color;

  const _StatRow({
    required this.label,
    required this.value,
    this.isHighlighted = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: isHighlighted ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
              fontSize: isHighlighted ? 18 : 14,
              color: color ?? (isHighlighted ? AppTheme.primaryColor : null),
            ),
          ),
        ],
      ),
    );
  }
}

/// Onglet Profil
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
              backgroundColor: Colors.red.withOpacity(0.1),
              child: Text(
                user?.prenom.substring(0, 1).toUpperCase() ?? 'A',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.nomComplet ?? 'Administrateur',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(user?.email ?? '', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'ADMINISTRATEUR',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.settings, color: AppTheme.primaryColor),
              ),
              title: const Text('Paramètres'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await authProvider.logout();
                    if (!context.mounted) return;
                    context.go(AppRoutes.login);
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
