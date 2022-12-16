// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';

class ExtendedPublicKey extends PublicKey {
  static const String PATH_MASTER_PUBLIC = "mp";


  // Master Extended Keys:
  static final Uint8List MASTER_DEPTH = 0x00.to8Bits();
  static final Uint8List MASTER_FINGERPRINT = 0x00000000.to32Bits();
  static final Uint8List CHILD_NUMBER = 0x00000000.to32Bits();

  final ExtendedPublicKey? parentKey;
  final Uint8List chainCode;
  final String? parentPath;
  final int index;
  late final String path;
  final Network network;

  ExtendedPublicKey(this.chainCode, BigIntPoint point, {this.parentKey, this.parentPath,
      this.index = 0, EllipticCurve? curve, this.network = Network.mainnet}) : super(curve ?? EllipticCurve.secp256k1, point) {
    path = (parentPath == null) ? PATH_MASTER_PUBLIC : parentPath! + "/" + index.toString();
  }

  factory ExtendedPublicKey.fromCompressedParentPublicKey(Uint8List chainCode, Uint8List compressedPubKey, {EllipticCurve? curve, String? parentPath, int index = 0, Network network = Network.mainnet}) {
    final data = compressedPubKey.concat(index.to32Bits(endian: Endian.big));
    final intermediateKey = Hash.hmacSHA512(chainCode, data);
    final k = intermediateKey.sublist(0, 32).toBigInt;
    final newChainCode = intermediateKey.sublist(32, 64);

    final point = (curve ?? EllipticCurve.secp256k1).multiply(k);
    return ExtendedPublicKey(newChainCode, point, parentPath: parentPath, curve: curve, network: network);
  }

  ExtendedPublicKey deriveKey([int index = 0]) {
    final data = compressed.concat(index.to32Bits(endian: Endian.big));
    final intermediateKey = Hash.hmacSHA512(chainCode, data);
    final k = intermediateKey.sublist(0, 32).toBigInt;
    final newChainCode = intermediateKey.sublist(32, 64);

    final point = curve.multiply(k);
    return ExtendedPublicKey(newChainCode, point, parentPath: path, curve: curve);
  }

  /// Serialize an [ExtendedPublicKey].
  /// The [ExtendedPublicKey] serialization is a string in Base58 containing:
  /// - version: BIP32 network Prefix - 4 Bytes
  /// - depth: hierarchy depth (how many child derivations) - 1 Byte
  /// - fingerPrint: first 4 bytes of the parent public key hash160 - 4 Bytes
  /// - childNumber: child index value - 4 Bytes
  /// - key value: Compressed Public Key value - 33 bytes
  String get serialize {
    final version = network.bip32Public.to32Bits(endian: Endian.big);
    final depth = (path.split("/").length - 1).to8Bits();
    final fingerPrint = (parentKey?.toPublicKeyHash(compress: true).sublist(0, 4)) ?? MASTER_FINGERPRINT;
    final childNumber = index.to32Bits();
    final key = compressed;

    final input = version.concat(depth.concat(fingerPrint.concat(childNumber.concat(chainCode.concat(key)))));

    final data = input.concat(Hash.checksum(input));

    return data.toBase58;
  }
}