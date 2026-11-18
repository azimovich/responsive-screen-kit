import "package:flutter/foundation.dart";

import "breakpoint.dart";
import "screen_metrics.dart";

/// The app's screen classes in **fallback order** — usually smallest first.
///
/// - **Resolve**: the *last* breakpoint that matches wins; the first one is
///   the base and is used when nothing else matches. When the order is not by
///   size, keep the rules exclusive (a `where` predicate).
/// - **Fallback**: a value missing for a screen class is taken from the one
///   declared before it — so a page only writes the classes where it differs.
///
/// Create it **once** (a top-level `final`), not in `build`: the scope
/// compares it by identity.
@immutable
class Breakpoints<T extends Object> {
  /// Creates the screen classes from [breakpoints], in fallback order.
  ///
  /// [breakpoints] must not be empty and must name each class once. The list
  /// is copied, so changing it later does not change these breakpoints.
  Breakpoints(List<Breakpoint<T>> breakpoints)
      : assert(breakpoints.isNotEmpty, "at least the base screen class"),
        assert(
          breakpoints.map((b) => b.id).toSet().length == breakpoints.length,
          "every screen class once",
        ),
        _list = List.unmodifiable(breakpoints),
        _rank = Map.unmodifiable({
          for (var i = 0; i < breakpoints.length; i++) breakpoints[i].id: i
        });

  final List<Breakpoint<T>> _list;
  final Map<T, int> _rank;

  /// In fallback order, as declared.
  List<T> get screens => [for (final b in _list) b.id];

  /// The class at [rank] in the declared order.
  T screenAt(int rank) => _list[rank].id;

  /// The first declared class: what every fallback ends at.
  T get base => _list.first.id;

  /// The screen class for [metrics]. O(n), n = a handful.
  T resolve(ScreenMetrics metrics) {
    for (var i = _list.length - 1; i > 0; i--) {
      if (_list[i].matches(metrics)) return _list[i].id;
    }
    return base;
  }

  /// Position in the declared order; a class falls back to lower ranks.
  int rankOf(T screen) {
    final rank = _rank[screen];
    if (rank == null) {
      throw ArgumentError.value(screen, "screen", "not in these breakpoints");
    }
    return rank;
  }

  @override
  String toString() => "Breakpoints<$T>(${screens.join(" < ")})";
}
