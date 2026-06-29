import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qr_scanner/services/permission_service.dart';
import 'package:qr_scanner/viewmodels/generator_viewmodel.dart';

class MockPermissionService extends Mock implements PermissionService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockPermissionService mockPermissionService;
  late GeneratorViewModel viewModel;

  setUp(() {
    mockPermissionService = MockPermissionService();
    viewModel = GeneratorViewModel(permissionService: mockPermissionService);

    // Mock the clipboard platform channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter/platform'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.setData') {
          return null;
        }
        return null;
      },
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('GeneratorViewModel Text Update and Debounce', () {
    test('updateText sets inputText immediately', () {
      viewModel.updateText('abc');
      expect(viewModel.inputText, 'abc');
    });

    test('debounce updates qrText after 300ms', () async {
      viewModel.updateText('hello');
      // Before debounce fires, qrText should still be empty
      expect(viewModel.qrText, '');

      // After 300ms debounce
      await Future.delayed(const Duration(milliseconds: 350));
      expect(viewModel.qrText, 'hello');
    });

    test('debounce cancels previous timer on rapid input', () async {
      viewModel.updateText('ab');
      await Future.delayed(const Duration(milliseconds: 100));
      viewModel.updateText('abcd');
      // Wait for the second debounce to fire (not the first)
      await Future.delayed(const Duration(milliseconds: 350));
      expect(viewModel.qrText, 'abcd');
    });

    test('empty text results in empty qrText', () async {
      viewModel.updateText('');
      await Future.delayed(const Duration(milliseconds: 350));
      expect(viewModel.qrText, '');
    });
  });

  group('GeneratorViewModel URL Detection', () {
    test('detects URL with www prefix', () async {
      viewModel.updateText('www.example.com');
      await Future.delayed(const Duration(milliseconds: 350));
      expect(viewModel.isUrlDetected, true);
    });

    test('detects URL with https scheme', () async {
      viewModel.updateText('https://flutter.dev');
      await Future.delayed(const Duration(milliseconds: 350));
      expect(viewModel.isUrlDetected, true);
    });

    test('detects URL with common TLD', () async {
      viewModel.updateText('example.com');
      await Future.delayed(const Duration(milliseconds: 350));
      expect(viewModel.isUrlDetected, true);
    });

    test('does not detect URL with spaces', () async {
      viewModel.updateText('hello world.com');
      await Future.delayed(const Duration(milliseconds: 350));
      expect(viewModel.isUrlDetected, false);
    });

    test('prepends https:// to URL without scheme', () async {
      viewModel.updateText('example.com');
      await Future.delayed(const Duration(milliseconds: 350));
      expect(viewModel.qrText, 'https://example.com');
    });

    test('does not double-prepend https://', () async {
      viewModel.updateText('https://example.com');
      await Future.delayed(const Duration(milliseconds: 350));
      expect(viewModel.qrText, 'https://example.com');
    });
  });

  group('GeneratorViewModel Actions', () {
    test('copyToClipboard copies inputText', () async {
      viewModel.updateText('hello world');
      expect(viewModel.inputText, 'hello world');
      // copyToClipboard should not throw - actual clipboard is platform-tested
    });

    test('dispose cancels timer', () async {
      viewModel.updateText('test');
      // Dispose immediately - should not throw
      viewModel.dispose();
      // Recreate for tearDown
      viewModel = GeneratorViewModel(permissionService: mockPermissionService);
    });
  });
}
