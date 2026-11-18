import "package:responsive_screen_kit/responsive_screen_kit.dart";
import "package:flutter/widgets.dart";
import "package:flutter_test/flutter_test.dart";

import "support.dart";

ResponsiveData<Screen> _data(Screen screen,
        [Orientation orientation = Orientation.portrait]) =>
    ResponsiveData(
        screen: screen, orientation: orientation, breakpoints: breakpoints);

void main() {
  test("isAtLeast and isBelow follow the declared order", () {
    final mini = _data(Screen.tabletMini);
    expect(mini.isAtLeast(Screen.phone), isTrue);
    expect(mini.isAtLeast(Screen.tabletMini), isTrue);
    expect(mini.isAtLeast(Screen.tabletBig), isFalse);
    expect(mini.isBelow(Screen.tabletBig), isTrue);
    expect(mini.isBelow(Screen.tabletMini), isFalse);
  });

  group("select", () {
    const values = {Screen.phone: "phone", Screen.tabletMini: "tablet"};

    test("portrait ignores the landscape values", () {
      expect(
        _data(Screen.tabletMini)
            .select(values, landscape: {Screen.tabletMini: "wide"}),
        "tablet",
      );
    });

    test("landscape takes this class's landscape value", () {
      final data = _data(Screen.tabletMini, Orientation.landscape);
      expect(
          data.select(values, landscape: {Screen.tabletMini: "wide"}), "wide");
    });

    test("landscape: an earlier class's sideways value beats its upright one",
        () {
      final data = _data(Screen.tabletBig, Orientation.landscape);
      expect(
          data.select(values, landscape: {Screen.tabletMini: "wide"}), "wide");
    });

    test(
        "landscape: a class's own upright value beats an earlier class's sideways one",
        () {
      final data = _data(Screen.tabletBig, Orientation.landscape);
      const own = {...values, Screen.tabletBig: "big"};
      expect(data.select(own, landscape: {Screen.tabletMini: "wide"}), "big");
    });

    test("landscape walks down to the base", () {
      final data = _data(Screen.foldable, Orientation.landscape);
      expect(data.select(values, landscape: {Screen.phone: "phone sideways"}),
          "phone sideways");
    });
  });

  group("equality", () {
    test("same class, orientation and breakpoints", () {
      expect(_data(Screen.phone), _data(Screen.phone));
      expect(_data(Screen.phone).hashCode, _data(Screen.phone).hashCode);
    });

    test("differs by class or orientation", () {
      expect(_data(Screen.phone), isNot(_data(Screen.foldable)));
      expect(_data(Screen.phone),
          isNot(_data(Screen.phone, Orientation.landscape)));
    });

    test("breakpoints compare by identity", () {
      final copy = Breakpoints<Screen>(rules);
      final other = ResponsiveData(
        screen: Screen.phone,
        orientation: Orientation.portrait,
        breakpoints: copy,
      );
      expect(_data(Screen.phone), isNot(other));
    });
  });

  group("edge cases", () {
    test("select is null when only larger classes have a value", () {
      expect(_data(Screen.foldable).select({Screen.tabletBig: 1}), isNull);
    });

    test(
        "held sideways with only landscape values for larger classes, "
        "the upright value below is used", () {
      final data = _data(Screen.foldable, Orientation.landscape);
      expect(
        data.select({Screen.phone: "phone"},
            landscape: {Screen.tabletMini: "wide"}),
        "phone",
      );
    });

    test("isAtLeast with a class not in the breakpoints is an error", () {
      final small = ResponsiveData(
        screen: "only",
        orientation: Orientation.portrait,
        breakpoints: Breakpoints<String>(const [Breakpoint("only")]),
      );
      expect(() => small.isAtLeast("other"), throwsArgumentError);
    });

    test("toString names the class and orientation", () {
      expect(_data(Screen.tabletMini, Orientation.landscape).toString(),
          "ResponsiveData(Screen.tabletMini, landscape)");
    });
  });
}
