# responsive_screen_kit

User-defined screen classes and breakpoints for Flutter — one object, your own rules, a body per screen class.

[![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Why responsive_screen_kit

Responsive code usually starts with `MediaQuery.of(context).size.width > 600` and grows into three problems:

1. **Magic numbers everywhere.** Every page repeats its own `600`, `840`, `1200`. Change a breakpoint and you hunt for it in fifty files.
2. **Pages branch on sizes.** `if / else if / else` chains decide layouts inside `build()`. The design for a tablet is hidden in the middle of the phone's code.
3. **Too many rebuilds.** Reading the whole `MediaQuery` rebuilds a page when the keyboard opens or the window grows by one pixel — even when nothing about the layout changed.

Most packages fix the first one with a fixed set of sizes (`mobile`, `tablet`, `desktop`) that never quite fits your designs.

`responsive_screen_kit` gives you:

- **Your own screen classes.** An enum of yours — `phone`, `foldable`, `tablet`, `desktop`, as many as the design needs.
- **Your own rules, in one place.** Each class says when it applies: minimum width, height, shortest or longest side, or any predicate.
- **A body per class, not `if` chains.** `screens.layout` builds only the body for the current class. `screens.value` picks a value.
- **Fallback, so you write less.** A class without a body or value takes the one declared before it. Write only where the design differs.
- **Precise rebuilds.** Keyboard and insets rebuild nothing; a resize within a class rebuilds nothing below the scope; turning the device rebuilds only what depends on orientation.
- **The type written once.** One `ResponsiveScreens<AppScreen>` object — no `<AppScreen>` on every call, no wrong-type surprises at runtime.

## Features

- 🎯 User-defined screen classes — any enum, any number of classes
- 📏 Rules on width, height, shortest side, longest side, or a custom predicate
- 🧱 `screens.layout` — one builder per class, only the current one runs (box or sliver)
- 🎚️ `screens.value` — one value per class, with fallback
- 🔄 Optional landscape bodies and values
- ⚡ Rebuilds only on what a widget depends on (`InheritedModel` aspects)
- 🧪 `screens.forced` — a fixed class for widget tests, goldens and previews
- 📦 Depends on Flutter only

## Installation

```yaml
dependencies:
  responsive_screen_kit: ^1.0.0
```

## Quick start

```dart
import "package:responsive_screen_kit/responsive_screen_kit.dart";

// 1. Your screen classes.
enum AppScreen { phone, tablet, desktop }

// 2. Your rules — ONCE, as a top-level final.
final screens = ResponsiveScreens<AppScreen>(const [
  Breakpoint(AppScreen.phone), // base
  Breakpoint(AppScreen.tablet, minWidth: 600),
  Breakpoint(AppScreen.desktop, minWidth: 1200),
]);

// 3. Wrap the app once, above MaterialApp.
void main() => runApp(screens.scope(child: const App()));

// 4. Draw a body per class.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return screens.layout(
      builders: {
        AppScreen.phone: (_) => const OneColumn(),
        AppScreen.tablet: (_) => const TwoColumns(), // desktop falls back here
      },
    );
  }
}
```

## Before / After

**Before** — sizes and branches inside every page:

```dart
@override
Widget build(BuildContext context) {
  final width = MediaQuery.of(context).size.width; // rebuilds on keyboard too
  final padding = width >= 600 ? 24.0 : 16.0;

  if (width >= 1200) {
    return Padding(padding: EdgeInsets.all(padding), child: const ThreeColumns());
  } else if (width >= 600) {
    return Padding(padding: EdgeInsets.all(padding), child: const TwoColumns());
  }
  return Padding(padding: EdgeInsets.all(padding), child: const OneColumn());
}
```

**After** — the rules live in one place, the page only says what differs:

```dart
@override
Widget build(BuildContext context) {
  final padding = screens.value(context, {
    AppScreen.phone: 16.0,
    AppScreen.tablet: 24.0, // desktop falls back to 24
  });

  return Padding(
    padding: EdgeInsets.all(padding),
    child: screens.layout(
      builders: {
        AppScreen.phone: (_) => const OneColumn(),
        AppScreen.tablet: (_) => const TwoColumns(),
        AppScreen.desktop: (_) => const ThreeColumns(),
      },
    ),
  );
}
```

## Defining breakpoints

Classes are listed in **fallback order**, usually smallest first:

- **Resolve:** the *last* class whose rule matches wins. The first class is the base and is used when nothing else matches.
- **Fallback:** a class without a body or value takes the one declared before it.

Every minimum given must hold (they are combined with AND):

| Parameter | Matches when | Use it for |
|---|---|---|
| `minWidth` | window width ≥ value | the classic breakpoint |
| `minHeight` | window height ≥ value | short windows, landscape phones |
| `minShortestSide` | shorter side ≥ value | "what device is this" — does not change when the device turns |
| `minLongestSide` | longer side ≥ value | large screens in any orientation |
| `where` | your predicate returns `true` | anything the minimums cannot say |

```dart
enum AppScreen { phone, foldable, tablet, desktop }

final screens = ResponsiveScreens<AppScreen>(const [
  Breakpoint(AppScreen.phone),
  Breakpoint(AppScreen.foldable, minWidth: 600),
  // A tablet stays a tablet when turned: its shortest side is large.
  Breakpoint(AppScreen.tablet, minWidth: 600, minShortestSide: 700),
  Breakpoint(AppScreen.desktop, minWidth: 1200, where: _isWide),
]);

// Pass a top-level or static function so the list can stay const.
bool _isWide(ScreenMetrics m) => m.width / m.height > 1.3;
```

> Sizes are the **window**, in logical pixels — not the device. An app in split view on a tablet resolves to what its own window is.

## Building pages

| Member | Use it when |
|---|---|
| `screens.layout(builders: {...})` | whole bodies differ — only the current builder runs; works as a box or a sliver |
| `screens.value(context, {...})` | one value differs — padding, column count, font size |
| `screens.of(context)` | you need the class itself |
| `screens.builder((context, data) => ...)` | a detail inside a body differs; `data.isAtLeast(...)`, `data.isLandscape` |
| `screens.dataOf(context)` | the whole snapshot: class, orientation, `isAtLeast`, `isBelow` |

```dart
// The class itself.
if (screens.of(context) == AppScreen.desktop) const SideMenu(),

// A detail.
screens.builder(
  (context, data) => data.isAtLeast(AppScreen.tablet) ? const Hint() : const SizedBox.shrink(),
)
```

`screens.layout` and `screens.value` require an entry for the **base** class — otherwise the fallback would have nothing to end at. Debug builds assert on it.

## Landscape

Both `layout` and `value` take an optional `landscape` map. Held sideways, each fallback step tries the landscape entry first, then the upright one:

```dart
screens.layout(
  builders: {
    AppScreen.phone: (_) => const OneColumn(),
    AppScreen.tablet: (_) => const TwoColumns(),
  },
  landscape: {
    AppScreen.tablet: (_) => const ThreeColumns(), // tablet and desktop, held sideways
  },
)
```

Without a `landscape` map, turning the device does not rebuild the widget at all.

## Rebuilds

| Change | What rebuilds |
|---|---|
| Keyboard, system bars, insets | nothing — the scope reads `MediaQuery.sizeOf` only |
| Window resized within one class | nothing below the scope |
| Device turned, same class | orientation dependents only — `of`, and `layout` / `value` without `landscape`, do not |
| Class changed | dependents of the screen class |

When the class changes, Flutter matches the new body with the old one by widget type and key, as anywhere else: a body of another type starts with fresh state, one of the same type keeps it. Give the bodies different keys when they must not share state.

## Create it once

`ResponsiveScreens` must be created **once** — a top-level `final`, not inside `build()`. The scope compares its rules by identity, so a second instance (even with the same rules) is a new configuration and rebuilds everything below it. In debug mode `of`, `dataOf` and `value` assert that the scope above them is their own.

Changing the rules needs a hot **restart** — hot reload does not re-run top-level initializers.

## Testing

Fix the class, whatever the test window is:

```dart
testWidgets("tablet shows two columns", (tester) async {
  await tester.pumpWidget(
    screens.forced(
      screen: AppScreen.tablet,
      orientation: Orientation.landscape, // optional, portrait by default
      child: const MaterialApp(home: HomePage()),
    ),
  );

  expect(find.byType(TwoColumns), findsOneWidget);
});
```

Or set the test window size and use the real scope:

```dart
tester.view
  ..devicePixelRatio = 1
  ..physicalSize = const Size(820, 1180);
addTearDown(tester.view.reset);
```

## Building blocks

`ResponsiveScreens` adds no logic — it hands over to public classes you can use directly:

| Class | Responsibility |
|---|---|
| `Breakpoint<T>` | one screen class and its rule |
| `Breakpoints<T>` | the classes in fallback order; `resolve`, `rankOf`, `base` |
| `ScreenMetrics` | what a rule may look at: width, height, shortest/longest side, orientation |
| `ResponsiveScope<T>` | resolves the class and publishes it; `ResponsiveScope.forced` |
| `ResponsiveData<T>` | the snapshot: `screen`, `orientation`, `select` (the fallback walk) |
| `ResponsiveLayout<T>` | builds only the current body |
| `ResponsiveBuilder<T>` | hands the snapshot to a builder |
| `ResponsiveAspect` | `screen` or `orientation` — what a widget rebuilds on |

## Visual guide

[`docs/how-it-works.html`](docs/how-it-works.html) — diagrams of the flows and a playground that draws a real-size device for any window size. Open it in a browser after cloning the repository.

## License

MIT — see [LICENSE](LICENSE).
