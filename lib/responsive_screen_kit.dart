/// User-defined screen classes and breakpoints.
///
/// The app declares its own screen classes (an enum) and the rules that pick
/// one from the window size in a single [ResponsiveScreens] object, and wraps
/// itself once in its `scope`. Pages hand ready bodies to `screens.layout` or
/// pick values with `screens.value` — they never branch on sizes themselves.
library;

export "src/breakpoint.dart";
export "src/breakpoints.dart";
export "src/responsive_data.dart";
export "src/responsive_layout.dart";
export "src/responsive_scope.dart";
export "src/responsive_screens.dart";
export "src/screen_metrics.dart";
