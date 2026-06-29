import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/scanner_screen.dart';
import '../screens/generator_screen.dart';
import '../screens/history_screen.dart';
import '../viewmodels/scanner_viewmodel.dart';
import '../viewmodels/generator_viewmodel.dart';
import '../viewmodels/result_viewmodel.dart';
import '../viewmodels/history_viewmodel.dart';
import '../services/permission_service.dart';
import '../services/storage_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

GoRouter createAppRouter({PermissionService? permissionService, StorageService? storageService, MobileScannerController? mockController}) {
  return GoRouter(
    initialLocation: '/scanner', // D-07: always Scanner at launch
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/scanner',
              builder: (context, state) => ScannerScreen(
                viewModel: ScannerViewModel(
                  permissionService: permissionService ?? SystemPermissionService(),
                  storageService: storageService,
                ),
                resultViewModel: ResultViewModel(),
                mockController: mockController,
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/generator',
              builder: (context, state) => GeneratorScreen(
                viewModel: GeneratorViewModel(
                  permissionService: permissionService ?? SystemPermissionService(),
                  storageService: storageService,
                ),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => HistoryScreen(
                viewModel: HistoryViewModel(
                  storageService: storageService ?? StorageService(),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);
}
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.camera_alt),
            label: 'Scanner',
          ),
          NavigationDestination(
            icon: Icon(Icons.qr_code),
            label: 'Générateur',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'Historique',
          ),
        ],
      ),
    );
  }
}
