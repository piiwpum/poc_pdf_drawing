// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class Stroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  Stroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  Stroke copyWith({List<Offset>? points, Color? color, double? strokeWidth}) {
    return Stroke(
      points: points ?? this.points,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }

  @override
  String toString() =>
      'Stroke(points: $points, color: $color, strokeWidth: $strokeWidth)';

  @override
  bool operator ==(covariant Stroke other) {
    if (identical(this, other)) return true;

    return listEquals(other.points, points) &&
        other.color == color &&
        other.strokeWidth == strokeWidth;
  }

  @override
  int get hashCode => points.hashCode ^ color.hashCode ^ strokeWidth.hashCode;
}
