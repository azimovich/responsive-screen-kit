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

    test("the screens it hands out cannot change it", () {
      final copy = breakpoints.screens..clear();
      expect(copy, isEmpty);
      expect(breakpoints.screens, Screen.values);
    });
  });

  group("edge cases", () {
    test("an empty window is the base", () {
      expect(breakpoints.resolve(const ScreenMetrics(Size.zero)), Screen.phone);
    });

    test("equal rules: the one declared later wins", () {
      final tie = Breakpoints<String>(const [
        Breakpoint("base"),
        Breakpoint("first", minWidth: 600),
        Breakpoint("second", minWidth: 600),
      ]);
      expect(tie.resolve(const ScreenMetrics(Size(800, 800))), "second");
    });

    test("an order not by size works with exclusive predicates", () {
      // The foldable comes after the tablet so it borrows the tablet's
      // values; its predicate keeps it from matching a plain tablet.
      final custom = Breakpoints<String>(const [
        Breakpoint("phone"),
        Breakpoint("tablet", minWidth: 600, where: _notSquarish),
        Breakpoint("foldable", minWidth: 600, where: _squarish),
      ]);
      expect(custom.resolve(const ScreenMetrics(Size(820, 1180))), "tablet");
      expect(custom.resolve(const ScreenMetrics(Size(700, 760))), "foldable");
      expect(custom.rankOf("foldable"), greaterThan(custom.rankOf("tablet")));
    });

    test("screenAt and rankOf are inverse", () {
      for (final s in Screen.values) {
        expect(breakpoints.screenAt(breakpoints.rankOf(s)), s);
      }
    });

    test("toString lists the classes in order", () {
      expect(breakpoints.toString(),
          "Breakpoints<Screen>(Screen.phone < Screen.foldable < Screen.tabletMini < Screen.tabletBig)");
    });
  });
}

bool _squarish(ScreenMetrics m) => m.longestSide / m.shortestSide < 1.2;
bool _notSquarish(ScreenMetrics m) => !_squarish(m);
