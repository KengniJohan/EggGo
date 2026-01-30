import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/auth_provider.dart';

/// Écran de profil utilisateur
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmerDeconnexion(context),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.user;

          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_circle,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Non connecté',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text('Se connecter'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar et info
                _buildProfileHeader(user),
                const SizedBox(height: 32),

                // Sections
                _buildSection(
                  context,
                  title: 'Mon compte',
                  items: [
                    _MenuItem(
                      icon: Icons.person,
                      label: 'Informations personnelles',
                      onTap: () => _showEditProfile(context),
                    ),
                    _MenuItem(
                      icon: Icons.lock,
                      label: 'Changer le mot de passe',
                      onTap: () => _showChangePassword(context),
                    ),
                    _MenuItem(
                      icon: Icons.location_on,
                      label: 'Mes adresses',
                      onTap: () => _showAddresses(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildSection(
                  context,
                  title: 'Mes commandes',
                  items: [
                    _MenuItem(
                      icon: Icons.receipt_long,
                      label: 'Historique des commandes',
                      onTap: () => context.go(AppRoutes.orders),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildSection(
                  context,
                  title: 'Préférences',
                  items: [
                    _MenuItem(
                      icon: Icons.notifications,
                      label: 'Notifications',
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {},
                        activeColor: AppTheme.primaryColor,
                      ),
                    ),
                    _MenuItem(
                      icon: Icons.language,
                      label: 'Langue',
                      trailing: const Text('Français'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildSection(
                  context,
                  title: 'Support',
                  items: [
                    _MenuItem(
                      icon: Icons.help_outline,
                      label: 'Centre d\'aide',
                      onTap: () => _showHelp(context),
                    ),
                    _MenuItem(
                      icon: Icons.chat_bubble_outline,
                      label: 'Nous contacter',
                      onTap: () => _showContact(context),
                    ),
                    _MenuItem(
                      icon: Icons.info_outline,
                      label: 'À propos',
                      onTap: () => _showAbout(context),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Bouton déconnexion
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmerDeconnexion(context),
                    icon: const Icon(Icons.logout, color: AppTheme.errorColor),
                    label: const Text(
                      'Déconnexion',
                      style: TextStyle(color: AppTheme.errorColor),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.errorColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Version
                Text(
                  'EggGo v1.0.0',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user) {
    return Column(
      children: [
        // Avatar
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person,
            size: 60,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),

        // Nom
        Text(
          '${user.prenom ?? ''} ${user.nom ?? ''}'.trim(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),

        // Email
        Text(
          user.email ?? '',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),

        // Téléphone
        if (user.telephone != null)
          Text(
            '+237 ${user.telephone}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        Container(
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
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  ListTile(
                    leading: Icon(item.icon, color: AppTheme.primaryColor),
                    title: Text(item.label),
                    trailing: item.trailing ??
                        (item.onTap != null
                            ? const Icon(Icons.chevron_right)
                            : null),
                    onTap: item.onTap,
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: Colors.grey[200],
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _confirmerDeconnexion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
              context.go(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    // TODO: Implémenter l'édition du profil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité à venir')),
    );
  }

  void _showChangePassword(BuildContext context) {
    // TODO: Implémenter le changement de mot de passe
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité à venir')),
    );
  }

  void _showAddresses(BuildContext context) {
    // TODO: Implémenter la gestion des adresses
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité à venir')),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Centre d\'aide'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Questions fréquentes:'),
            SizedBox(height: 12),
            Text('• Comment passer une commande ?'),
            Text('• Comment suivre ma livraison ?'),
            Text('• Comment contacter le support ?'),
            SizedBox(height: 16),
            Text(
              'Pour toute autre question, contactez-nous.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showContact(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nous contacter'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.phone, color: AppTheme.primaryColor),
                SizedBox(width: 12),
                Text('+237 6XX XXX XXX'),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.email, color: AppTheme.primaryColor),
                SizedBox(width: 12),
                Text('support@egggo.cm'),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, color: AppTheme.primaryColor),
                SizedBox(width: 12),
                Expanded(child: Text('Douala, Cameroun')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.egg, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('EggGo'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version 1.0.0',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'EggGo est votre application de livraison d\'œufs frais au Cameroun. '
              'Nous connectons les producteurs locaux directement aux consommateurs '
              'pour vous garantir des œufs de qualité, livrés rapidement.',
            ),
            SizedBox(height: 16),
            Text(
              '© 2024 EggGo. Tous droits réservés.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;

  _MenuItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
  });
}
