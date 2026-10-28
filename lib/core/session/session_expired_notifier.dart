import 'dart:async';

/// Lets the network layer tell the app that the session is over
/// (token expired and could not be refreshed) without knowing about the UI.
class SessionExpiredNotifier {
  final _controller = StreamController<String>.broadcast();

  Stream<String> get stream => _controller.stream;

  void notify(String message) {
    if (!_controller.isClosed) _controller.add(message);
  }

  Future<void> dispose() => _controller.close();
}
