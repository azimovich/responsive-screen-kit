import "package:responsive_screen_kit/responsive_screen_kit.dart";
import "package:flutter/widgets.dart";
import "package:flutter_test/flutter_test.dart";

import "support.dart";

void main() {
  group("resolve", () {
    test("the last match wins", () {
      expect(breakpoints.resolve(const ScreenMetrics(phone)), Screen.phone);
      expect(
          breakpoints.resolve(const ScreenMetrics(foldable)), Screen.foldable);
      expect(breakpoints.resolve(const ScreenMetrics(iPad)), Screen.tabletMini);
      expect(
          breakpoints.resolve(const ScreenMetrics(iPadPro)), Screen.tabletBig);
    });

    test("a tablet stays a tablet sideways", () {
      expect(breakpoints.resolve(const ScreenMetrics(iPadSideways)),
          Screen.tabletMini);
      expect(breakpoints.resolve(const ScreenMetrics(iPadProSideways)),
          Screen.tabletBig);
    });

    test("a narrow window on a tablet is what its width says", () {
      expect(breakpoints.resolve(const ScreenMetrics(Size(410, 1180))),
          Screen.phone);
    });

    test("the base when nothing matches, even if it has minimums of its own",
        () {
      final strict = Breakpoints<String>(const [
        Breakpoint("small", minWidth: 300),
        Breakpoint("large", minWidth: 900),
      ]);
      expect(strict.resolve(const ScreenMetrics(Size(100, 100))), "small");
    });

    test("any number of classes, any id type", () {
      final one = Breakpoints<int>(const [Breakpoint(0)]);
      expect(one.resolve(const ScreenMetrics(Size(5000, 5000))), 0);
    });
  });

  group("order", () {
    test("screens and base as declared", () {
      expect(breakpoints.screens, Screen.values);
      expect(breakpoints.base, Screen.phone);
    });

    test("rank grows with size", () {
      expect(
          [for (final s in Screen.values) breakpoints.rankOf(s)], [0, 1, 2, 3]);
    });

    test("an unknown class is an error", () {
      final small = Breakpoints<Screen>(const [Breakpoint(Screen.phone)]);
      expect(() => small.rankOf(Screen.tabletBig), throwsArgumentError);
    });
  });

  group("declaration", () {
    test("empty is refused", () {
      expect(() => Breakpoints<Screen>(const []), throwsAssertionError);
    });

    test("a class twice is refused", () {
      expect(
        () => Breakpoints<Screen>(const [
          Breakpoint(Screen.phone),
          Breakpoint(Screen.phone, minWidth: 600),
        ]),
        throwsAssertionError,
      );
    });

    test("the list given cannot change it later", () {
      final list = [const Breakpoint(Screen.phone)];
      final set = Breakpoints<Screen>(list);
      list.add(const Breakpoint(Screen.tabletBig, minWidth: 1));
      expect(set.screens, [Screen.phone]);
    });
  });
}
