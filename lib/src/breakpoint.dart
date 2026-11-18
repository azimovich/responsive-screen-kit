import "package:flutter/foundation.dart";

import "screen_metrics.dart";

/// A custom rule a [Breakpoint] adds on top of its minimums. Pass a top-level
/// or static function so the breakpoint can stay `const`.
typedef ScreenPredicate = bool Function(ScreenMetrics metrics);

/// One screen class of the app and when it applies.
///
/// Every given minimum must hold, and [where] too when set. A breakpoint with
/// no minimums always matches — the natural base.
///
/// ```dart
/// const Breakpoint(AppScreen.tablet, minWidth: 600, minShortestSide: 700)
/// ```
@immutable
class Breakpoint<T extends Object> {
  /// Creates the rule for the screen class [id].
  ///
  /// Every minimum defaults to `0` (no limit) and must not be negative.
  const Breakpoint(
    this.id, {
    this.minWidth = 0,
    this.minHeight = 0,
    this.minShortestSide = 0,
    this.minLongestSide = 0,
    this.where,
  }) : assert(minWidth >= 0 &&
            minHeight >= 0 &&
            minShortestSide >= 0 &&
            minLongestSide >= 0);

  /// The app's own screen class, usually an enum value.
  final T id;

  /// The smallest window width, in logical pixels, this class applies to.
  final double minWidth;

  /// The smallest window height, in logical pixels, this class applies to.
  final double minHeight;

  /// The smallest value of the window's shorter side.
  ///
  /// Does not change when the device turns — use it for "what device is this".
  final double minShortestSide;

  /// The smallest value of the window's longer side.
  final double minLongestSide;

  /// Anything the minimums cannot say (an aspect ratio, say).
  final ScreenPredicate? where;

  /// Whether [metrics] meets every minimum and, when set, [where].
  bool matches(ScreenMetrics metrics) =>
      metrics.width >= minWidth &&
      metrics.height >= minHeight &&
      metrics.shortestSide >= minShortestSide &&
      metrics.longestSide >= minLongestSide &&
      (where?.call(metrics) ?? true);

  @override
  String toString() =>
      "Breakpoint($id, minWidth: $minWidth, minHeight: $minHeight, "
      "minShortestSide: $minShortestSide, minLongestSide: $minLongestSide)";
}
