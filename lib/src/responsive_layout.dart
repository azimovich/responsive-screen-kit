import "package:flutter/widgets.dart";

import "responsive_data.dart";
import "responsive_scope.dart";

/// Builds the body for the current screen class — only that one: the others
/// are builders and never run.
///
/// A class without a builder takes the one declared before it, so the base
/// builder is required. [landscape] holds bodies for a class held sideways;
/// each fallback step tries it first (see [ResponsiveData.select]).
///
/// Works as a box or as a sliver: it returns whatever the builder returns.
///
/// When the class changes, Flutter compares the new body with the old one by
/// widget type and key, as anywhere else: a body of another type (or key)
/// starts with fresh state, one of the same type keeps it. Give the bodies
/// different keys when they must not share state; keep state that must
/// survive any switch above this widget, or in a bloc.
class ResponsiveLayout<T extends Object> extends StatelessWidget {
  /// Creates a layout with one body builder per screen class.
  const ResponsiveLayout(
      {super.key, required this.builders, this.landscape = const {}});

  /// The body for each screen class; must include the base class.
  final Map<T, WidgetBuilder> builders;

  /// The body for a screen class held sideways, tried before [builders].
  final Map<T, WidgetBuilder> landscape;

  @override
  Widget build(BuildContext context) {
    // No landscape bodies → turning the device cannot change the result.
    final data = ResponsiveScope.of<T>(
      context,
      aspect: landscape.isEmpty ? ResponsiveAspect.screen : null,
    );
    assert(
      builders.containsKey(data.breakpoints.base),
      "ResponsiveLayout<$T> needs a builder for the base class ${data.breakpoints.base}",
    );

    final builder = data.select(builders, landscape: landscape);
    return builder!(context);
  }
}

/// The resolved data at hand, for a body that differs only in a detail.
/// Prefer [ResponsiveLayout] when whole bodies differ.
class ResponsiveBuilder<T extends Object> extends StatelessWidget {
  /// Creates a widget that hands the resolved data to [builder].
  const ResponsiveBuilder({super.key, required this.builder, this.aspect});

  /// Builds the widget from the resolved data.
  final Widget Function(BuildContext context, ResponsiveData<T> data) builder;

  /// Rebuild only on this aspect; `null` — on any.
  final ResponsiveAspect? aspect;

  @override
  Widget build(BuildContext context) =>
      builder(context, ResponsiveScope.of<T>(context, aspect: aspect));
}
