import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/auth_provider.dart';
import '../../widgets/feedback_widgets.dart';

/// Écran de connexion professionnel
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _telephoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      AppSnackBar.warning(context, 'Veuillez corriger les erreurs');
      return;
    }

    setState(() => _isLoading = true);

    // Afficher le dialog de chargement
    if (mounted) {
      LoadingDialog.show(context, message: 'Connexion en cours...');
    }

    try {
      final authProvider = context.read<AuthProvider>();
      final telephone = _telephoneController.text.replaceAll(RegExp(r'\D'), '');

      final success = await authProvider.login(
        telephone,
        _passwordController.text,
      );

      // Fermer le dialog de chargement
      if (mounted) {
        LoadingDialog.hide(context);
      }

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (success) {
        // Message de bienvenue rapide
        AppSnackBar.success(context, 'Bienvenue sur EggGo !');
        
        // Redirection selon le rôle de l'utilisateur
        final role = authProvider.user?.role?.toUpperCase();
        switch (role) {
          case 'ADMIN':
            context.go(AppRoutes.adminDashboard);
            break;
          case 'PRODUCTEUR':
            context.go(AppRoutes.producteurDashboard);
            break;
          case 'LIVREUR':
            context.go(AppRoutes.livreurDashboard);
            break;
          case 'CLIENT':
          default:
            context.go(AppRoutes.main);
        }
      } else {
        // Afficher l'erreur avec un dialog
        final errorMsg = authProvider.errorMessage ?? 'Identifiants incorrects';
        await FeedbackDialog.show(
          context,
          type: FeedbackType.error,
          title: 'Échec de connexion',
          message: _formatErrorMessage(errorMsg),
          buttonText: 'Réessayer',
        );
      }
    } catch (e) {
      if (mounted) {
        LoadingDialog.hide(context);
      }
      setState(() => _isLoading = false);

      if (mounted) {
        await FeedbackDialog.show(
          context,
          type: FeedbackType.error,
          title: 'Erreur',
          message: 'Une erreur inattendue s\'est produite.',
          buttonText: 'OK',
        );
      }
    }
  }

  String _formatErrorMessage(String error) {
    if (error.contains('Identifiants invalides') ||
        error.contains('invalides')) {
      return 'Numéro de téléphone ou mot de passe incorrect. Veuillez vérifier vos informations.';
    }
    if (error.contains('désactivé') || error.contains('Compte')) {
      return 'Votre compte a été désactivé. Contactez le support pour plus d\'informations.';
    }
    if (error.contains('connexion') || error.contains('internet')) {
      return 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
    }
    if (error.contains('timeout')) {
      return 'Le serveur met trop de temps à répondre. Veuillez réessayer.';
    }
    return error;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre numéro';
    }
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length != 9) {
      return 'Le numéro doit contenir 9 chiffres';
    }
    if (!cleaned.startsWith('6')) {
      return 'Le numéro doit commencer par 6';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                // Logo
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.egg_outlined,
                      size: 50,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Titre
                const Text(
                  'Bon retour !',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Connectez-vous pour commander vos œufs',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Téléphone (identifiant)
                TextFormField(
                  controller: _telephoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Numéro de téléphone',
                    hintText: '6XX XXX XXX',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    prefixText: '+237 ',
                    helperText:
                        'Entrez le numéro utilisé lors de l\'inscription',
                    helperStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                  validator: _validatePhone,
                ),
                const SizedBox(height: 16),

                // Mot de passe
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                // Mot de passe oublié
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      AppSnackBar.info(
                        context,
                        'Fonctionnalité bientôt disponible',
                      );
                    },
                    child: const Text('Mot de passe oublié ?'),
                  ),
                ),
                const SizedBox(height: 24),

                // Bouton Connexion
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      disabledBackgroundColor: AppTheme.primaryColor
                          .withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Se connecter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Séparateur
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OU',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                const SizedBox(height: 24),

                // Bouton continuer sans compte
                OutlinedButton(
                  onPressed: () {
                    AppSnackBar.info(
                      context,
                      'Créez un compte pour profiter de toutes les fonctionnalités',
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continuer en tant qu\'invité',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Lien inscription
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pas encore de compte ? ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.register),
                      child: const Text(
                        'S\'inscrire',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
