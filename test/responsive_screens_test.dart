import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:responsive_screen_kit/responsive_screen_kit.dart";

import "support.dart";

void main() {
  /// Pumps [reader] under `screens.scope` and returns what it read.
  Future<T> read<T>(
    WidgetTester tester,
    T Function(BuildContext context) reader,
  ) async {
    late T value;
    await tester.pumpWidget(
      screens.scope(
        child: Builder(
          builder: (context) {
            value = reader(context);
            return const SizedBox();
          },
        ),
      ),
    );
    return value;
  }

  test("wraps the rules it is given in one Breakpoints", () {
    final own = ResponsiveScreens<Screen>(rules);
    expect(own.breakpoints.screens, Screen.values);
    expect(identical(own.breakpoints, own.breakpoints), isTrue);
  });

  group("of", () {
    testWidgets("gives the screen class under its scope", (tester) async {
      useSize(tester, foldable);
      expect(await read(tester, screens.of), Screen.foldable);
    });

    testWidgets("does not rebuild when the device turns", (tester) async {
      useSize(tester, iPad);
      var builds = 0;
      await tester.pumpWidget(
        screens.scope(
          child: Probe(read: screens.of, onBuild: (_) => builds++),
        ),
      );
      await resize(tester, iPadSideways);
      expect(builds, 1);
    });
  });

  group("value", () {
    testWidgets("falls back to the nearest smaller class", (tester) async {
      useSize(tester, iPadPro);
      final padding = await read(
        tester,
        (c) => screens.value(c, {Screen.phone: 16.0, Screen.tabletMini: 24.0}),
      );
      expect(padding, 24);
    });

    testWidgets("takes the landscape value held sideways", (tester) async {
      useSize(tester, iPadProSideways);
      final columns = await read(
        tester,
        (c) => screens.value(
          c,
          {Screen.phone: 1, Screen.tabletMini: 2},
          landscape: {Screen.tabletBig: 3},
        ),
      );
      expect(columns, 3);
    });

    testWidgets("a null entry is a value, not a fallback", (tester) async {
      useSize(tester, iPad);
      final values = <Screen, double?>{
        Screen.phone: null,
        Screen.tabletMini: 400
      };
      expect(await read(tester, (c) => screens.value(c, values)), 400);

      useSize(tester, phone);
      expect(await read(tester, (c) => screens.value(c, values)), isNull);
    });

    testWidgets("needs a value for the base class", (tester) async {
      useSize(tester, iPad);
      await tester.pumpWidget(
        screens.scope(
          child: Builder(
            builder: (context) {
              screens.value(context, {Screen.tabletMini: 24.0});
              return const SizedBox();
            },
          ),
        ),
      );
      expect(tester.takeException(), isAssertionError);
    });

    testWidgets("without landscape values ignores turning", (tester) async {
      useSize(tester, iPad);
      var builds = 0;
      await tester.pumpWidget(
        screens.scope(
          child: Probe(
            read: (c) => screens.value(c, {Screen.phone: 16.0}),
            onBuild: (_) => builds++,
          ),
        ),
      );
      await resize(tester, iPadSideways);
      expect(builds, 1);
    });
  });

  group("widgets", () {
    testWidgets("layout builds only the body for this class", (tester) async {
      useSize(tester, iPad);
      final built = <String>[];
      WidgetBuilder body(String name) => (_) {
            built.add(name);
            return Text(name, textDirection: TextDirection.ltr);
          };

      await tester.pumpWidget(
        screens.scope(
          child: screens.layout(
            builders: {
              Screen.phone: body("phone"),
              Screen.tabletMini: body("tabletMini"),
              Screen.tabletBig: body("tabletBig"),
            },
          ),
        ),
      );
      expect(built, ["tabletMini"]);
    });

    testWidgets("builder hands over the resolved data", (tester) async {
      useSize(tester, iPad);
      ResponsiveData<Screen>? seen;
      await tester.pumpWidget(
        screens.scope(
          child: screens.builder((context, data) {
            seen = data;
            return const SizedBox();
          }),
        ),
      );
      expect(seen!.screen, Screen.tabletMini);
    });

    testWidgets("forced ignores the window", (tester) async {
      useSize(tester, phone);
      late ResponsiveData<Screen> data;
      await tester.pumpWidget(
        screens.forced(
          screen: Screen.tabletBig,
          orientation: Orientation.landscape,
          child: Builder(
            builder: (context) {
              data = screens.dataOf(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(data.screen, Screen.tabletBig);
      expect(data.isLandscape, isTrue);
    });
  });

  group("dataOf", () {
    testWidgets("asserts the scope uses these breakpoints", (tester) async {
      useSize(tester, iPad);
      await tester.pumpWidget(
        ResponsiveScope<Screen>(
          breakpoints: Breakpoints<Screen>(rules),
          child: Builder(
            builder: (context) {
              screens.dataOf(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(tester.takeException(), isAssertionError);
    });

    testWidgets("without a scope throws a FlutterError", (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      );
      expect(() => screens.dataOf(context), throwsFlutterError);
    });
  });
}
