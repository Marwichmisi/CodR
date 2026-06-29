import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner/screens/scanner_screen.dart';
import 'package:qr_scanner/services/permission_service.dart';
import 'package:qr_scanner/viewmodels/scanner_viewmodel.dart';
import 'package:qr_scanner/viewmodels/result_viewmodel.dart';

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
        resultViewModel: ResultViewModel(),
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

  testWidgets('ScannerScreen toggles torch when FAB is tapped', (tester) async {
    when(() => mockPermissionService.hasCameraPermission()).thenAnswer((_) async => true);
    when(() => mockController.value).thenReturn(FakeMobileScannerState(
      isInitialized: true,
      torchState: TorchState.off,
    ));
    when(() => mockController.toggleTorch()).thenAnswer((_) async {});
    when(() => mockController.updateScanWindow(any())).thenAnswer((_) async {});
    when(() => mockController.buildCameraView()).thenReturn(Container());
    
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    
    final fab = find.byType(FloatingActionButton);
    expect(fab, findsOneWidget);
    
    await tester.tap(fab);
    verify(() => mockController.toggleTorch()).called(1);
  });

  testWidgets('ScannerScreen shows bottom sheet on text detection', (tester) async {
    when(() => mockPermissionService.hasCameraPermission()).thenAnswer((_) async => true);
    
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    
    final MobileScanner scanner = tester.widget(find.byType(MobileScanner));
    final capture = BarcodeCapture(
      barcodes: [Barcode(rawValue: 'Hello World')],
    );
    
    scanner.onDetect?.call(capture);
    await tester.pump(); // trigger frame for bottom sheet
    await tester.pumpAndSettle(); // wait for bottom sheet animation
    
    // Bottom sheet shows the content and Copy/Share buttons for text
    expect(find.text('Hello World'), findsOneWidget);
    expect(find.text('Copier le texte'), findsOneWidget);
    expect(find.text('Partager le contenu'), findsOneWidget);
    // No contextual button for plain text
    expect(find.text('Ouvrir le lien'), findsNothing);
    
    // Flush the debounce timer
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });

  testWidgets('ScannerScreen shows bottom sheet with URL action', (tester) async {
    when(() => mockPermissionService.hasCameraPermission()).thenAnswer((_) async => true);
    
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    
    final MobileScanner scanner = tester.widget(find.byType(MobileScanner));
    final capture = BarcodeCapture(
      barcodes: [Barcode(rawValue: 'https://flutter.dev')],
    );
    
    scanner.onDetect?.call(capture);
    await tester.pump(); // trigger frame for bottom sheet
    await tester.pumpAndSettle(); // wait for bottom sheet animation
    
    // Bottom sheet shows URL content and contextual "Open" button
    expect(find.text('https://flutter.dev'), findsOneWidget);
    expect(find.text('Ouvrir le lien'), findsOneWidget);
    expect(find.text('Copier le texte'), findsOneWidget);
    expect(find.text('Partager le contenu'), findsOneWidget);
    
    // Flush the debounce timer
    await tester.pumpAndSettle(const Duration(seconds: 2));
  });
}
