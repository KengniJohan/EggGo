import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Types de feedback
enum FeedbackType { success, error, warning, info, loading }

/// Widget pour afficher un dialog de chargement
class LoadingDialog extends StatelessWidget {
  final String message;

  const LoadingDialog({super.key, this.message = 'Veuillez patienter...'});

  static Future<void> show(BuildContext context, {String? message}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          LoadingDialog(message: message ?? 'Veuillez patienter...'),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget pour afficher un message de succès ou d'erreur
class FeedbackDialog extends StatelessWidget {
  final FeedbackType type;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onPressed;

  const FeedbackDialog({
    super.key,
    required this.type,
    required this.title,
    required this.message,
    this.buttonText,
    this.onPressed,
  });

  static Future<bool?> show(
    BuildContext context, {
    required FeedbackType type,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onPressed,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: type != FeedbackType.loading,
      builder: (context) => FeedbackDialog(
        type: type,
        title: title,
        message: message,
        buttonText: buttonText,
        onPressed: onPressed,
      ),
    );
  }

  IconData get _icon {
    switch (type) {
      case FeedbackType.success:
        return Icons.check_circle;
      case FeedbackType.error:
        return Icons.error;
      case FeedbackType.warning:
        return Icons.warning;
      case FeedbackType.info:
        return Icons.info;
      case FeedbackType.loading:
        return Icons.hourglass_empty;
    }
  }

  Color get _color {
    switch (type) {
      case FeedbackType.success:
        return AppTheme.successColor;
      case FeedbackType.error:
        return AppTheme.errorColor;
      case FeedbackType.warning:
        return Colors.orange;
      case FeedbackType.info:
        return AppTheme.primaryColor;
      case FeedbackType.loading:
        return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, size: 40, color: _color),
            ),
            const SizedBox(height: 16),
            // Titre
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Message
            Text(
              message,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Bouton
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onPressed ?? () => Navigator.of(context).pop(true),
                child: Text(
                  buttonText ?? 'OK',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Snackbar personnalisé pour les notifications rapides
class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    FeedbackType type = FeedbackType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final color = _getColor(type);
    final icon = _getIcon(type);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: duration,
      ),
    );
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, type: FeedbackType.success);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, type: FeedbackType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message: message, type: FeedbackType.warning);
  }

  static void info(BuildContext context, String message) {
    show(context, message: message, type: FeedbackType.info);
  }

  static Color _getColor(FeedbackType type) {
    switch (type) {
      case FeedbackType.success:
        return AppTheme.successColor;
      case FeedbackType.error:
        return AppTheme.errorColor;
      case FeedbackType.warning:
        return Colors.orange;
      case FeedbackType.info:
        return AppTheme.primaryColor;
      case FeedbackType.loading:
        return AppTheme.primaryColor;
    }
  }

  static IconData _getIcon(FeedbackType type) {
    switch (type) {
      case FeedbackType.success:
        return Icons.check_circle;
      case FeedbackType.error:
        return Icons.error;
      case FeedbackType.warning:
        return Icons.warning;
      case FeedbackType.info:
        return Icons.info;
      case FeedbackType.loading:
        return Icons.hourglass_empty;
    }
  }
}
