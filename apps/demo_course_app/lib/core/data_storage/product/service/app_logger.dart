class AppLogger {
  static void log(String message) {
    // ignore: avoid_print
    print("🟢 [LOG] $message");
  }

  static void error(String message, [dynamic e]) {
    // ignore: avoid_print
    print("🔴 [ERROR] $message -> $e");
  }
}