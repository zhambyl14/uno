import 'package:flutter/material.dart';

import '../constants/strings.dart';
import 'failures.dart';

/// Consistent, user-friendly feedback across the app.
extension UiFeedback on BuildContext {
  void showSnack(String message) {
    ScaffoldMessenger.of(this)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void showError(Object error) => showSnack(errorMessage(error));
}

String errorMessage(Object error) =>
    error is AppFailure ? error.message : S.unknownError;
