import "package:responsive_screen_kit/responsive_screen_kit.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

import "support.dart";

void main() {
  group("ResponsiveLayout", () {
    testWidgets("builds only the body for this class", (tester) async {
      useSize(tester, iPad);
      final built = <String>[];
      WidgetBuilder body(String name) => (_) {
            built.add(name);
            return Text(name);
          };

      await tester.pumpWidget(
        scoped(
          ResponsiveLayout<Screen>(
            builders: {
              Screen.phone: body("phone"),
              Screen.foldable: body("foldable"),
              Screen.tabletMini: body("tabletMini"),
              Screen.tabletBig: body("tabletBig"),
            },
          ),
        ),
      );

      expect(built, ["tabletMini"]);
      expect(find.text("tabletMini"), findsOneWidget);
    });

    testWidgets("a missing body is the nearest smaller class's",
        (tester) async {
      useSize(tester, iPadPro);
      await tester.pumpWidget(
        scoped(
          ResponsiveLayout<Screen>(
            builders: {
              Screen.phone: (_) => const Text("phone"),
              Screen.tabletMini: (_) => const Text("tablet"),
            },
          ),
        ),
      );
      expect(find.text("tablet"), findsOneWidget);

      await resize(tester, foldable);
      expect(find.text("phone"), findsOneWidget);
    });

    testWidgets(
        "landscape bodies when held sideways, the class's own otherwise",
        (tester) async {
      useSize(tester, iPad);
      Widget layout() => scoped(
            ResponsiveLayout<Screen>(
              builders: {
                Screen.phone: (_) => const Text("phone"),
                Screen.tabletMini: (_) => const Text("upright"),
              },
              landscape: {Screen.tabletMini: (_) => const Text("sideways")},
            ),
          );

      await tester.pumpWidget(layout());
      expect(find.text("upright"), findsOneWidget);
      await resize(tester, iPadSideways);
      expect(find.text("sideways"), findsOneWidget);
      // tabletBig has no body of its own: tabletMini's sideways one.
      await resize(tester, iPadProSideways);
      expect(find.text("sideways"), findsOneWidget);
    });

    testWidgets("without landscape bodies, turning does not rebuild it",
        (tester) async {
      useSize(tester, iPad);
      var builds = 0;
      await tester.pumpWidget(
        scoped(
          ResponsiveLayout<Screen>(
            builders: {
              Screen.phone: (_) {
                builds++;
                return const SizedBox();
              },
            },
          ),
        ),
      );
      await resize(tester, iPadSideways);
      expect(builds, 1);
    });

    testWidgets("keeps the body's state across a resize within its class",
        (tester) async {
      useSize(tester, iPad);
      await tester.pumpWidget(
        scoped(ResponsiveLayout<Screen>(
            builders: {Screen.phone: (_) => const _Counter()})),
      );
      await tester.tap(find.byType(_Counter));
      await tester.pump();
      expect(find.text("1"), findsOneWidget);

      await resize(tester, const Size(900, 1180));
      expect(find.text("1"), findsOneWidget);
    });

    testWidgets("works as a sliver", (tester) async {
      useSize(tester, phone);
      await tester.pumpWidget(
        scoped(
          CustomScrollView(
            slivers: [
              ResponsiveLayout<Screen>(
                builders: {
                  Screen.phone: (_) =>
                      const SliverToBoxAdapter(child: Text("one column")),
                  Screen.tabletMini: (_) =>
                      const SliverToBoxAdapter(child: Text("two columns")),
                },
              ),
            ],
          ),
        ),
      );
      expect(find.text("one column"), findsOneWidget);
    });

    testWidgets("a missing base body is an error", (tester) async {
      useSize(tester, iPad);
      await tester.pumpWidget(
        scoped(ResponsiveLayout<Screen>(
            builders: {Screen.tabletMini: (_) => const SizedBox()})),
      );
      expect(tester.takeException(), isAssertionError);
    });
  });

  group("ResponsiveBuilder", () {
    testWidgets("hands over the data and honours its aspect", (tester) async {
      useSize(tester, iPad);
      var builds = 0;
      ResponsiveData<Screen>? seen;
      await tester.pumpWidget(
        scoped(
          ResponsiveBuilder<Screen>(
            aspect: ResponsiveAspect.screen,
            builder: (context, data) {
              builds++;
              seen = data;
              return const SizedBox();
            },
          ),
        ),
      );
      expect(seen!.screen, Screen.tabletMini);

      await resize(tester, iPadSideways);
      expect(builds, 1);
      await resize(tester, phone);
      expect(builds, 2);
      expect(seen!.screen, Screen.phone);
    });
  });
}

class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () => setState(() => _count++), child: Text("$_count"));
}
