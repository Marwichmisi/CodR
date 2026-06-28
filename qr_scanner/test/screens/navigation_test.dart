import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_scanner/navigation/app_router.dart';
import 'package:qr_scanner/services/permission_service.dart';

import 'package:mobile_scanner/mobile_scanner.dart';

class MockPermissionService extends Mock implements PermissionService {}
class MockMobileScannerController extends Mock implements MobileScannerController {}

class FakeMobileScannerState extends Fake implements MobileScannerState {
  @override
  final bool isInitialized;
  @override
  final TorchState torchState;
  @override
  final MobileScannerException? error;
  @override
  final Size size;
  
  FakeMobileScannerState({
    this.isInitialized = true, 
    this.torchState = TorchState.off,
    this.error,
    this.size = Size.zero,
  });
  
  @override
  final DeviceOrientation deviceOrientation = DeviceOrientation.portraitUp;
}

void main() {
  late MockPermissionService mockPermissionService;
  late MockMobileScannerController mockController;

  setUp(() {
    mockPermissionService = MockPermissionService();
    when(() => mockPermissionService.hasCameraPermission()).thenAnswer((_) async => true);
    when(() => mockPermissionService.requestCameraPermission()).thenAnswer((_) async => true);

    mockController = MockMobileScannerController();
    when(() => mockController.start()).thenAnswer((_) async {});
    when(() => mockController.stop()).thenAnswer((_) async {});
    when(() => mockController.dispose()).thenAnswer((_) async {});
    when(() => mockController.updateScanWindow(any())).thenAnswer((_) async {});
    when(() => mockController.buildCameraView()).thenReturn(Container());
    when(() => mockController.autoStart).thenReturn(false);
    
    final fakeState = FakeMobileScannerState(
      isInitialized: true,
      size: const Size(640, 480),
      torchState: TorchState.off,
    );
    when(() => mockController.value).thenReturn(fakeState);
    when(() => mockController.addListener(any())).thenAnswer((_) {});
    when(() => mockController.removeListener(any())).thenAnswer((_) {});
  });

  Widget createTestApp() {
    return MaterialApp.router(
      routerConfig: createAppRouter(
        permissionService: mockPermissionService,
        mockController: mockController,
      ),
    );
  }

  group('Navigation', () {
    testWidgets('app launches on Scanner screen', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();
      expect(find.text('Scanner'), findsWidgets);
    });

    testWidgets('bottom nav has 3 tabs with correct labels',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();
      expect(find.text('Scanner'), findsWidgets);
      expect(find.text('Générateur'), findsOneWidget);
      expect(find.text('Historique'), findsOneWidget);
    });

    testWidgets('tapping Generator tab shows Generator screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Générateur'));
      await tester.pumpAndSettle();
      expect(find.text('Créez un QR code à partir de texte'), findsOneWidget);
    });

    testWidgets('tapping History tab shows History screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Historique'));
      await tester.pumpAndSettle();
      expect(find.text('Vos scans et générations récents'), findsOneWidget);
    });

    testWidgets('tapping Scanner tab returns to Scanner screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Générateur'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Scanner'));
      await tester.pumpAndSettle();
      expect(find.text('Placez le code QR dans la zone de visée'), findsOneWidget);
    });
  });
}
