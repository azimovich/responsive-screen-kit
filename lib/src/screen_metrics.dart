import "package:flutter/widgets.dart";

/// What a breakpoint may look at: the window's logical size and what follows
/// from it. Built from the size alone, so the keyboard, system bars and
/// insets never cause a new resolution.
@immutable
class ScreenMetrics {
  /// Creates the metrics of a window of [size].
  const ScreenMetrics(this.size);

  /// The window, in logical pixels — not the device: a split-view window
  /// counts as its own size.
  final Size size;

  /// The window width, in logical pixels.
  double get width => size.width;

  /// The window height, in logical pixels.
  double get height => size.height;

  /// The shorter of [width] and [height].
  double get shortestSide => size.shortestSide;

  /// The longer of [width] and [height].
  double get longestSide => size.longestSide;

  /// Derived from the size, so no extra `MediaQuery` dependency is needed.
  Orientation get orientation =>
      width > height ? Orientation.landscape : Orientation.portrait;

  @override
  bool operator ==(Object other) =>
      other is ScreenMetrics && other.size == size;

  @override
  int get hashCode => size.hashCode;

  @override
  String toString() =>
      "ScreenMetrics(${width.toStringAsFixed(1)} × ${height.toStringAsFixed(1)})";
}
