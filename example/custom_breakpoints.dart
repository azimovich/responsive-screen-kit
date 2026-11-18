import "package:flutter/material.dart";
import "package:responsive_screen_kit/responsive_screen_kit.dart";

// =============================================================================
// Custom rules: a foldable class, a predicate, and the building blocks.
//
// For a full app, see: example/responsive_screen_kit_example.dart
// =============================================================================

enum AppScreen { phone, foldable, tablet, desktop }

// --- Rules on more than width ---
//
// - foldable: wide enough for two panes, but its shortest side is short.
// - tablet:   shortestSide does not change when the device turns,
//             so a tablet stays a tablet in landscape.
// - desktop:  a predicate — anything the minimums cannot say.
final screens = ResponsiveScreens<AppScreen>(const [
  Breakpoint(AppScreen.phone),
  Breakpoint(AppScreen.foldable, minWidth: 600),
  Breakpoint(AppScreen.tablet, minWidth: 600, minShortestSide: 700),
  Breakpoint(AppScreen.desktop, minWidth: 1200, where: _isWide),
]);

// A top-level (or static) function keeps the breakpoint list const.
bool _isWide(ScreenMetrics metrics) => metrics.width / metrics.height > 1.3;

void main() {
  runApp(screens.scope(child: const MaterialApp(home: InfoPage())));
}

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Custom breakpoints")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- The whole snapshot, for details inside a body ---
          screens.builder(
            (context, data) => ListTile(
              title: Text("Screen class: ${data.screen.name}"),
              subtitle: Text("Orientation: ${data.orientation.name}"),
            ),
          ),

          // --- Compare classes by their declared order ---
          screens.builder(
            (context, data) => ListTile(
              title: const Text("Two panes?"),
              subtitle: Text(
                data.isAtLeast(AppScreen.foldable) ? "yes" : "no, one pane",
              ),
            ),
          ),

          // --- A value that also differs when held sideways ---
          ListTile(
            title: const Text("Columns"),
            subtitle: Text(
              "${screens.value(
                context,
                {AppScreen.phone: 1, AppScreen.foldable: 2},
                landscape: {AppScreen.phone: 2, AppScreen.tablet: 3},
              )}",
            ),
          ),

          // --- The rules themselves ---
          ListTile(
            title: const Text("Declared order"),
            subtitle: Text(screens.breakpoints.toString()),
          ),
        ],
      ),
    );
  }
}

// --- Tests and previews: a fixed class, whatever the window ---
//
// screens.forced(
//   screen: AppScreen.tablet,
//   orientation: Orientation.landscape,
//   child: const MaterialApp(home: InfoPage()),
// );
