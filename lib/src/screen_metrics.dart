import "package:flutter/widgets.dart";

/// What a breakpoint may look at: the window's logical size and what follows
/// from it. Built from the size alone, so the keyboard, system bars and
/// insets never cause a new resolution.
@immutable
class ScreenMetrics {
  const ScreenMetrics(this.size);

  /// The window, in logical pixels — not the device: a split-view window
  /// counts as its own size.
  final Size size;

  double get width => size.width;
  double get height => size.height;
  double get shortestSide => size.shortestSide;
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
