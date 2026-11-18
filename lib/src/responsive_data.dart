import "package:flutter/widgets.dart";

import "breakpoints.dart";

/// What the scope resolved: the screen class and the orientation. Equal
/// snapshots never notify dependents, so a window resized within one class
/// rebuilds nothing below the scope.
@immutable
class ResponsiveData<T extends Object> {
  /// Creates a snapshot of [screen] and [orientation] under [breakpoints].
  const ResponsiveData({
    required this.screen,
    required this.orientation,
    required this.breakpoints,
  });

  /// The resolved screen class.
  final T screen;

  /// The window's orientation, derived from its size.
  final Orientation orientation;

  /// The rules [screen] was resolved with.
  final Breakpoints<T> breakpoints;

  /// Whether the window is wider than it is tall.
  bool get isLandscape => orientation == Orientation.landscape;

  /// `isAtLeast(AppScreen.tablet)` — this class or a larger one.
  bool isAtLeast(T other) =>
      breakpoints.rankOf(screen) >= breakpoints.rankOf(other);

  /// Whether [screen] comes before [other] in the declared order.
  bool isBelow(T other) => !isAtLeast(other);

  /// The value for this class, walking the fallback order. Held sideways, each
  /// step tries [landscape] before [values]: a class's own upright value beats
  /// an earlier class's sideways one, and an earlier class's sideways value
  /// beats its upright one.
  V? select<V>(Map<T, V> values, {Map<T, V> landscape = const {}}) {
    final sideways = isLandscape && landscape.isNotEmpty;
    for (var rank = breakpoints.rankOf(screen); rank >= 0; rank--) {
      final id = breakpoints.screenAt(rank);
      if (sideways && landscape.containsKey(id)) return landscape[id];
      if (values.containsKey(id)) return values[id];
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is ResponsiveData<T> &&
      other.screen == screen &&
      other.orientation == orientation &&
      identical(other.breakpoints, breakpoints);

  @override
  int get hashCode =>
      Object.hash(screen, orientation, identityHashCode(breakpoints));

  @override
  String toString() => "ResponsiveData($screen, ${orientation.name})";
}
