import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner/screens/scanner_screen.dart';
import 'package:qr_scanner/services/permission_service.dart';
import 'package:qr_scanner/viewmodels/scanner_viewmodel.dart';
import 'package:qr_scanner/viewmodels/result_viewmodel.dart';
import 'package:go_router/go_router.dart';

class MockPermissionService extends Mock implements PermissionService {}
class MockMobileScannerController extends Mock implements MobileScannerController {}

void main() {
  late MockPermissionService mockPermissionService;
  late ScannerViewModel viewModel;
  late MockMobileScannerController mockController;

  setUp(() {
    mockPermissionService = MockPermissionService();
    viewModel = ScannerViewModel(permissionService: mockPermissionService);
    mockController = MockMobileScannerController();
    
    when(() => mockController.value).thenReturn(const MobileScannerState.uninitialized());
    when(() => mockController.autoStart).thenReturn(false);
    when(() => mockController.addListener(any())).thenAnswer((_) {});
    when(() => mockController.removeListener(any())).thenAnswer((_) {});
    when(() => mockController.dispose()).thenAnswer((_) async {});
    when(() => mockController.start()).thenAnswer((_) async {});
    when(() => mockController.stop()).thenAnswer((_) async {});
    when(() => mockPermissionService.hasCameraPermission()).thenAnswer((_) async => true);
  });

  Widget buildApp(GoRouter router) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }

  testWidgets('ScannerScreen handles lifecycle and tab navigation', (tester) async {
    final router = GoRouter(
      initialLocation: '/scanner',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return Scaffold(
              body: navigationShell,
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: navigationShell.currentIndex,
                onTap: (index) => navigationShell.goBranch(index),
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Scanner'),
                  BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
                ],
              ),
            );
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/scanner',
                  builder: (context, state) => ScannerScreen(
                    viewModel: viewModel,
                    resultViewModel: ResultViewModel(),
                    mockController: mockController,
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/history',
                  builder: (context, state) => const Text('History'),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(buildApp(router));
    await tester.pumpAndSettle();

    verify(() => mockController.start()).called(greaterThanOrEqualTo(1));
    clearInteractions(mockController);

    // Pause
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    verify(() => mockController.stop()).called(1);
    clearInteractions(mockController);

    // Resume
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    verify(() => mockController.start()).called(1);
    clearInteractions(mockController);

    // Change tab
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    verify(() => mockController.stop()).called(1);
    clearInteractions(mockController);

    // Change back
    await tester.tap(find.text('Scanner'));
    await tester.pumpAndSettle();
    verify(() => mockController.start()).called(1);
  });
}
