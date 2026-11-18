# Changelog

## 1.0.0

Initial pub.dev release.

### Features

- `ResponsiveScreens<T>` — the one object an app talks to; the screen type is written once. Members: `scope`, `layout`, `value`, `of`, `dataOf`, `builder`, `forced`.
- `Breakpoint<T>` — a user-defined screen class and when it applies: `minWidth`, `minHeight`, `minShortestSide`, `minLongestSide`, and an optional `where` predicate.
- `Breakpoints<T>` — screen classes in fallback order. The last match wins; the first class is the base.
- Fallback — a class without a body or value takes the one declared before it.
- Landscape — optional `landscape` bodies and values, tried first at each fallback step when the device is held sideways.
- `ResponsiveScope<T>` — resolves the class from `MediaQuery.sizeOf` only; `ResponsiveScope.forced` for tests and previews.
- `ResponsiveLayout<T>` / `ResponsiveBuilder<T>` — build only the current body; work as a box or a sliver.
- Precise rebuilds via `InheritedModel` aspects: keyboard and insets rebuild nothing, a resize within a class rebuilds no dependent, turning the device rebuilds orientation dependents only.

### Notes

- Depends on Flutter only. Supports Dart 3.0+ / Flutter 3.10+.
- Debug asserts: `layout` and `value` need an entry for the base class; `of`, `dataOf` and `value` check that the nearest scope uses the same `ResponsiveScreens` instance.
- See `example/` for a full app and custom breakpoints, and `docs/how-it-works.html` in the repository for a visual guide.
