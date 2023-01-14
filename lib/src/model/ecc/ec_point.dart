import 'package:equatable/equatable.dart';

import 'field_element.dart';

/// y^2 = x^3 + ax + b
class ECPoint extends Equatable {
  late final FieldElement x;
  late final FieldElement y;
  late final FieldElement a;
  late final FieldElement b;

  static final infinity = ECPoint(BigInt.zero, BigInt.zero, BigInt.zero, BigInt.zero, BigInt.one);

  /// y^2 mod p = x^3 + ax + b % mod p
  ECPoint(BigInt x, BigInt y, BigInt a, BigInt b, BigInt p) {
    this.x = FieldElement(x, p);
    this.y = FieldElement(y, p);
    this.a = FieldElement(a, p);
    this.b = FieldElement(b, p);
    // Assert the point is in the curve
    assert(this.y.pow(BigInt.two) == this.x.pow(BigInt.from(3)) + this.a * this.x + this.b);
  }

  @override
  /// Points are equal if and only if they are on the same curve and have the same coordinates.
  List<Object?> get props => [x,y,a,b];

  bool get isInfinity => this == ECPoint.infinity;

  bool isSameCurve(ECPoint other) => (a == other.a) && (b == other.b);

  ECPoint operator+(ECPoint other) {
    assert(isSameCurve(other));

    if(isInfinity) {
      return other;
    }

    if(other.isInfinity) {
      return this;
    }

    //The point are in a vertical line i.e. A and (-A), then the sum is the Identity
    // A + (-A) = I
    if(x == other.x && y != other.y) {
      return ECPoint.infinity;
    }

    // When is the same point
    if(this == other) {
      // when the 2 points are the same, the line is tangent to the curve
      // 2y dy = (3x^2 + a) dx => dy/dx = (3x^2 + a)/2y
      final slope = (FieldElement(BigInt.from(3), x.order) * x.pow(BigInt.two) + a) / (FieldElement(BigInt.two, y.order) * y);

      if(slope.value == BigInt.zero) {
        return infinity;
      }

      final sumX = slope.pow(BigInt.two) - x - other.x;
      final sumY = slope * (x - sumX) - y;

      return ECPoint(sumX.value, sumY.value, a.value, b.value, x.order);
    } else {
      // Different points
      //define the line equation y = mx + q (In english m, the angular coefficient is called slope)
      final slope = (other.y - y) / (other.x - x);
      // final q = other.y - slope * other.x;

      final sumX = slope.pow(BigInt.two) - x - other.x;
      final sumY = slope * (x - sumX) - y;

      return ECPoint(sumX.value, sumY.value, a.value, b.value, x.order);
    }
  }
}