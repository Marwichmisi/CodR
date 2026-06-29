import 'package:flutter_test/flutter_test.dart';
import 'package:qr_scanner/models/content_type.dart';
import 'package:qr_scanner/viewmodels/result_viewmodel.dart';

void main() {
  late ResultViewModel viewModel;

  setUp(() {
    viewModel = ResultViewModel();
  });

  group('ResultViewModel Content Detection', () {
    test('detectContentType identifies URLs (https)', () {
      viewModel.detectContentType('https://flutter.dev');
      expect(viewModel.contentType, ContentType.url);
      expect(viewModel.hasError, false);
    });

    test('detectContentType identifies URLs (http)', () {
      viewModel.detectContentType('http://example.com');
      expect(viewModel.contentType, ContentType.url);
      expect(viewModel.hasError, false);
    });

    test('detectContentType identifies emails', () {
      viewModel.detectContentType('user@example.com');
      expect(viewModel.contentType, ContentType.email);
      expect(viewModel.hasError, false);
    });

    test('detectContentType identifies phones (international)', () {
      viewModel.detectContentType('+33612345678');
      expect(viewModel.contentType, ContentType.phone);
      expect(viewModel.hasError, false);
    });

    test('detectContentType identifies phones (national)', () {
      viewModel.detectContentType('0612345678');
      expect(viewModel.contentType, ContentType.phone);
      expect(viewModel.hasError, false);
    });

    test('detectContentType identifies plain text', () {
      viewModel.detectContentType('Hello World');
      expect(viewModel.contentType, ContentType.text);
      expect(viewModel.hasError, false);
    });

    test('detectContentType handles empty content as error', () {
      viewModel.detectContentType('');
      expect(viewModel.contentType, ContentType.empty);
      expect(viewModel.hasError, true);
    });

    test('detectContentType handles whitespace-only as invalid (D-15)', () {
      viewModel.detectContentType('   ');
      expect(viewModel.contentType, ContentType.empty);
      expect(viewModel.hasError, true);
    });

    test('detectContentType treats mixed text as text (D-08)', () {
      viewModel.detectContentType('Mon site: https://flutter.dev');
      expect(viewModel.contentType, ContentType.text);
      expect(viewModel.hasError, false);
    });

    test('detectContentType rejects non-http schemes (D-05)', () {
      viewModel.detectContentType('javascript:alert(1)');
      expect(viewModel.contentType, ContentType.text);
    });

    test('detectContentType rejects file:// scheme', () {
      viewModel.detectContentType('file:///etc/passwd');
      expect(viewModel.contentType, ContentType.text);
    });

    test('detectContentType priority URL > email > phone (D-08)', () {
      // Pure URL gets url type
      viewModel.detectContentType('https://example.com');
      expect(viewModel.contentType, ContentType.url);

      // Mixed text gets text type (not URL)
      viewModel.detectContentType('Contact: user@example.com');
      expect(viewModel.contentType, ContentType.text);
    });

    test('detectContentType uses strict priority for pure matches', () {
      // Pure email
      viewModel.detectContentType('test@domain.com');
      expect(viewModel.contentType, ContentType.email);

      // Pure phone
      viewModel.detectContentType('+1234567890');
      expect(viewModel.contentType, ContentType.phone);
    });
  });

  group('ResultViewModel State', () {
    test('initial state is text with no error', () {
      expect(viewModel.contentType, ContentType.text);
      expect(viewModel.hasError, false);
      expect(viewModel.scannedContent, '');
    });

    test('detectContentType stores scanned content', () {
      viewModel.detectContentType('Hello World');
      expect(viewModel.scannedContent, 'Hello World');
    });

    test('notifyListeners is called on detectContentType', () {
      var notified = false;
      viewModel.addListener(() {
        notified = true;
      });
      viewModel.detectContentType('test');
      expect(notified, true);
    });
  });

  group('ResultViewModel Actions', () {
    test('copyToClipboard stores content', () async {
      // Clipboard requires platform channel, just verify method exists and is callable
      expect(() => viewModel.copyToClipboard('test content'), returnsNormally);
    });

    test('shareContent is callable', () async {
      // SharePlus requires platform channel, just verify method exists
      expect(() => viewModel.shareContent('test content'), returnsNormally);
    });

    test('openUrl is callable', () async {
      expect(() => viewModel.openUrl('https://flutter.dev'), returnsNormally);
    });

    test('sendEmail is callable', () async {
      expect(() => viewModel.sendEmail('test@example.com'), returnsNormally);
    });

    test('callPhone is callable', () async {
      expect(() => viewModel.callPhone('+33612345678'), returnsNormally);
    });
  });

  group('Edge Cases (Backstops)', () {
    test('R6: shareContent with empty content does not crash', () async {
      // Backstop R6: Share button disabled if empty/error — no crash on empty
      expect(() => viewModel.shareContent(''), returnsNormally);
    });

    test('R7: detectContentType called multiple times consecutively does not crash', () {
      // Backstop R7: Repeated retry does not crash
      for (var i = 0; i < 10; i++) {
        viewModel.detectContentType('https://example.com/$i');
      }
      expect(viewModel.contentType, ContentType.url);
      expect(viewModel.hasError, false);
    });

    test('R9: detectContentType with empty string does not throw exception', () {
      // Backstop R9: ViewModel handles null/empty without exception
      expect(() => viewModel.detectContentType(''), returnsNormally);
      expect(viewModel.contentType, ContentType.empty);
      expect(viewModel.hasError, true);
    });

    test('R9: detectContentType does not throw on any input', () {
      // Verify no exception on various edge cases
      expect(() => viewModel.detectContentType(''), returnsNormally);
      expect(() => viewModel.detectContentType('   '), returnsNormally);
      expect(() => viewModel.detectContentType('\n\t'), returnsNormally);
      expect(() => viewModel.dispose(), returnsNormally);
    });
  });

  group('Additional Content Detection', () {
    test('detectContentType rejects data: scheme (D-05)', () {
      viewModel.detectContentType('data:text/html,<h1>Hello</h1>');
      expect(viewModel.contentType, ContentType.text);
    });

    test('detectContentType mixed email treated as text (D-08)', () {
      viewModel.detectContentType('Contact: user@example.com');
      expect(viewModel.contentType, ContentType.text);
    });

    test('detectContentType mixed phone treated as text (D-08)', () {
      viewModel.detectContentType('Appelez le +33612345678');
      expect(viewModel.contentType, ContentType.text);
    });

    test('hasError resets to false after valid content', () {
      viewModel.detectContentType('');
      expect(viewModel.hasError, true);

      viewModel.detectContentType('https://flutter.dev');
      expect(viewModel.hasError, false);
      expect(viewModel.contentType, ContentType.url);
    });

    test('scannedContent stores raw content before trim', () {
      viewModel.detectContentType('  https://flutter.dev  ');
      expect(viewModel.scannedContent, '  https://flutter.dev  ');
      expect(viewModel.contentType, ContentType.url);
    });
  });
}
