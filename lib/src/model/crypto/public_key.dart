// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:equatable/equatable.dart';

/// Represent an instance of a [PublicKey] derived from the [SecretKey] by using the
/// [EllipticCurve] instance associated.
///
/// `PublicKey = curve.G * SecretKey`
///
class PublicKey extends Equatable {

  static const int UNCOMPRESSED_PREFIX = 0x04;
  static const int COMPRESSED_EVEN_PREFIX = 0x02;
  static const int COMPRESSED_ODD_PREFIX = 0x03;

  final EllipticCurve curve;
  final BigIntPoint point;

  /// Create a [PublicKey] instance from a [BigPoint] and an [EllipticCurve] instance.
  const PublicKey(this.curve, this.point);

  factory PublicKey.from(EllipticCurve curve, BigInt x, BigInt y) => PublicKey(curve, BigIntPoint(x: x, y: y));

  /// Parse a public key from its SEC format, with a prefix specifying if the key is uncompressed or compressed.
  /// In case of compressed SEC, it resolves the [curve] equation and discriminate which of the 2 y values should be used (odd or even).
  factory PublicKey.fromSEC(EllipticCurve curve, Uint8List secData) => (secData.elementAt(0) == UNCOMPRESSED_PREFIX) ? _fromUncompressed(secData, curve) : _fromCompressed(secData, curve);

  static PublicKey _fromCompressed(Uint8List secData, EllipticCurve curve) {
    assert(secData.length == 33);
    assert(secData.elementAt(0) == COMPRESSED_EVEN_PREFIX || secData.elementAt(0) == COMPRESSED_ODD_PREFIX);
    final isEven = secData.elementAt(0) == COMPRESSED_EVEN_PREFIX;
    final x = secData.sublist(1).toBigInt;
    final ys = curve.apply(x);
    final yEven = ys.value1.isEven ? ys.value1 : ys.value2;
    final yOdd = ys.value1.isOdd ? ys.value1 : ys.value2;
    assert(yEven.isEven);
    assert(yOdd.isOdd);
    return PublicKey.from(curve, x, isEven ? yEven : yOdd);
  }
  
  static PublicKey _fromUncompressed(Uint8List data, EllipticCurve curve) {
    assert(data.length == 1 + 32 + 32); //length
    assert(data.elementAt(0) == UNCOMPRESSED_PREFIX);
    return PublicKey.from(curve, data.sublist(1, 33).toBigInt, data.sublist(33).toBigInt);
  }

  
  Uint8List toSEC({bool compress: false}) => compress ? compressed : uncompressed;

  /// Serialize the `point.x` and `point.y` of the [PublicKey] prefixed by the [PublicKey.UNCOMPRESSED_PREFIX].
  Uint8List get uncompressed => [UNCOMPRESSED_PREFIX].toUint8List.concat(point.x.toRadixString(16).toUint8ListFromHex!).concat(point.y.toRadixString(16).toUint8ListFromHex!);
  /// The compressed [PublicKey] takes only the coordinate `point.x` of the [PublicKey] prefixed by [PublicKey.COMPRESSED_EVEN_PREFIX] if the
  /// coordinate `point.y` of the [PublicKey] is even, otherwise it uses the [PublicKey.COMPRESSED_ODD_PREFIX].
  Uint8List get compressed => ((point.y.isEven) ? [COMPRESSED_EVEN_PREFIX] : [ COMPRESSED_ODD_PREFIX]).toUint8List.concat(point.x.toRadixString(16).toUint8ListFromHex!);

  /// Return the [Hash.hash160] of the [PublicKey.compressed] representation. This is convenient because is smaller than the original [PublicKey].
  Uint8List toPublicKeyHash({bool compress = false}) => Hash.hash160(compress ? compressed : uncompressed);

  @override
  List<Object?> get props => [curve, point];
}