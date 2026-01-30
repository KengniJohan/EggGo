import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/auth_provider.dart';
import '../../widgets/feedback_widgets.dart';

/// Types de rôle disponibles pour l'inscription
enum RegisterRole { client, producteur, livreur }

/// Écran d'inscription avec choix du rôle
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers communs
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Controllers producteur
  final _nomFermeController = TextEditingController();
  final _adresseFermeController = TextEditingController();
  final _descriptionFermeController = TextEditingController();
  
  // Controllers livreur
  final _pieceIdentiteController = TextEditingController();
  final _zoneCouvertureController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _acceptTerms = false;
  
  // Rôle sélectionné
  RegisterRole _selectedRole = RegisterRole.client;
  
  // Type de véhicule pour livreur
  String _typeVehicule = 'MOTO';
  
  // Indépendant ou rattaché (livreur)
  bool _independant = true;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nomFermeController.dispose();
    _adresseFermeController.dispose();
    _descriptionFermeController.dispose();
    _pieceIdentiteController.dispose();
    _zoneCouvertureController.dispose();
    super.dispose();
  }

  String _getRoleString() {
    switch (_selectedRole) {
      case RegisterRole.client:
        return 'CLIENT';
      case RegisterRole.producteur:
        return 'PRODUCTEUR';
      case RegisterRole.livreur:
        return 'LIVREUR';
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      AppSnackBar.warning(context, 'Veuillez corriger les erreurs du formulaire');
      return;
    }

    if (!_acceptTerms) {
      AppSnackBar.warning(context, 'Veuillez accepter les conditions d\'utilisation');
      return;
    }

    setState(() => _isLoading = true);
    if (mounted) LoadingDialog.show(context, message: 'Création de votre compte...');

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.register(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        email: _emailController.text.trim(),
        telephone: _telephoneController.text.replaceAll(RegExp(r'\D'), ''),
        motDePasse: _passwordController.text,
        role: _getRoleString(),
        // Champs producteur
        nomFerme: _selectedRole == RegisterRole.producteur ? _nomFermeController.text.trim() : null,
        localisation: _selectedRole == RegisterRole.producteur ? _adresseFermeController.text.trim() : null,
        description: _selectedRole == RegisterRole.producteur ? _descriptionFermeController.text.trim() : null,
        // Champs livreur
        typeVehicule: _selectedRole == RegisterRole.livreur ? _typeVehicule : null,
        numeroPermis: _selectedRole == RegisterRole.livreur ? _pieceIdentiteController.text.trim() : null,
        zoneCouverture: _selectedRole == RegisterRole.livreur ? _zoneCouvertureController.text.trim() : null,
      );

      if (mounted) LoadingDialog.hide(context);
      setState(() => _isLoading = false);

      if (!mounted) return;

      if (success) {
        String message = 'Votre compte a été créé avec succès.';
        if (_selectedRole != RegisterRole.client) {
          message += '\n\nVotre compte doit être validé par un administrateur avant de pouvoir l\'utiliser.';
        }
        
        await FeedbackDialog.show(
          context,
          type: FeedbackType.success,
          title: 'Compte créé !',
          message: message,
          buttonText: _selectedRole == RegisterRole.client ? 'Commencer' : 'OK',
          onPressed: () {
            Navigator.of(context).pop();
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
          },
        );
      } else {
        final errorMsg = authProvider.errorMessage ?? 'Une erreur est survenue';
        await FeedbackDialog.show(
          context,
          type: FeedbackType.error,
          title: 'Échec de l\'inscription',
          message: _formatErrorMessage(errorMsg),
          buttonText: 'Réessayer',
        );
      }
    } catch (e) {
      if (mounted) LoadingDialog.hide(context);
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
    if (error.contains('téléphone') && error.contains('utilisé')) {
      return 'Ce numéro de téléphone est déjà associé à un compte.';
    }
    if (error.contains('email') && error.contains('utilisé')) {
      return 'Cet email est déjà associé à un compte.';
    }
    if (error.contains('connexion') || error.contains('internet')) {
      return 'Impossible de se connecter au serveur.';
    }
    return error;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Veuillez entrer votre numéro';
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length != 9) return 'Le numéro doit contenir 9 chiffres';
    if (!cleaned.startsWith('6')) return 'Le numéro doit commencer par 6';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Veuillez entrer votre email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Format d\'email invalide';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Titre
                const Text(
                  'Créer un compte',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choisissez votre type de compte',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // Sélection du rôle
                _buildRoleSelector(),
                const SizedBox(height: 24),

                // Formulaire commun
                _buildCommonFields(),
                
                // Formulaires spécifiques selon le rôle
                if (_selectedRole == RegisterRole.producteur) ...[
                  const SizedBox(height: 24),
                  _buildProducteurFields(),
                ],
                if (_selectedRole == RegisterRole.livreur) ...[
                  const SizedBox(height: 24),
                  _buildLivreurFields(),
                ],

                const SizedBox(height: 24),
                _buildPasswordFields(),
                const SizedBox(height: 24),
                _buildTermsCheckbox(),
                const SizedBox(height: 24),
                _buildSubmitButton(),
                const SizedBox(height: 16),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Je suis :',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildRoleCard(
              role: RegisterRole.client,
              icon: Icons.person,
              label: 'Client',
              description: 'Commander des œufs',
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildRoleCard(
              role: RegisterRole.producteur,
              icon: Icons.agriculture,
              label: 'Producteur',
              description: 'Vendre mes œufs',
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildRoleCard(
              role: RegisterRole.livreur,
              icon: Icons.delivery_dining,
              label: 'Livreur',
              description: 'Livrer les commandes',
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required RegisterRole role,
    required IconData icon,
    required String label,
    required String description,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.primaryColor : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommonFields() {
    return Column(
      children: [
        // Nom & Prénom
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _nomController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nom *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Requis';
                  if (value.trim().length < 2) return 'Min 2 car.';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _prenomController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Prénom *',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Requis';
                  if (value.trim().length < 2) return 'Min 2 car.';
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Téléphone
        TextFormField(
          controller: _telephoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Téléphone *',
            hintText: '6XX XXX XXX',
            prefixIcon: const Icon(Icons.phone_outlined),
            prefixText: '+237 ',
            helperText: 'Votre identifiant de connexion',
            helperStyle: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          validator: _validatePhone,
        ),
        const SizedBox(height: 16),

        // Email
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Email *',
            hintText: 'votre@email.com',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          validator: _validateEmail,
        ),
      ],
    );
  }

  Widget _buildProducteurFields() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.agriculture, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Informations de la ferme',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _nomFermeController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nom de la ferme *',
              prefixIcon: Icon(Icons.home_work_outlined),
            ),
            validator: (value) {
              if (_selectedRole == RegisterRole.producteur) {
                if (value == null || value.trim().isEmpty) return 'Requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _adresseFermeController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Adresse de la ferme *',
              prefixIcon: Icon(Icons.location_on_outlined),
              hintText: 'Quartier, Ville',
            ),
            validator: (value) {
              if (_selectedRole == RegisterRole.producteur) {
                if (value == null || value.trim().isEmpty) return 'Requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _descriptionFermeController,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Description (optionnel)',
              hintText: 'Décrivez votre ferme et vos produits...',
              alignLabelWithHint: true,
            ),
          ),
          
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Votre compte devra être validé par un administrateur avant de pouvoir publier des produits.',
                    style: TextStyle(fontSize: 12, color: Colors.orange[800]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivreurFields() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.delivery_dining, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Informations du livreur',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _pieceIdentiteController,
            decoration: const InputDecoration(
              labelText: 'Numéro de pièce d\'identité *',
              prefixIcon: Icon(Icons.badge_outlined),
              hintText: 'CNI ou Passeport',
            ),
            validator: (value) {
              if (_selectedRole == RegisterRole.livreur) {
                if (value == null || value.trim().isEmpty) return 'Requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Type de véhicule
          Text(
            'Type de véhicule *',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildVehiculeChip('MOTO', Icons.two_wheeler),
              const SizedBox(width: 12),
              _buildVehiculeChip('VELO', Icons.pedal_bike),
              const SizedBox(width: 12),
              _buildVehiculeChip('VOITURE', Icons.directions_car),
            ],
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _zoneCouvertureController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Zone de couverture *',
              prefixIcon: Icon(Icons.map_outlined),
              hintText: 'Ex: Douala, Akwa',
            ),
            validator: (value) {
              if (_selectedRole == RegisterRole.livreur) {
                if (value == null || value.trim().isEmpty) return 'Requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Type de livreur
          Text(
            'Type de livreur',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildLivreurTypeCard(
                  isIndependant: true,
                  title: 'Indépendant',
                  subtitle: 'Libre de choisir mes livraisons',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLivreurTypeCard(
                  isIndependant: false,
                  title: 'Rattaché',
                  subtitle: 'Livraisons exclusives',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Votre compte devra être validé par un administrateur avant de pouvoir effectuer des livraisons.',
                    style: TextStyle(fontSize: 12, color: Colors.orange[800]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiculeChip(String type, IconData icon) {
    final isSelected = _typeVehicule == type;
    return GestureDetector(
      onTap: () => setState(() => _typeVehicule = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLivreurTypeCard({required bool isIndependant, required String title, required String subtitle}) {
    final isSelected = _independant == isIndependant;
    return GestureDetector(
      onTap: () => setState(() => _independant = isIndependant),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordFields() {
    return Column(
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Mot de passe *',
            hintText: 'Minimum 6 caractères',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Veuillez entrer un mot de passe';
            if (value.length < 6) return 'Minimum 6 caractères';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _register(),
          decoration: InputDecoration(
            labelText: 'Confirmer le mot de passe *',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
          validator: (value) {
            if (value != _passwordController.text) return 'Les mots de passe ne correspondent pas';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (value) => setState(() => _acceptTerms = value ?? false),
            activeColor: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _acceptTerms = !_acceptTerms),
            child: RichText(
              text: TextSpan(
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                children: const [
                  TextSpan(text: 'J\'accepte les '),
                  TextSpan(
                    text: 'conditions d\'utilisation',
                    style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              )
            : Text(
                'Créer mon compte ${_selectedRole == RegisterRole.client ? '' : _selectedRole == RegisterRole.producteur ? 'Producteur' : 'Livreur'}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Déjà un compte ? ', style: TextStyle(color: Colors.grey[600])),
        TextButton(
          onPressed: () => context.go(AppRoutes.login),
          child: const Text('Se connecter', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
