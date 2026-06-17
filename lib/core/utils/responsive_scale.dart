import 'package:flutter/material.dart';

class ResponsiveScale {
  ResponsiveScale(this.context);
  final BuildContext context;

  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;
  bool get isTablet => width >= 600;
  bool get isLandscape => width > height;

  double s(double v) => v * (width / 430).clamp(0.75, 1.4);
  double f(double v) => _clamp(v, 0.8, 1.3);
  double p(double v) => _clamp(v, 0.7, 1.5);

  double _clamp(double v, double lo, double hi) {
    final scaled = s(v);
    if (v >= 0) return scaled.clamp(v * lo, v * hi);
    return scaled.clamp(v * hi, v * lo);
  }

  double get pad4 => p(4);
  double get pad6 => p(6);
  double get pad8 => p(8);
  double get pad10 => p(10);
  double get pad12 => p(12);
  double get pad14 => p(14);
  double get pad16 => p(16);
  double get pad18 => p(18);
  double get pad20 => p(20);
  double get pad24 => p(24);
  double get pad32 => p(32);

  double get font8 => f(8);
  double get font9 => f(9);
  double get font10 => f(10);
  double get font11 => f(11);
  double get font12 => f(12);
  double get font13 => f(13);
  double get font14 => f(14);
  double get font15 => f(15);
  double get font16 => f(16);
  double get font17 => f(17);
  double get font18 => f(18);
  double get font20 => f(20);
  double get font22 => f(22);
  double get font24 => f(24);
  double get font28 => f(28);
  double get font32 => f(32);
  double get font48 => f(48);

  EdgeInsets symH(double h) => EdgeInsets.symmetric(horizontal: p(h));
  EdgeInsets symV(double v) => EdgeInsets.symmetric(vertical: p(v));
  EdgeInsets all(double v) => EdgeInsets.all(p(v));
  EdgeInsets only({double l = 0, double t = 0, double r = 0, double b = 0}) =>
      EdgeInsets.only(left: p(l), top: p(t), right: p(r), bottom: p(b));
  EdgeInsets fromLTRB(double l, double t, double r, double b) =>
      EdgeInsets.fromLTRB(p(l), p(t), p(r), p(b));

  BorderRadius circ(double r) => BorderRadius.circular(p(r));

  Widget Function(Widget) tabletCenter(double maxWidth) =>
      (Widget child) => Center(
            child: SizedBox(
              width: isTablet ? maxWidth.clamp(0, width) : width,
              child: child,
            ),
          );
}
