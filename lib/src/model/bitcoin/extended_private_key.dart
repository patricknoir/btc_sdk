// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:hex/hex.dart';

class ExtendedPrivateKey extends PrivateKey {
  static final Uint8List BITCOIN_SEED = "Bitcoin seed".toUint8ListFromUtf8;
  static const String PATH_MASTER_PRIVATE = "m";
  static const int PRIVATE_KEY_HARDENED_MIN_INDEX = 2147483648;
  static const int PRIVATE_KEY_HARDENED_MAX_INDEX = 4294967295;

  final Uint8List chainCode;
  final String? parentPath;
  final int index;
  late final String path;

  ExtendedPrivateKey(this.chainCode, Uint8List value, {this.parentPath, this.index = 0, EllipticCurve? curve}) : super(value, curve: curve) {
    path = (parentPath == null) ? PATH_MASTER_PRIVATE : parentPath! + "/" + index.toString();
  }

  factory ExtendedPrivateKey.masterKey(Uint8List seed) {
    final longKey = Hash.hmacSHA512(BITCOIN_SEED, seed);
    final masterPrivateKey = longKey.sublist(0, 32);
    final chainCode = longKey.sublist(32, 64);
    return ExtendedPrivateKey(chainCode, masterPrivateKey);
  }

  ExtendedPrivateKey deriveKey({bool hardened = true, int? index}) => hardened ? hardenedChild(index ?? PRIVATE_KEY_HARDENED_MIN_INDEX) : normalChild(index ?? 0);

  ExtendedPrivateKey normalChild([int index = 0]) {
    final data = publicKey.compressed.concat(index.to32Bits(endian: Endian.big));
    final intermediateKey = Hash.hmacSHA512(chainCode, data);
    final left = intermediateKey.sublist(0, 32);
    final newChainCode = intermediateKey.sublist(32, 64);

    final newValue = (left.toBigInt + value.toBigInt) % curve.n;

    return ExtendedPrivateKey(newChainCode, newValue.toUint8List, parentPath: path, index: index);
  }

  ExtendedPrivateKey hardenedChild(int index) {
    assert(index >= PRIVATE_KEY_HARDENED_MIN_INDEX && index <= PRIVATE_KEY_HARDENED_MAX_INDEX);
    final data = 0.to8Bits().concat(value.concat(index.to32Bits(endian: Endian.big)));
    final intermediateKey = Hash.hmacSHA512(chainCode, data);
    final left = intermediateKey.sublist(0, 32);
    final newChainCode = intermediateKey.sublist(32, 64);

    final newValue = (left.toBigInt + value.toBigInt) % curve.n;

    return ExtendedPrivateKey(newChainCode, newValue.toUint8List, parentPath: path, index: index);
  }

  @override
  PublicKey get publicKey => (index < PRIVATE_KEY_HARDENED_MIN_INDEX) ? super.publicKey : throw Exception("Operation not supported on an Hardened Private Key");
}