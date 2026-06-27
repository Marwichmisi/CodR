import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth =
            constraints.maxWidth > 600 ? 480.0 : constraints.maxWidth;
        return Scaffold(
          appBar: AppBar(title: const Text('QR Scanner')), // D-11
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history, // D-09
                    size: 64, // D-10
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 32), // UI-SPEC xl spacing
                  Text(
                    'Historique',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 16), // UI-SPEC md spacing
                  Text(
                    'Vos scans et générations récents',
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

@Preview(name: 'History Screen', group: 'Screens')
Widget historyPreview() {
  return MaterialApp(
    theme: buildLightTheme(),
    home: const HistoryScreen(),
  );
}
