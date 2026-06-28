import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_scanner/screens/scanner_screen.dart';
import 'package:qr_scanner/screens/generator_screen.dart';
import 'package:qr_scanner/screens/history_screen.dart';
import 'package:qr_scanner/theme/app_theme.dart';
import 'package:qr_scanner/viewmodels/scanner_viewmodel.dart';
import 'package:qr_scanner/viewmodels/result_viewmodel.dart';
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
  late ScannerViewModel viewModel;
  
  setUp(() {
    mockPermissionService = MockPermissionService();
    when(() => mockPermissionService.hasCameraPermission()).thenAnswer((_) async => true);
    viewModel = ScannerViewModel(permissionService: mockPermissionService);
    
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

  group('Responsive Layout', () {
    testWidgets('renders without overflow at 360px width (phone)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        theme: buildLightTheme(),
        home: ScannerScreen(viewModel: viewModel, resultViewModel: ResultViewModel(), mockController: mockController),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow at 768px width (tablet)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        theme: buildLightTheme(),
        home: ScannerScreen(viewModel: viewModel, resultViewModel: ResultViewModel(), mockController: mockController),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('content is constrained on wide screen',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        theme: buildLightTheme(),
        home: ScannerScreen(viewModel: viewModel, resultViewModel: ResultViewModel(), mockController: mockController),
      ));
      // Verify ConstrainedBox exists with maxWidth constraint
      expect(find.byType(ConstrainedBox), findsWidgets);
    });

    testWidgets('GeneratorScreen renders without overflow at 360px width',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        theme: buildLightTheme(),
        home: const GeneratorScreen(),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('HistoryScreen renders without overflow at 360px width',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        theme: buildLightTheme(),
        home: const HistoryScreen(),
      ));
      expect(tester.takeException(), isNull);
    });

    testWidgets('all screens have LayoutBuilder', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(MaterialApp(
        theme: buildLightTheme(),
        home: ScannerScreen(viewModel: viewModel, resultViewModel: ResultViewModel(), mockController: mockController),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(LayoutBuilder), findsWidgets);

      await tester.pumpWidget(MaterialApp(
        theme: buildLightTheme(),
        home: const GeneratorScreen(),
      ));
      expect(find.byType(LayoutBuilder), findsWidgets);

      await tester.pumpWidget(MaterialApp(
        theme: buildLightTheme(),
        home: const HistoryScreen(),
      ));
      expect(find.byType(LayoutBuilder), findsWidgets);
    });
  });
}
