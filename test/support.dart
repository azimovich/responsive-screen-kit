import "package:responsive_screen_kit/responsive_screen_kit.dart";
import "package:flutter/widgets.dart";
import "package:flutter_test/flutter_test.dart";

/// The screen classes the tests use — four, to show the package has no fixed set.
enum Screen { phone, foldable, tabletMini, tabletBig }

const rules = [
  Breakpoint(Screen.phone),
  Breakpoint(Screen.foldable, minWidth: 600),
  Breakpoint(Screen.tabletMini, minWidth: 600, minShortestSide: 700),
  Breakpoint(Screen.tabletBig, minWidth: 600, minShortestSide: 1000),
];

final screens = ResponsiveScreens<Screen>(rules);

final breakpoints = screens.breakpoints;

const phone = Size(390, 844);
const foldable = Size(669, 951);
const iPad = Size(820, 1180);
const iPadSideways = Size(1180, 820);
const iPadPro = Size(1024, 1366);
const iPadProSideways = Size(1366, 1024);

/// Gives the test view [size] in logical pixels until the test ends.
void useSize(WidgetTester tester, Size size) {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = size;
  addTearDown(tester.view.reset);
}

/// Changes the window as a running app sees it: the same widget tree, a new size.
Future<void> resize(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  await tester.pump();
}

/// [child] under the scope, with text direction for widgets that need it.
Widget scoped(Widget child, {Breakpoints<Screen>? using}) =>
    ResponsiveScope<Screen>(
      breakpoints: using ?? breakpoints,
      child: Directionality(textDirection: TextDirection.ltr, child: child),
    );

/// Counts its builds and reports what it read.
class Probe extends StatelessWidget {
  const Probe({super.key, required this.read, required this.onBuild});

  final Object? Function(BuildContext context) read;
  final void Function(Object? value) onBuild;

  @override
  Widget build(BuildContext context) {
    onBuild(read(context));
    return const SizedBox();
  }
}
