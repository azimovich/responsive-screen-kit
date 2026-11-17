import "package:flutter/widgets.dart";

import "breakpoints.dart";
import "responsive_data.dart";
import "screen_metrics.dart";

/// What a dependent listens to. A widget that asks only for [screen] does not
/// rebuild when the device turns within the same class.
enum ResponsiveAspect { screen, orientation }

/// Wraps the app once and resolves the screen class for everything below it.
///
/// Put it **above** `MaterialApp`: Flutter's root `View` already provides a
/// `MediaQuery`, so routes, dialogs and overlays all see it.
///
/// It reads only `MediaQuery.sizeOf`, never the whole `MediaQueryData`, so
/// the keyboard and inset changes do not reach it; and since [child] is the
/// same instance between its builds, its own rebuild stops at the
/// `InheritedModel`, which notifies only dependents whose aspect changed.
class ResponsiveScope<T extends Object> extends StatelessWidget {
  const ResponsiveScope(
      {super.key, required this.breakpoints, required this.child})
      : _forcedScreen = null,
        _forcedOrientation = null;

  /// A fixed screen class, whatever the window: previews, golden and widget tests.
  const ResponsiveScope.forced({
    super.key,
    required this.breakpoints,
    required T screen,
    Orientation orientation = Orientation.portrait,
    required this.child,
  })  : _forcedScreen = screen,
        _forcedOrientation = orientation;

  final Breakpoints<T> breakpoints;
  final Widget child;
  final T? _forcedScreen;
  final Orientation? _forcedOrientation;

  /// The nearest scope of type [T]. Pass an [aspect] to depend on it alone;
  /// without one, the caller rebuilds on any change.
  static ResponsiveData<T> of<T extends Object>(BuildContext context,
      {ResponsiveAspect? aspect}) {
    final data = maybeOf<T>(context, aspect: aspect);
    if (data == null) {
      throw FlutterError.fromParts([
        ErrorSummary("No ResponsiveScope<$T> found."),
        ErrorHint(
          "Wrap the app once: runApp(screens.scope(child: MyApp())). "
          "The type argument must match the one used here.",
        ),
      ]);
    }
    return data;
  }

  static ResponsiveData<T>? maybeOf<T extends Object>(
    BuildContext context, {
    ResponsiveAspect? aspect,
  }) =>
      InheritedModel.inheritFrom<_ResponsiveModel<T>>(context, aspect: aspect)
          ?.data;

  @override
  Widget build(BuildContext context) {
    final forced = _forcedScreen;
    final ResponsiveData<T> data;

    if (forced != null) {
      data = ResponsiveData(
        screen: forced,
        orientation: _forcedOrientation!,
        breakpoints: breakpoints,
      );
    } else {
      final metrics = ScreenMetrics(MediaQuery.sizeOf(context));
      data = ResponsiveData(
        screen: breakpoints.resolve(metrics),
        orientation: metrics.orientation,
        breakpoints: breakpoints,
      );
    }

    return _ResponsiveModel<T>(data: data, child: child);
  }
}

class _ResponsiveModel<T extends Object>
    extends InheritedModel<ResponsiveAspect> {
  const _ResponsiveModel({required this.data, required super.child});

  final ResponsiveData<T> data;

  @override
  bool updateShouldNotify(_ResponsiveModel<T> oldWidget) =>
      oldWidget.data != data;

  @override
  bool updateShouldNotifyDependent(
    _ResponsiveModel<T> oldWidget,
    Set<ResponsiveAspect> dependencies,
  ) {
    final old = oldWidget.data;
    if (!identical(old.breakpoints, data.breakpoints)) return true;
    return (dependencies.contains(ResponsiveAspect.screen) &&
            old.screen != data.screen) ||
        (dependencies.contains(ResponsiveAspect.orientation) &&
            old.orientation != data.orientation);
  }
}
