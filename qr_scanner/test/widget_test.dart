import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner/navigation/app_router.dart';
import 'package:qr_scanner/services/permission_service.dart';

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
    this.size = const Size(1080, 1920),
  });

  @override
  final DeviceOrientation deviceOrientation = DeviceOrientation.portraitUp;
}

class FakeMobileScannerValueNotifier extends Fake implements ValueNotifier<MobileScannerState> {
  @override
  MobileScannerState get value => FakeMobileScannerState();

  @override
  void addListener(VoidCallback listener) {}
  
  @override
  void removeListener(VoidCallback listener) {}
}

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    final mockPermissionService = MockPermissionService();
    when(() => mockPermissionService.hasCameraPermission()).thenAnswer((_) async => true);
    
    final mockController = MockMobileScannerController();
    when(() => mockController.start()).thenAnswer((_) async {});
    when(() => mockController.stop()).thenAnswer((_) async {});
    when(() => mockController.dispose()).thenAnswer((_) async {});
    when(() => mockController.updateScanWindow(any())).thenAnswer((_) async {});
    when(() => mockController.buildCameraView()).thenReturn(Container());
    when(() => mockController.autoStart).thenReturn(true);
    when(() => mockController.value).thenReturn(FakeMobileScannerValueNotifier().value);
    
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: createAppRouter(
        permissionService: mockPermissionService,
        mockController: mockController,
      ),
    ));
    await tester.pumpAndSettle();
    
    expect(find.text('Scanner'), findsWidgets);
  });
}
