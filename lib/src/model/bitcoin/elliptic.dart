import 'dart:math';

import 'package:equatable/equatable.dart';

/// An elliptic curve is a set of points described by the equation `y² = x³ + ax + b mod p`, so this is where the a and b variables come from. Different curves will have different values for these coefficients, and a=0 and b=7 are the ones specific to [EllipticCurve.secp256k1].
///
/// The prime modulus p is just a number that keeps all of the numbers within a specific range when performing mathematical calculations (again it’s specific to secp256k1). The fact that it’s a prime number is a key ingredient for the cryptography to work, but that’s an aside.
///
/// There are n number of points on the curve we can reach. This is also referred to as the “order”. It’s less than p, and it’s based on the chosen generator point (see below).
///
/// Finally, every curve has a generator point G, which is basically the starting point on the curve used when performing most mathematical operations. The exact origin for the choice of this point is unknown1, but it’s usually because it provides a high order (see above) and has shown to not have any inherent cryptographic weaknesses.
class EllipticCurve extends Equatable {
  final BigInt a;
  final BigInt b;
  final BigInt p;
  final BigInt n;
  final BigIntPoint G;

  /// Create an elliptic curve by specifying the equation parameters: `y² = x³ + ax + b mod p`.
  const EllipticCurve._({required this.a, required this.b, required this.p, required this.n, required this.G});

  /// This is a nickname for one of the specific curves used in elliptic curve cryptography:
  ///
  /// - sec = Standard for Efficient Cryptography — A consortium that develops commercial standards for cryptography.
  /// - p = Prime — The prime number used to create the finite field.
  /// - 256 = 256 bits — Size of the prime field used.
  /// - k = Koblitz — Specific type of curve.
  /// - 1 = First curve in this category.
  static final EllipticCurve secp256k1 =
    EllipticCurve._(
      a: BigInt.from(0),
      b: BigInt.from(7),
      p: BigInt.parse("115792089237316195423570985008687907853269984665640564039457584007908834671663", radix: 10), // 2^256 - 2^32 - 2^9 - 2^8 - 2^7 - 2^6 - 2^4 - 1
      n: BigInt.parse('115792089237316195423570985008687907852837564279074904382605163141518161494337', radix: 10),
      G: BigIntPoint(
          x: BigInt.parse('55066263022277343669578718895168534326250603453777594175500187360389116729240', radix: 10),
          y: BigInt.parse('32670510020758816978083085130507043184471273380659243275938904335757337482424', radix: 10)
      )
    );


  /// “Doubling” a point is the same thing as “adding” a point to itself.
  ///
  /// From a visual perspective, to “double” a point you draw a tangent to the curve at the given point, then find the point on the curve this line intersects (there will only be one), then take the reflection of this point across the x-axis.
  BigIntPoint double(BigIntPoint point) {
    // slope = (3x₁² + a) / 2y₁ = (3x₁² + a) * inverse(2y₁)
    BigInt slope = ((BigInt.from(3) * point.x.pow(2) + a) * (BigInt.from(2) * point.y).modInverse(p)) % p;

    // x = slope² - 2x₁
    BigInt x = (slope.pow(2) - BigInt.from(2) * point.x) % p;

    // y = slope * (x₁ - x) - y₁
    BigInt y = (slope * (point.x - x) - point.y) % p;

    return BigIntPoint(x: x, y: y);
  }

  /// As expected, “addition” of two points in elliptic curve mathematics isn’t the same as straightforward integer addition, but it’s called “addition” anyway.
  ///
  /// From a visual perspective, to “add” two points together you draw a line between them, then find the point on the curve this line intersects (there will only be one), then take the reflection of this point across the x-axis.
  BigIntPoint add( BigIntPoint point1, BigIntPoint point2) {
    if(point1 == point2) {
      return double(point1);
    }

    // slope = (y₁ - y₂) / (x₁ - x₂) = (y₁ - y₂) * inverse(x₁ - x₂)
    BigInt slope = ((point1.y - point2.y) * (point1.x - point2.x).modInverse(p)) % p;

    // x = slope² - x₁ - x₂
    BigInt x = (slope.pow(2) - point1.x - point2.x) % p;

    // y = slope * (x₁ - x) - y₁
    BigInt y = (slope * (point1.x - x) - point1.y) % p;

    return BigIntPoint(x: x, y: y);
  }

  /// A faster approach to multiplication is to use the double-and-add algorithm, where you make an efficient use of both doubling and adding to reach the target multiple in as few operations as possible.
  ///
  /// For example, if you start at 2 and want to get to 128, it’s faster to perfom six double() operations than it is to perform sixty-four add() operations.
  ///
  /// But how do you know how many double and add operations you need to get to your target multiple?
  ///
  /// Well, amazingly, if you convert any integer in to its binary representation, the 1s and 0s will provide a map for the sequence of double() and add() operations you need to perform to reach that multiple.
  ///
  /// Working from left to right and ignoring the first number:
  ///
  /// - 0 = double
  /// - 1 = double and add
  BigIntPoint multiply(BigInt k) {
    // create a copy the initial starting point (for use in addition later on)
    BigIntPoint current = G;

    // create a copy the initial starting point (for use in addition later on)
    String kBinary = k.toRadixString(2);

    for(int i=1; i<kBinary.length; i++) {
      // double
      current = double(current);

      if(kBinary[i] == "1") {
        current = add(current, G);
      }
    }

    return current;
  }

  @override
  List<Object?> get props => [a,b,p,n,G];
}

class BigIntPoint extends Equatable {
  final BigInt x;
  final BigInt y;

  const BigIntPoint({required this.x, required this.y});

  @override
  List<Object?> get props => [x, y];
}

class Modulus {
  static BigInt inverse(BigInt a, {required BigInt p}) {
    // assert(a > BigInt.zero);
    // BigInt m = p;
    // a = a % m;
    // BigInt y = BigInt.one;
    // BigInt prevY = BigInt.zero;
    // while(a > BigInt.one) {
    //   BigInt q = m ~/ a;
    //   BigInt currentY = y;
    //   y = prevY - q * y;
    //   prevY = currentY;
    //   BigInt originA = a;
    //   a = m % a;
    //   m = originA;
    // }
    // return y % p;

    return a.modInverse(p);
  }
}