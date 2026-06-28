import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../models/content_type.dart';
import '../viewmodels/result_viewmodel.dart';
import '../theme/app_theme.dart';

/// Bottom sheet Material 3 affichant le contenu scanné et les actions contextuelles.
class ScanResultBottomSheet extends StatelessWidget {
  final String content;
  final ResultViewModel viewModel;
  final VoidCallback? onRetry;
  final VoidCallback? onClose;

  const ScanResultBottomSheet({
    required this.content,
    required this.viewModel,
    this.onRetry,
    this.onClose,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth =
                constraints.maxWidth > 600 ? 500.0 : constraints.maxWidth;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: _buildContent(context),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // État d'erreur — contenu vide ou invalide (D-13 à D-16)
    if (viewModel.hasError || viewModel.contentType == ContentType.empty) {
      return _buildErrorState(context, colorScheme);
    }

    // État normal — contenu valide
    return _buildNormalState(context, colorScheme);
  }

  Widget _buildErrorState(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône d'avertissement rouge (D-13)
          Icon(
            Icons.warning,
            size: 48,
            color: Color(0xFFD32F2F),
          ),
          const SizedBox(height: 16),
          // Message d'erreur (D-13)
          Text(
            'Code QR vide ou invalide',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Le contenu du code QR ne peut pas être traité. Veuillez scanner un autre code.',
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // Boutons Réessayer et Fermer (D-14, D-16: pas de Copier/Partager)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  onClose?.call();
                  Navigator.of(context).pop();
                },
                child: const Text('Fermer'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  onRetry?.call();
                  Navigator.of(context).pop();
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNormalState(BuildContext context, ColorScheme colorScheme) {
    final contentType = viewModel.contentType;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Titre — type de contenu détecté (Semibold 20px)
          Text(
            contentType.displayName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          // Zone de contenu scrollable (D-02 : hauteur max 200dp, fond #F4FAFC)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFF4FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Barre d'actions horizontale (D-01 : icône + texte court)
          _buildActionButtons(context, contentType),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ContentType contentType) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Bouton contextuel selon le type
        if (contentType == ContentType.url)
          _buildAccentButton(
            context,
            icon: Icons.open_in_browser,
            label: 'Ouvrir le lien',
            onPressed: () => viewModel.openUrl(content),
          ),
        if (contentType == ContentType.email)
          _buildAccentButton(
            context,
            icon: Icons.email,
            label: "Envoyer l'e-mail",
            onPressed: () => viewModel.sendEmail(content),
          ),
        if (contentType == ContentType.phone)
          _buildAccentButton(
            context,
            icon: Icons.phone,
            label: 'Appeler le numéro',
            onPressed: () => viewModel.callPhone(content),
          ),
        // Bouton Copier (toujours visible)
        _buildOutlineButton(
          context,
          icon: Icons.copy,
          label: 'Copier le texte',
          onPressed: () async {
            await viewModel.copyToClipboard(content);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Contenu copié'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        // Bouton Partager (toujours visible)
        _buildOutlineButton(
          context,
          icon: Icons.share,
          label: 'Partager le contenu',
          onPressed: () => viewModel.shareContent(content),
        ),
      ],
    );
  }

  Widget _buildAccentButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0083B0),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildOutlineButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

// Previews
@Preview(name: 'Bottom Sheet - URL', group: 'Widgets')
Widget bottomSheetUrlPreview() {
  final viewModel = ResultViewModel();
  viewModel.detectContentType('https://flutter.dev');
  return MaterialApp(
    theme: buildLightTheme(),
    home: Scaffold(
      body: ScanResultBottomSheet(
        content: 'https://flutter.dev',
        viewModel: viewModel,
      ),
    ),
  );
}

@Preview(name: 'Bottom Sheet - Email', group: 'Widgets')
Widget bottomSheetEmailPreview() {
  final viewModel = ResultViewModel();
  viewModel.detectContentType('user@example.com');
  return MaterialApp(
    theme: buildLightTheme(),
    home: Scaffold(
      body: ScanResultBottomSheet(
        content: 'user@example.com',
        viewModel: viewModel,
      ),
    ),
  );
}

@Preview(name: 'Bottom Sheet - Text', group: 'Widgets')
Widget bottomSheetTextPreview() {
  final viewModel = ResultViewModel();
  viewModel.detectContentType('Hello World');
  return MaterialApp(
    theme: buildLightTheme(),
    home: Scaffold(
      body: ScanResultBottomSheet(
        content: 'Hello World',
        viewModel: viewModel,
      ),
    ),
  );
}

@Preview(name: 'Bottom Sheet - Error', group: 'Widgets')
Widget bottomSheetErrorPreview() {
  final viewModel = ResultViewModel();
  viewModel.detectContentType('');
  return MaterialApp(
    theme: buildLightTheme(),
    home: Scaffold(
      body: ScanResultBottomSheet(
        content: '',
        viewModel: viewModel,
      ),
    ),
  );
}
