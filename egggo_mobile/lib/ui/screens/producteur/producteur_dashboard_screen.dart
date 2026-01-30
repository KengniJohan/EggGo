import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/producteur_provider.dart';
import '../../../data/models/producteur_dashboard.dart';
import '../../../core/theme/app_theme.dart';
import 'producteur_produits_screen.dart';
import 'producteur_commandes_screen.dart';

/// Dashboard du producteur avec statistiques réelles
class ProducteurDashboardScreen extends StatefulWidget {
  const ProducteurDashboardScreen({super.key});

  @override
  State<ProducteurDashboardScreen> createState() => _ProducteurDashboardScreenState();
}

class _ProducteurDashboardScreenState extends State<ProducteurDashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Charger les données au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProducteurProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const _DashboardHomeTab(),
      const ProducteurProduitsScreen(),
      const ProducteurCommandesScreen(),
      const _ProfilTab(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.egg), label: 'Produits'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Commandes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

/// Onglet Dashboard Home avec statistiques réelles
class _DashboardHomeTab extends StatelessWidget {
  const _DashboardHomeTab();

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: '', decimalDigits: 0);
    return '${formatter.format(amount)} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    
    return SafeArea(
      child: Consumer<ProducteurProvider>(
        builder: (context, producteurProvider, _) {
          final dashboard = producteurProvider.dashboard ?? ProducteurDashboard.empty();
          final isLoading = producteurProvider.isLoading;

          return RefreshIndicator(
            onRefresh: () => producteurProvider.loadDashboard(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bonjour, ${user?.prenom ?? "Producteur"} 👋',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Voici votre tableau de bord',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: const Icon(Icons.agriculture, color: AppTheme.primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Chiffre d'affaires du mois
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Chiffre d\'affaires du mois',
                              style: TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    dashboard.noteMoyenne.toStringAsFixed(1),
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _formatCurrency(dashboard.chiffreAffairesMois),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        const SizedBox(height: 4),
                        Text(
                          'Aujourd\'hui: ${_formatCurrency(dashboard.chiffreAffairesJour)}',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Statistiques rapides (4 cartes)
                  Row(
                    children: [
                      Expanded(child: _StatCard(
                        title: 'Commandes',
                        value: dashboard.totalCommandes.toString(),
                        icon: Icons.shopping_bag,
                        color: Colors.blue,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(
                        title: 'En attente',
                        value: dashboard.commandesEnAttente.toString(),
                        icon: Icons.hourglass_empty,
                        color: Colors.orange,
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _StatCard(
                        title: 'En stock',
                        value: dashboard.produitsEnStock.toString(),
                        icon: Icons.inventory_2,
                        color: Colors.green,
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(
                        title: 'Ruptures',
                        value: dashboard.produitsEnRupture.toString(),
                        icon: Icons.warning_amber,
                        color: dashboard.produitsEnRupture > 0 ? Colors.red : Colors.grey,
                      )),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Actions rapides
                  Text(
                    'Actions rapides',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    icon: Icons.add_circle,
                    title: 'Ajouter un produit',
                    subtitle: 'Publier une nouvelle offre',
                    onTap: () {
                      // Naviguer vers l'onglet Produits et ouvrir le formulaire
                      DefaultTabController.of(context).animateTo(1);
                    },
                  ),
                  const SizedBox(height: 8),
                  _QuickActionButton(
                    icon: Icons.inventory,
                    title: 'Gérer le stock',
                    subtitle: 'Mettre à jour les quantités',
                    onTap: () {
                      DefaultTabController.of(context).animateTo(1);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Dernières commandes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dernières commandes',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Naviguer vers l'onglet Commandes
                        },
                        child: const Text('Voir tout'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  if (dashboard.dernieresCommandes.isEmpty)
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
                              'Aucune commande récente',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...dashboard.dernieresCommandes.map((commande) => _CommandeCard(commande: commande)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Carte de commande récente
class _CommandeCard extends StatelessWidget {
  final CommandeRecente commande;

  const _CommandeCard({required this.commande});

  Color _getStatutColor() {
    switch (commande.statut) {
      case 'EN_ATTENTE':
        return Colors.orange;
      case 'CONFIRMEE':
        return Colors.blue;
      case 'EN_LIVRAISON':
        return Colors.purple;
      case 'LIVREE':
        return Colors.green;
      case 'ANNULEE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatutLabel() {
    switch (commande.statut) {
      case 'EN_ATTENTE':
        return 'En attente';
      case 'CONFIRMEE':
        return 'Confirmée';
      case 'EN_LIVRAISON':
        return 'En livraison';
      case 'LIVREE':
        return 'Livrée';
      case 'ANNULEE':
        return 'Annulée';
      default:
        return commande.statut;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getStatutColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.receipt, color: _getStatutColor()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  commande.reference,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  commande.clientNom,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                Text(
                  dateFormat.format(commande.dateCommande),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${commande.montant.toStringAsFixed(0)} FCFA',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatutColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatutLabel(),
                  style: TextStyle(
                    color: _getStatutColor(),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Carte de statistique
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouton d'action rapide
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.primaryColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

/// Onglet Profil producteur
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
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text(
                user?.prenom.substring(0, 1).toUpperCase() ?? 'P',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.nomComplet ?? 'Producteur',
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
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '🏭 PRODUCTEUR',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 32),
            _ProfileMenuItem(
              icon: Icons.store,
              title: 'Ma ferme',
              subtitle: 'Gérer les informations de ma ferme',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.people,
              title: 'Mes livreurs',
              subtitle: 'Livreurs rattachés à ma ferme',
              onTap: () {},
            ),
            _ProfileMenuItem(
              icon: Icons.bar_chart,
              title: 'Statistiques',
              subtitle: 'Voir mes performances',
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
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(title),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
