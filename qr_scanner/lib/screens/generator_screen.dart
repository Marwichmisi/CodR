import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widget_previews.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../theme/app_theme.dart';
import '../viewmodels/generator_viewmodel.dart';

class GeneratorScreen extends StatefulWidget {
  final GeneratorViewModel viewModel;

  const GeneratorScreen({required this.viewModel, super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final GlobalKey _qrKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth =
                constraints.maxWidth > 600 ? 480.0 : constraints.maxWidth;
            return Scaffold(
              appBar: AppBar(title: const Text('Générateur')),
              body: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        // TextField
                        TextField(
                          maxLines: 4,
                          minLines: 2,
                          maxLength: 250,
                          onChanged: (text) => widget.viewModel.updateText(text),
                          decoration: InputDecoration(
                            hintText: "Entrez du texte ou une URL...",
                            border: const OutlineInputBorder(),
                            counter: _buildCounter(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // URL Badge
                        if (widget.viewModel.isUrlDetected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.link,
                                  size: 16,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'URL détectée',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 24),
                        // QR Preview or Placeholder
                        _buildQrSection(),
                        const SizedBox(height: 24),
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                label: 'Sauvegarder',
                                icon: Icons.save_alt,
                                onPressed: _saveToGallery,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildActionButton(
                                label: 'Partager',
                                icon: Icons.share,
                                onPressed: _shareQrImage,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildActionButton(
                                label: 'Copier',
                                icon: Icons.content_copy,
                                onPressed: _copyToClipboard,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCounter() {
    final length = widget.viewModel.inputText.length;
    final isAtLimit = length >= 250;
    return Text(
      '$length/250',
      style: TextStyle(
        color: isAtLimit ? const Color(0xFFD32F2F) : null,
        fontSize: 12,
      ),
    );
  }

  Widget _buildQrSection() {
    if (widget.viewModel.qrText.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Saisissez du texte pour générer un QR code',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: RepaintBoundary(
        key: _qrKey,
        child: QrImageView(
          data: widget.viewModel.qrText,
          size: 300,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontSize: 14)),
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Future<void> _saveToGallery() async {
    final granted = await widget.viewModel.requestGalleryPermission();
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permission galerie refusée. Activez-la dans les réglages.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    try {
      final boundary = _qrKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final result = await SaverGallery.saveImage(
        pngBytes,
        fileName: 'qr_${DateTime.now().millisecondsSinceEpoch}.png',
        skipIfExists: false,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.isSuccess ? 'QR sauvegardé !' : 'Erreur lors de la sauvegarde',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la sauvegarde'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _shareQrImage() async {
    try {
      final boundary = _qrKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/qr_share.png')
          .writeAsBytes(pngBytes);

      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)]),
      );
    } catch (e) {
      // Share sheet is self-evident, no SnackBar needed per UI-SPEC
    }
  }

  void _copyToClipboard() {
    widget.viewModel.copyToClipboard();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copié !'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// Previews
class _MockGeneratorViewModel implements GeneratorViewModel {
  @override
  String get inputText => '';
  @override
  String get qrText => '';
  @override
  bool get isUrlDetected => false;

  @override
  void updateText(String text) {}
  @override
  void copyToClipboard() {}
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

@Preview(name: 'Generator Screen', group: 'Screens')
Widget generatorPreview() {
  return MaterialApp(
    theme: buildLightTheme(),
    home: GeneratorScreen(viewModel: _MockGeneratorViewModel()),
  );
}
