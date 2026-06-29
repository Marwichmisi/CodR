import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../services/permission_service.dart';

class GeneratorViewModel extends ChangeNotifier {
  final PermissionService _permissionService;

  GeneratorViewModel({required PermissionService permissionService})
      : _permissionService = permissionService;

  Timer? _debounceTimer;

  String _inputText = '';
  String get inputText => _inputText;

  String _qrText = '';
  String get qrText => _qrText;

  bool _isUrlDetected = false;
  bool get isUrlDetected => _isUrlDetected;

  void updateText(String text) {
    _inputText = text;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _qrText = _processText(text);
      _isUrlDetected = _detectUrl(text);
      notifyListeners();
    });
    notifyListeners(); // Update counter immediately
  }

  String _processText(String text) {
    if (text.isEmpty) return '';
    if (_detectUrl(text) && !text.startsWith(RegExp(r'https?://|ftp://'))) {
      return 'https://$text';
    }
    return text;
  }

  bool _detectUrl(String text) {
    if (text.contains(' ')) return false;
    if (text.startsWith(RegExp(r'https?://|ftp://|www\.'))) return true;
    final urlExtensions = RegExp(
      r'\.(com|fr|org|net|io|edu|gov|co|info|biz)$',
      caseSensitive: false,
    );
    return text.contains('.') && urlExtensions.hasMatch(text);
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _inputText));
  }

  Future<bool> requestGalleryPermission() {
    return _permissionService.requestGalleryPermission();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
