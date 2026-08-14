import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:screen_protector/screen_protector.dart';

/// Controls native screenshot and screen-recording protection for sensitive UI.
abstract final class ScreenCaptureProtection {
  static int _activeScopes = 0;
  static Future<void> _pendingOperation = Future<void>.value();

  static bool get _isSupportedPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static Future<void> acquire() {
    _activeScopes += 1;
    if (_activeScopes > 1) return Future<void>.value();
    return _enqueue(true);
  }

  static Future<void> release() {
    if (_activeScopes == 0) return Future<void>.value();
    _activeScopes -= 1;
    if (_activeScopes > 0) return Future<void>.value();
    return _enqueue(false);
  }

  static Future<void> _enqueue(bool enabled) {
    final operation = _pendingOperation.then((_) => _setEnabled(enabled));
    _pendingOperation = operation;
    return operation;
  }

  static Future<void> _setEnabled(bool enabled) async {
    if (!_isSupportedPlatform) return;

    try {
      if (enabled) {
        await ScreenProtector.preventScreenshotOn();
      } else {
        await ScreenProtector.preventScreenshotOff();
      }
    } on PlatformException catch (error) {
      debugPrint('Could not update screen capture protection: $error');
    } on MissingPluginException catch (error) {
      debugPrint('Screen capture protection is unavailable: $error');
    }
  }
}
