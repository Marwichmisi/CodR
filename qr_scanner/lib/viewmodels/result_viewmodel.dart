import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../models/content_type.dart';

/// ViewModel pour gérer l'état du résultat de scan QR.
/// Suit le pattern ChangeNotifier identique à ScannerViewModel.
class ResultViewModel extends ChangeNotifier {
  ContentType _contentType = ContentType.text;
  ContentType get contentType => _contentType;

  bool _hasError = false;
  bool get hasError => _hasError;

  String _scannedContent = '';
  String get scannedContent => _scannedContent;

  /// Détecte le type de contenu et met à jour l'état.
  /// Priorité : URL > email > téléphone (D-08).
  void detectContentType(String content) {
    final trimmed = content.trim();
    _scannedContent = content;

    if (trimmed.isEmpty) {
      _contentType = ContentType.empty;
      _hasError = true;
    } else if (RegExp(r'^https?://').hasMatch(trimmed) &&
        Uri.tryParse(trimmed)?.isAbsolute == true) {
      _contentType = ContentType.url;
      _hasError = false;
    } else if (RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(trimmed)) {
      _contentType = ContentType.email;
      _hasError = false;
    } else if (RegExp(r'^\+?\d[\d\s\-\(\)]{8,13}\d$').hasMatch(trimmed)) {
      _contentType = ContentType.phone;
      _hasError = false;
    } else {
      _contentType = ContentType.text;
      _hasError = false;
    }

    notifyListeners();
  }

  /// Ouvre une URL dans le navigateur système.
  /// Vérifie canLaunchUrl avant de lancer (T-03-02).
  Future<void> openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      // Gestion silencieuse des erreurs
    }
  }

  /// Ouvre l'app mail par défaut avec le scheme mailto:.
  Future<void> sendEmail(String email) async {
    try {
      final uri = Uri(scheme: 'mailto', path: email);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      // Gestion silencieuse des erreurs
    }
  }

  /// Ouvre le dialer natif avec le scheme tel:.
  /// Jamais d'appel direct — l'utilisateur confirme dans le dialer (D-07).
  Future<void> callPhone(String phone) async {
    try {
      final uri = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      // Gestion silencieuse des erreurs
    }
  }

  /// Copie le contenu dans le presse-papiers système.
  Future<void> copyToClipboard(String content) async {
    try {
      await Clipboard.setData(ClipboardData(text: content));
    } catch (e) {
      // Gestion silencieuse des erreurs
    }
  }

  /// Partage le contenu via le share sheet natif.
  Future<void> shareContent(String content) async {
    try {
      await SharePlus.instance.share(ShareParams(text: content));
    } catch (e) {
      // Gestion silencieuse des erreurs
    }
  }
}
