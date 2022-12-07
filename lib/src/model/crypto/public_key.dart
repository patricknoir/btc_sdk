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