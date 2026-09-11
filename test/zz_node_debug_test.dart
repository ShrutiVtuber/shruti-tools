import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:astrolabe/sky/moon.dart';
import 'package:astrolabe/sky/time.dart';

void main() {
  test('debug', () {
    final jd = julianDayFromUtc(DateTime.parse('2010-09-29T19:41:03Z'));
    final t = centuriesTT(jd);
    final f = (93.2720950 + 483202.0175233 * t - 0.0036539 * t * t) % 360;
    // ignore: avoid_print
    print('  F (argument of latitude) = ${f.toStringAsFixed(3)}');
    // ignore: avoid_print
    print(
      '  5.13 * sin(F)            = ${(5.128 * math.sin(f * radians)).toStringAsFixed(4)}',
    );
    // ignore: avoid_print
    print(
      '  my moonLatitude          = ${moonLatitude(jd).toStringAsFixed(4)}',
    );
    // ignore: avoid_print
    print(
      '  my moonLongitude         = ${moonLongitude(jd).toStringAsFixed(4)}',
    );
    // mean node: longitude - F should be the node
    // ignore: avoid_print
    print(
      '  longitude - F            = ${((moonLongitude(jd) - f) % 360).toStringAsFixed(4)}  (site node: 8.1938)',
    );
  });
}
