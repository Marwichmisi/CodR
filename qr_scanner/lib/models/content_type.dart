/// Types de contenu détectés dans un QR code scanné.
enum ContentType { url, email, phone, text, empty }

/// Extension pour le nom d'affichage lisible de chaque type.
extension ContentTypeExtension on ContentType {
  String get displayName {
    switch (this) {
      case ContentType.url:
        return 'URL';
      case ContentType.email:
        return 'Email';
      case ContentType.phone:
        return 'Téléphone';
      case ContentType.text:
        return 'Texte';
      case ContentType.empty:
        return 'Vide';
    }
  }
}
