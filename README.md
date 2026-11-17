# responsive_screen_kit

User-defined screen classes and breakpoints for Flutter. Depends only on Flutter: no fixed sizes,
no fixed set of layouts, nothing of any app.

- **Your classes** — an enum of your own (`phone`, `tablet`, `desktop`, …), as many as you need.
- **Your breakpoints** — each class says when it applies: a minimum width, height, shortest or
  longest side, or a predicate. The last match wins; the first class is the base.
- **One object** — `ResponsiveScreens<T>` holds the rules and gives you everything else. The type
  is written once.
- **No branching in pages** — `screens.layout` builds the body for the class, `screens.value`
  picks a value. A class without one takes the one declared before it, so you write only the
  classes where the design differs.

## Install

```yaml
dependencies:
  responsive_screen_kit: ^1.0.0
```

Requires Dart 3.0 / Flutter 3.10 or newer.

## Setup — once per app

```dart
import "package:responsive_screen_kit/responsive_screen_kit.dart";

enum AppScreen { phone, foldable, tablet, desktop }

// Create it ONCE, as a top-level final — not in build().
final screens = ResponsiveScreens<AppScreen>(const [
  Breakpoint(AppScreen.phone),                                     // base
  Breakpoint(AppScreen.foldable, minWidth: 600),
  Breakpoint(AppScreen.tablet, minWidth: 600, minShortestSide: 700),
  Breakpoint(AppScreen.desktop, minWidth: 1200),
]);

void main() {
  runApp(screens.scope(child: const App())); // above MaterialApp
}
```

The list is in **fallback order** — usually smallest first. Another order works when the rules
stay exclusive (a `where` predicate).

> The scope compares the breakpoints by identity. A second `ResponsiveScreens` — even with the
> same rules — is a new configuration, and in debug mode `screens.of`, `dataOf` and `value`
> assert that the scope above them is their own.

## In a page

```dart
// Whole bodies differ — only the chosen builder runs. Works as a box or a sliver.
screens.layout(
  builders: {
    AppScreen.phone: (_) => const OneColumn(),
    AppScreen.tablet: (_) => const TwoColumns(),
  },
  // Tried first when held sideways — so a (wide) desktop gets ThreeColumns too.
  landscape: {AppScreen.tablet: (_) => const ThreeColumns()},
)

// One value differs.
final gutter = screens.value(context, {AppScreen.phone: 16.0, AppScreen.tablet: 24.0});

// The class itself.
if (screens.of(context) == AppScreen.desktop) const SideMenu(),

// A detail inside a body.
screens.builder((context, data) => data.isAtLeast(AppScreen.tablet) ? const Hint() : const SizedBox())
```

| Member | Gives |
|---|---|
| `screens.scope(child:)` | wraps the app once |
| `screens.layout(builders:, landscape:)` | the body for the current class |
| `screens.value(context, values, landscape:)` | the value for the current class |
| `screens.of(context)` | the current class |
| `screens.dataOf(context)` | class + orientation, `isAtLeast`, `isBelow` |
| `screens.builder((context, data) => …)` | the data inside a builder |
| `screens.forced(screen:, orientation:, child:)` | a fixed class for tests and previews |

Held sideways, each fallback step tries the `landscape` entry first: a class's own upright value
beats an earlier class's sideways one.

## Rebuilds

| Change | What rebuilds |
|---|---|
| Keyboard, system bars, insets | nothing — the scope reads `MediaQuery.sizeOf` only |
| Window resized within one class | the scope (cheap); no dependent |
| Device turned, same class | orientation dependents only — `screens.of`, and `layout` / `value` without landscape entries, do not |
| Class changed | dependents of the screen class |

Switching a `layout` body replaces its subtree: keep state that must survive a resize above it.

## Tests and previews

```dart
screens.forced(
  screen: AppScreen.tablet,
  orientation: Orientation.landscape,
  child: const MaterialApp(home: HomePage()),
)
```

## Building blocks

`ResponsiveScreens` adds no logic; it hands over to public classes you can use directly:
`Breakpoint`, `Breakpoints`, `ScreenMetrics`, `ResponsiveScope`, `ResponsiveData`,
`ResponsiveLayout`, `ResponsiveBuilder`, `ResponsiveAspect`.
