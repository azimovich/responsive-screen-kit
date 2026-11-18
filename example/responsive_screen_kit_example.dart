import "package:flutter/material.dart";
import "package:responsive_screen_kit/responsive_screen_kit.dart";

// =============================================================================
// A small shop app: one column on phones, two on tablets, four on desktops,
// three on a tablet held sideways.
//
// For custom rules (predicates, a foldable class), see:
// example/custom_breakpoints.dart
// =============================================================================

// --- 1. Your screen classes, smallest first ---
enum AppScreen { phone, tablet, desktop }

// --- 2. Your rules: created ONCE, as a top-level final ---
final screens = ResponsiveScreens<AppScreen>(const [
  Breakpoint(AppScreen.phone), // base: used when nothing else matches
  Breakpoint(AppScreen.tablet, minWidth: 600, minShortestSide: 600),
  Breakpoint(AppScreen.desktop, minWidth: 1200),
]);

// --- 3. Wrap the app once, above MaterialApp ---
void main() {
  runApp(screens.scope(child: const ShopApp()));
}

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: ShopPage());
  }
}

// --- 4. A page: say only what differs ---
class ShopPage extends StatelessWidget {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    // One value differs. desktop has no entry, so it takes tablet's 24.
    final gap = screens.value(context, {
      AppScreen.phone: 16.0,
      AppScreen.tablet: 24.0,
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Shop"),
        actions: [
          Center(child: Text(screens.of(context).name)),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(gap),
        // Whole bodies differ: only the builder for this class runs.
        child: screens.layout(
          builders: {
            AppScreen.phone: (_) => _ProductGrid(columns: 1, gap: gap),
            AppScreen.tablet: (_) => _ProductGrid(columns: 2, gap: gap),
            AppScreen.desktop: (_) => _ProductGrid(columns: 4, gap: gap),
          },
          // Held sideways, a tablet shows three columns.
          landscape: {
            AppScreen.tablet: (_) => _ProductGrid(columns: 3, gap: gap),
          },
        ),
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  const _ProductGrid({required this.columns, required this.gap});

  final int columns;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: columns,
      mainAxisSpacing: gap,
      crossAxisSpacing: gap,
      childAspectRatio: 1.4,
      children: [
        for (var i = 1; i <= 12; i++)
          Card(child: Center(child: Text("Product $i"))),
      ],
    );
  }
}
