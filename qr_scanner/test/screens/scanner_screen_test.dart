import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner/screens/scanner_screen.dart';
import 'package:qr_scanner/services/permission_service.dart';
import 'package:qr_scanner/viewmodels/scanner_viewmodel.dart';

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
  });

  Widget buildApp() {
    return MaterialApp(
      home: ScannerScreen(
        viewModel: viewModel,
        mockController: mockController,
      ),
    );
  }

  testWidgets('ScannerScreen shows error when permission denied and handles settings button', (tester) async {
    when(() => mockPermissionService.hasCameraPermission()).thenAnswer((_) async => false);
    when(() => mockPermissionService.openSettings()).thenAnswer((_) async => true);

    await tester.pumpWidget(buildApp());
    // Wait for permission check
    await tester.pumpAndSettle();

    expect(find.text('Accès à l\'appareil photo requis'), findsWidgets);
    expect(find.text('Ouvrir les paramètres'), findsOneWidget);

    await tester.tap(find.text('Ouvrir les paramètres'));
    await tester.pumpAndSettle();

    verify(() => mockPermissionService.openSettings()).called(1);
  });

  testWidgets('ScannerScreen shows scanner when permission granted', (tester) async {
    when(() => mockPermissionService.hasCameraPermission()).thenAnswer((_) async => true);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(MobileScanner), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets); // Contains ScannerOverlayPainter
    expect(find.text('Placez le code QR dans la zone de visée'), findsOneWidget);
  });
}
