import 'package:flutter/widgets.dart';

abstract final class Breakpoints {
  static const double compact = 600; // < 600 : phone
  static const double medium = 1024; // 600-1024 : tablet / small window
  // > 1024 : desktop / wide web

  /// Readable max width for long-form content on wide screens.
  static const double contentMaxWidth = 720;
}

extension AdaptiveX on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  bool get isCompact => screenWidth < Breakpoints.compact;
  bool get isMedium =>
      screenWidth >= Breakpoints.compact && screenWidth < Breakpoints.medium;
  bool get isWide => screenWidth >= Breakpoints.medium;
}
