// ignore_for_file: constant_identifier_names

import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';

class ExtendedPublicKey extends PublicKey {
  static const String PATH_MASTER_PUBLIC = "mp";

  final Uint8List chainCode;
  final String? parentPath;
  final int index;
  late final String path;

  ExtendedPublicKey(this.chainCode, BigIntPoint point, {this.parentPath,
      this.index = 0, EllipticCurve? curve}) : super(curve ?? EllipticCurve.secp256k1, point) {
    path = (parentPath == null) ? PATH_MASTER_PUBLIC : parentPath! + "/" + index.toString();
  }

  factory ExtendedPublicKey.fromCompressedParentPublicKey(Uint8List chainCode, Uint8List compressedPubKey, {EllipticCurve? curve, String? parentPath, int index = 0}) {
    final data = compressedPubKey.concat(index.to32Bits(endian: Endian.big));
    final intermediateKey = Hash.hmacSHA512(chainCode, data);
    final k = intermediateKey.sublist(0, 32).toBigInt;
    final newChainCode = intermediateKey.sublist(32, 64);

    final point = (curve ?? EllipticCurve.secp256k1).multiply(k);
    return ExtendedPublicKey(newChainCode, point, parentPath: parentPath, curve: curve);
  }

  ExtendedPublicKey deriveKey([int index = 0]) {
    final data = compressed.concat(index.to32Bits(endian: Endian.big));
    final intermediateKey = Hash.hmacSHA512(chainCode, data);
    final k = intermediateKey.sublist(0, 32).toBigInt;
    final newChainCode = intermediateKey.sublist(32, 64);

    final point = curve.multiply(k);
    return ExtendedPublicKey(newChainCode, point, parentPath: path, curve: curve);
  }

}