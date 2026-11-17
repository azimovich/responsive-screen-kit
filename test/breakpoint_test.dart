import "package:responsive_screen_kit/responsive_screen_kit.dart";
import "package:flutter/widgets.dart";
import "package:flutter_test/flutter_test.dart";

bool _wide(ScreenMetrics m) => m.width / m.height > 1.5;

void main() {
  const metrics = ScreenMetrics(Size(820, 1180));

  test("no minimums: always matches", () {
    expect(const Breakpoint("base").matches(const ScreenMetrics(Size.zero)),
        isTrue);
  });

  test("each minimum on its own, inclusive", () {
    expect(const Breakpoint("w", minWidth: 820).matches(metrics), isTrue);
    expect(const Breakpoint("w", minWidth: 821).matches(metrics), isFalse);
    expect(const Breakpoint("h", minHeight: 1180).matches(metrics), isTrue);
    expect(const Breakpoint("h", minHeight: 1181).matches(metrics), isFalse);
    expect(
        const Breakpoint("s", minShortestSide: 820).matches(metrics), isTrue);
    expect(
        const Breakpoint("s", minShortestSide: 821).matches(metrics), isFalse);
    expect(
        const Breakpoint("l", minLongestSide: 1180).matches(metrics), isTrue);
    expect(
        const Breakpoint("l", minLongestSide: 1181).matches(metrics), isFalse);
  });

  test("every minimum must hold", () {
    const tablet = Breakpoint("tablet", minWidth: 600, minShortestSide: 700);
    expect(tablet.matches(metrics), isTrue);
    // An open Duo: wide enough, but its shortest side is short.
    expect(tablet.matches(const ScreenMetrics(Size(669, 951))), isFalse);
  });

  test("the shortest side does not change when the device turns", () {
    const tablet = Breakpoint("tablet", minShortestSide: 700);
    expect(tablet.matches(const ScreenMetrics(Size(820, 1180))), isTrue);
    expect(tablet.matches(const ScreenMetrics(Size(1180, 820))), isTrue);
    // A phone held sideways is wide, but stays below.
    expect(tablet.matches(const ScreenMetrics(Size(844, 390))), isFalse);
  });

  test("a predicate adds to the minimums and keeps the breakpoint const", () {
    const wide = Breakpoint("wide", minWidth: 600, where: _wide);
    expect(wide.matches(const ScreenMetrics(Size(1366, 800))), isTrue);
    expect(wide.matches(const ScreenMetrics(Size(1180, 820))), isFalse);
    expect(
      wide.matches(const ScreenMetrics(Size(500, 100))),
      isFalse,
      reason: "minWidth still holds",
    );
  });

  test("negative minimums are refused", () {
    expect(() => Breakpoint("x", minWidth: -1), throwsAssertionError);
  });
}
