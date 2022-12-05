// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:btc_sdk/src/model/bitcoin/elliptic_algo.dart';
import 'package:equatable/equatable.dart';

class PublicKey extends Equatable {

  static const int UNCOMPRESSED_PREFIX = 0x04;
  static const int COMPRESSED_EVEN_PREFIX = 0x02;
  static const int COMPRESSED_ODD_PREFIX = 0x03;

  final EllipticCurve curve;
  final BigIntPoint point;

  const PublicKey(this.curve, this.point);
  factory PublicKey.from(EllipticCurve curve, BigInt x, BigInt y) => PublicKey(curve, BigIntPoint(x: x, y: y));

  Uint8List get uncompressed => [UNCOMPRESSED_PREFIX].toUint8List.concat(point.x.toRadixString(16).toUint8ListFromHex!).concat(point.y.toRadixString(16).toUint8ListFromHex!);
  Uint8List get compressed => ((point.y.isEven) ? [COMPRESSED_EVEN_PREFIX] : [ COMPRESSED_ODD_PREFIX]).toUint8List.concat(point.x.toRadixString(16).toUint8ListFromHex!);

  @override
  List<Object?> get props => [curve, point];
}