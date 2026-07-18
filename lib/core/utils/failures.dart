/// Typed failures thrown by repositories and rendered by the UI.
sealed class AppFailure implements Exception {
  const AppFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message);
}

class AuthFailure extends AppFailure {
  const AuthFailure(super.message);
}

class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure(super.message);
}

/// Raised when an online-only action is attempted in local mode.
class OfflineFailure extends AppFailure {
  const OfflineFailure(super.message);
}
