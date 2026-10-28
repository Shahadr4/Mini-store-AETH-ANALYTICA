import 'package:flutter/foundation.dart';

/// A ChangeNotifier that ignores notifyListeners() after it was disposed.
///
/// A network response can arrive after the screen was closed. Without this
/// check, notifyListeners() would throw in that case.
class SafeChangeNotifier extends ChangeNotifier {
  bool _disposed = false;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
