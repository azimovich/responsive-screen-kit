## 1.0.0

Initial release.

- `ResponsiveScreens<T>` — one object for the whole API, the type argument written once: `scope`, `layout`, `value`, `of`, `dataOf`, `builder`, `forced`. In debug mode `of`, `dataOf` and `value` assert that the nearest scope uses its own breakpoints.
- `Breakpoint<T>` — one user-defined screen class and its minimums (width, height, shortest/longest side) plus an optional `where` predicate.
- `Breakpoints<T>` — screen classes in fallback order; the last match wins, missing values fall back to the class declared before.
- `ResponsiveScope<T>` — resolves the class from `MediaQuery.sizeOf` only; `ResponsiveScope.forced` for tests and previews.
- `ResponsiveLayout<T>` / `ResponsiveBuilder<T>` — build only the body for the current class, with optional landscape bodies.
- Aspect-based rebuilds via `InheritedModel`: keyboard and insets rebuild nothing, turning the device rebuilds orientation dependents only.
