import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../theme/app_theme.dart';

class GeneratorScreen extends StatelessWidget {
  const GeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth =
            constraints.maxWidth > 600 ? 480.0 : constraints.maxWidth;
        return Scaffold(
          appBar: AppBar(title: const Text('Générateur')), // D-11
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code, // D-09
                    size: 64, // D-10
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 32), // UI-SPEC xl spacing
                  Text(
                    'Générateur',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 16), // UI-SPEC md spacing
                  Text(
                    'Créez un QR code à partir de texte',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

@Preview(name: 'Generator Screen', group: 'Screens')
Widget generatorPreview() {
  return MaterialApp(
    theme: buildLightTheme(),
    home: const GeneratorScreen(),
  );
}
