import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_scanner/services/permission_service.dart';
import 'package:qr_scanner/viewmodels/scanner_viewmodel.dart';

class MockPermissionService extends Mock implements PermissionService {}

void main() {
  late MockPermissionService mockPermissionService;
  late ScannerViewModel viewModel;

  setUp(() {
    mockPermissionService = MockPermissionService();
    viewModel = ScannerViewModel(permissionService: mockPermissionService);
  });

  group('ScannerViewModel Permissions', () {
    test('checkPermission sets hasPermission to true if granted', () async {
      when(() => mockPermissionService.hasCameraPermission()).thenAnswer((_) async => true);
      
      expect(viewModel.isCheckingPermission, true);
      
      final future = viewModel.checkPermission();
      expect(viewModel.isCheckingPermission, true); // Still checking synchronously before await returns
      
      await future;
      
      expect(viewModel.isCheckingPermission, false);
      expect(viewModel.hasPermission, true);
      verify(() => mockPermissionService.hasCameraPermission()).called(1);
    });

    test('checkPermission sets hasPermission to false if denied', () async {
      when(() => mockPermissionService.hasCameraPermission()).thenAnswer((_) async => false);
      
      await viewModel.checkPermission();
      
      expect(viewModel.isCheckingPermission, false);
      expect(viewModel.hasPermission, false);
    });

    test('requestPermission sets hasPermission to true if granted', () async {
      when(() => mockPermissionService.requestCameraPermission()).thenAnswer((_) async => true);
      
      await viewModel.requestPermission();
      
      expect(viewModel.isCheckingPermission, false);
      expect(viewModel.hasPermission, true);
      verify(() => mockPermissionService.requestCameraPermission()).called(1);
    });

    test('openSettings calls the service', () async {
      when(() => mockPermissionService.openSettings()).thenAnswer((_) async => true);
      
      await viewModel.openSettings();
      
      verify(() => mockPermissionService.openSettings()).called(1);
    });
  });

  group('ScannerViewModel QR Code Detection', () {
    testWidgets('handleQrCodeDetected handles empty codes and throttling', (tester) async {
      // Empty code
      bool accepted = await viewModel.handleQrCodeDetected('');
      expect(accepted, false);
      expect(viewModel.isScanningLocked, false);

      // Valid code
      accepted = await viewModel.handleQrCodeDetected('https://example.com');
      expect(accepted, true);
      expect(viewModel.isScanningLocked, true);

      // Another code within 2 seconds should be ignored
      accepted = await viewModel.handleQrCodeDetected('https://example.com/2');
      expect(accepted, false);
      expect(viewModel.isScanningLocked, true);

      // Fast forward 2 seconds (handled by tester.pump in testWidgets)
      await tester.pump(const Duration(seconds: 2));

      // Lock should be released
      expect(viewModel.isScanningLocked, false);

      // Should be able to scan again
      accepted = await viewModel.handleQrCodeDetected('https://example.com/3');
      expect(accepted, true);
      expect(viewModel.isScanningLocked, true);

      // Flush final timer
      await tester.pump(const Duration(seconds: 2));
    });
  });
}
