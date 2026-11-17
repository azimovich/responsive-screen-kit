import "package:flutter/material.dart";
import "package:responsive_screen_kit/responsive_screen_kit.dart";

/// The app's own screen classes, smallest first.
enum AppScreen { phone, tablet, desktop }

/// Created once: the scope compares its breakpoints by identity.
final screens = ResponsiveScreens<AppScreen>(const [
  Breakpoint(AppScreen.phone), // base
  Breakpoint(AppScreen.tablet, minWidth: 600, minShortestSide: 600),
  Breakpoint(AppScreen.desktop, minWidth: 1200),
]);

void main() {
  runApp(screens.scope(child: const ExampleApp()));
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // One value differs: desktop takes the tablet's 24 by fallback.
    final gutter = screens.value(context, {
      AppScreen.phone: 16.0,
      AppScreen.tablet: 24.0,
    });

    return Scaffold(
      appBar: AppBar(title: Text("Screen: ${screens.of(context).name}")),
      body: Padding(
        padding: EdgeInsets.all(gutter),
        // Whole bodies differ: only the builder for this class runs.
        child: screens.layout(
          builders: {
            AppScreen.phone: (_) => const _Grid(columns: 1),
            AppScreen.tablet: (_) => const _Grid(columns: 2),
            AppScreen.desktop: (_) => const _Grid(columns: 4),
          },
          landscape: {AppScreen.tablet: (_) => const _Grid(columns: 3)},
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.columns});

  final int columns;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: columns,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        for (var i = 1; i <= 12; i++)
          Card(child: Center(child: Text("Item $i"))),
      ],
    );
  }
}
