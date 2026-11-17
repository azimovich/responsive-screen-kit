import "package:flutter/widgets.dart";

import "breakpoint.dart";
import "breakpoints.dart";
import "responsive_data.dart";
import "responsive_layout.dart";
import "responsive_scope.dart";

/// The one object an app talks to: its screen classes and everything built
/// on them, with the type argument written once.
///
/// Create it **once**, as a top-level `final` — the scope compares its
/// [breakpoints] by identity, so a second instance is a new configuration.
///
/// ```dart
/// enum AppScreen { phone, tablet }
///
/// final screens = ResponsiveScreens<AppScreen>(const [
///   Breakpoint(AppScreen.phone),
///   Breakpoint(AppScreen.tablet, minWidth: 600),
/// ]);
///
/// void main() => runApp(screens.scope(child: const App()));
/// ```
///
/// It adds no logic of its own: every member hands over to [Breakpoints],
/// [ResponsiveScope], [ResponsiveLayout] or [ResponsiveBuilder], which stay
/// public for anyone who needs them directly.
@immutable
class ResponsiveScreens<T extends Object> {
  ResponsiveScreens(List<Breakpoint<T>> breakpoints)
      : breakpoints = Breakpoints<T>(breakpoints);

  /// The rules, in fallback order.
  final Breakpoints<T> breakpoints;

  /// Wraps the app once — put it above `MaterialApp`.
  ResponsiveScope<T> scope({Key? key, required Widget child}) =>
      ResponsiveScope<T>(key: key, breakpoints: breakpoints, child: child);

  /// A fixed screen class, whatever the window: previews, golden and widget
  /// tests.
  ResponsiveScope<T> forced({
    Key? key,
    required T screen,
    Orientation orientation = Orientation.portrait,
    required Widget child,
  }) =>
      ResponsiveScope<T>.forced(
        key: key,
        breakpoints: breakpoints,
        screen: screen,
        orientation: orientation,
        child: child,
      );

  /// One body per screen class; only the current one is built. A class
  /// without a builder takes the one declared before it, so the base builder
  /// is required. See [ResponsiveLayout].
  ResponsiveLayout<T> layout({
    Key? key,
    required Map<T, WidgetBuilder> builders,
    Map<T, WidgetBuilder> landscape = const {},
  }) =>
      ResponsiveLayout<T>(key: key, builders: builders, landscape: landscape);

  /// The resolved data at hand, for a body that differs only in a detail.
  /// See [ResponsiveBuilder].
  ResponsiveBuilder<T> builder(
    Widget Function(BuildContext context, ResponsiveData<T> data) builder, {
    Key? key,
    ResponsiveAspect? aspect,
  }) =>
      ResponsiveBuilder<T>(key: key, builder: builder, aspect: aspect);

  /// The current screen class. Turning the device does not rebuild the
  /// caller.
  T of(BuildContext context) =>
      dataOf(context, aspect: ResponsiveAspect.screen).screen;

  /// The whole snapshot. Pass an [aspect] to rebuild on it alone; without
  /// one, the caller rebuilds on any change.
  ResponsiveData<T> dataOf(BuildContext context, {ResponsiveAspect? aspect}) {
    final data = ResponsiveScope.of<T>(context, aspect: aspect);
    assert(
      identical(data.breakpoints, breakpoints),
      "This ResponsiveScreens<$T> is not the one the nearest scope uses — "
      "create it once and wrap the app with its scope().",
    );
    return data;
  }

  /// The value for this screen class, else for the one declared before it;
  /// held sideways, each step tries [landscape] first. [values] must have an
  /// entry for the base class. Depends on the orientation only when
  /// [landscape] is given.
  V value<V>(
    BuildContext context,
    Map<T, V> values, {
    Map<T, V> landscape = const {},
  }) {
    final data = dataOf(
      context,
      aspect: landscape.isEmpty ? ResponsiveAspect.screen : null,
    );
    assert(
      values.containsKey(breakpoints.base),
      "value() needs an entry for the base class ${breakpoints.base}",
    );
    return data.select(values, landscape: landscape) as V;
  }

  @override
  String toString() =>
      "ResponsiveScreens<$T>(${breakpoints.screens.join(" < ")})";
}
