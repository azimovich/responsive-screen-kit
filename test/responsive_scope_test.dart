import "package:responsive_screen_kit/responsive_screen_kit.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "support.dart";

/// How many times the scope resolved: a breakpoint whose predicate counts its calls.
int _resolutions = 0;
bool _counting(ScreenMetrics _) {
  _resolutions++;
  return false;
}

final _counted = Breakpoints<Screen>(const [
  Breakpoint(Screen.phone),
  Breakpoint(Screen.tabletBig, where: _counting),
]);

void main() {
  group("resolution", () {
    for (final (size, screen) in const [
      (phone, Screen.phone),
      (foldable, Screen.foldable),
      (iPad, Screen.tabletMini),
      (iPadProSideways, Screen.tabletBig),
    ]) {
      testWidgets("$size → ${screen.name}", (tester) async {
        useSize(tester, size);
        late ResponsiveData<Screen> data;
        await tester.pumpWidget(
          scoped(
            Builder(
              builder: (context) {
                data = ResponsiveScope.of<Screen>(context);
                return const SizedBox();
              },
            ),
          ),
        );
        expect(data.screen, screen);
        expect(
          data.orientation,
          size.width > size.height
              ? Orientation.landscape
              : Orientation.portrait,
        );
        expect(identical(data.breakpoints, breakpoints), isTrue);
      });
    }

    testWidgets("follows the window when it is resized", (tester) async {
      useSize(tester, phone);
      final seen = <Object?>[];
      await tester
          .pumpWidget(scoped(Probe(read: screens.of, onBuild: seen.add)));
      await resize(tester, iPad);
      await resize(tester, iPadPro);
      await resize(tester, phone);
      expect(seen,
          [Screen.phone, Screen.tabletMini, Screen.tabletBig, Screen.phone]);
    });

    testWidgets("seen by routes and dialogs when wrapping MaterialApp",
        (tester) async {
      useSize(tester, iPad);
      final key = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        ResponsiveScope<Screen>(
          breakpoints: breakpoints,
          child: MaterialApp(navigatorKey: key, home: const SizedBox()),
        ),
      );

      Screen? inDialog;
      showDialog<void>(
        context: key.currentContext!,
        builder: (context) {
          inDialog = screens.of(context);
          return const SizedBox();
        },
      );
      await tester.pumpAndSettle();
      expect(inDialog, Screen.tabletMini);
    });
  });

  group("lookup", () {
    testWidgets("without a scope: of throws, maybeOf is null", (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        Builder(
          builder: (c) {
            context = c;
            return const SizedBox();
          },
        ),
      );
      expect(ResponsiveScope.maybeOf<Screen>(context), isNull);
      expect(() => ResponsiveScope.of<Screen>(context), throwsFlutterError);
    });

    testWidgets("a scope of another type is not this one", (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        ResponsiveScope<String>(
          breakpoints: Breakpoints<String>(const [Breakpoint("only")]),
          child: Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(ResponsiveScope.maybeOf<Screen>(context), isNull);
      expect(ResponsiveScope.of<String>(context).screen, "only");
    });

    testWidgets("the nearest scope wins", (tester) async {
      useSize(tester, iPad);
      late Screen inner;
      await tester.pumpWidget(
        scoped(
          ResponsiveScope<Screen>.forced(
            breakpoints: breakpoints,
            screen: Screen.phone,
            child: Builder(
              builder: (context) {
                inner = screens.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(inner, Screen.phone);
    });
  });

  group("forced", () {
    testWidgets("ignores the window", (tester) async {
      useSize(tester, phone);
      late ResponsiveData<Screen> data;
      await tester.pumpWidget(
        ResponsiveScope<Screen>.forced(
          breakpoints: breakpoints,
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

      await resize(tester, iPad);
      expect(data.screen, Screen.tabletBig);
    });

    testWidgets("is portrait unless told otherwise", (tester) async {
      useSize(tester, iPadSideways);
      late ResponsiveData<Screen> data;
      await tester.pumpWidget(
        ResponsiveScope<Screen>.forced(
          breakpoints: breakpoints,
          screen: Screen.phone,
          child: Builder(builder: (context) {
            data = ResponsiveScope.of<Screen>(context);
            return const SizedBox();
          }),
        ),
      );
      expect(data.orientation, Orientation.portrait);
    });

    testWidgets("a new forced class notifies its dependents", (tester) async {
      final seen = <Object?>[];
      Widget tree(Screen screen) => ResponsiveScope<Screen>.forced(
            breakpoints: breakpoints,
            screen: screen,
            child: Probe(read: screens.of, onBuild: seen.add),
          );
      await tester.pumpWidget(tree(Screen.phone));
      await tester.pumpWidget(tree(Screen.tabletBig));
      expect(seen, [Screen.phone, Screen.tabletBig]);
    });

    testWidgets("switching from forced to the window resolves again",
        (tester) async {
      useSize(tester, iPad);
      final seen = <Object?>[];
      final probe = Probe(read: screens.of, onBuild: seen.add);
      await tester.pumpWidget(ResponsiveScope<Screen>.forced(
          breakpoints: breakpoints, screen: Screen.phone, child: probe));
      await tester.pumpWidget(
          ResponsiveScope<Screen>(breakpoints: breakpoints, child: probe));
      expect(seen, [Screen.phone, Screen.tabletMini]);
    });
  });

  group("rebuilds", () {
    testWidgets("a resize within one class rebuilds no dependent",
        (tester) async {
      useSize(tester, iPad);
      var screenBuilds = 0;
      var fullBuilds = 0;
      await tester.pumpWidget(
        scoped(
          Column(
            children: [
              Probe(read: screens.of, onBuild: (_) => screenBuilds++),
              Probe(read: screens.dataOf, onBuild: (_) => fullBuilds++),
            ],
          ),
        ),
      );

      await resize(tester, const Size(860, 1180));
      await resize(tester, const Size(900, 1100));
      expect(screenBuilds, 1);
      expect(fullBuilds, 1);
    });

    testWidgets("turning rebuilds orientation dependents only", (tester) async {
      useSize(tester, iPad);
      var screenBuilds = 0;
      var orientationBuilds = 0;
      var fullBuilds = 0;
      await tester.pumpWidget(
        scoped(
          Column(
            children: [
              Probe(read: screens.of, onBuild: (_) => screenBuilds++),
              Probe(
                read: (c) => ResponsiveScope.of<Screen>(c,
                        aspect: ResponsiveAspect.orientation)
                    .orientation,
                onBuild: (_) => orientationBuilds++,
              ),
              Probe(read: screens.dataOf, onBuild: (_) => fullBuilds++),
            ],
          ),
        ),
      );

      await resize(tester, iPadSideways);
      expect(screenBuilds, 1, reason: "still a tabletMini");
      expect(orientationBuilds, 2);
      expect(fullBuilds, 2);
    });

    testWidgets("a class change rebuilds screen dependents", (tester) async {
      useSize(tester, iPad);
      var screenBuilds = 0;
      await tester.pumpWidget(
        scoped(Probe(read: screens.of, onBuild: (_) => screenBuilds++)),
      );
      await resize(tester, iPadPro);
      expect(screenBuilds, 2);
    });

    testWidgets("the keyboard and insets rebuild nothing", (tester) async {
      useSize(tester, iPad);
      var builds = 0;
      await tester.pumpWidget(
        scoped(Probe(read: screens.dataOf, onBuild: (_) => builds++)),
      );

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 20);
      await tester.pump();
      expect(builds, 1);
    });

    testWidgets("the keyboard and insets do not even rebuild the scope",
        (tester) async {
      useSize(tester, iPad);
      await tester.pumpWidget(scoped(const SizedBox(), using: _counted));
      final before = _resolutions;

      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pump();
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 20);
      await tester.pump();
      expect(_resolutions, before, reason: "the scope reads the size alone");

      await resize(tester, iPadPro);
      expect(_resolutions, before + 1);
    });

    testWidgets("new breakpoints notify every dependent", (tester) async {
      useSize(tester, iPad);
      var builds = 0;
      Widget tree(Breakpoints<Screen> using) => scoped(
            Probe(
              // Another Breakpoints instance on purpose: read the scope directly,
              // not through the facade that is tied to its own instance.
              read: (c) =>
                  ResponsiveScope.of<Screen>(c, aspect: ResponsiveAspect.screen)
                      .screen,
              onBuild: (_) => builds++,
            ),
            using: using,
          );

      await tester.pumpWidget(tree(breakpoints));
      // The same rules, another instance: still a change of configuration.
      await tester.pumpWidget(tree(Breakpoints<Screen>(rules)));
      expect(builds, 2);
    });
  });
}
