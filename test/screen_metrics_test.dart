import "package:responsive_screen_kit/responsive_screen_kit.dart";
import "package:flutter/widgets.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("derives the sides from the size", () {
    const metrics = ScreenMetrics(Size(820, 1180));
    expect(metrics.width, 820);
    expect(metrics.height, 1180);
    expect(metrics.shortestSide, 820);
    expect(metrics.longestSide, 1180);
  });

  test("landscape only when wider than tall; a square is portrait", () {
    expect(const ScreenMetrics(Size(1180, 820)).orientation,
        Orientation.landscape);
    expect(
        const ScreenMetrics(Size(820, 1180)).orientation, Orientation.portrait);
    expect(
        const ScreenMetrics(Size(600, 600)).orientation, Orientation.portrait);
  });

  test("equal by size", () {
    expect(const ScreenMetrics(Size(1, 2)), const ScreenMetrics(Size(1, 2)));
    expect(const ScreenMetrics(Size(1, 2)).hashCode,
        const ScreenMetrics(Size(1, 2)).hashCode);
    expect(const ScreenMetrics(Size(1, 2)),
        isNot(const ScreenMetrics(Size(2, 1))));
  });

  test("an empty size is portrait with zero sides", () {
    const metrics = ScreenMetrics(Size.zero);
    expect(metrics.orientation, Orientation.portrait);
    expect(metrics.shortestSide, 0);
  });

  test("toString shows the size", () {
    expect(const ScreenMetrics(Size(820, 1180)).toString(),
        "ScreenMetrics(820.0 × 1180.0)");
  });
}
