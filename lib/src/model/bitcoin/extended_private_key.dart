// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:btc_sdk/src/model/bitcoin/extended_public_key.dart';

/// An Extended [PrivateKey] represents a [PrivateKey] which can be derived
/// to create new child pairs of [PrivateKey] and [PublicKey] that can be used
/// to perform payments.
///
/// This is an essential part of the Hierarchical Deterministic wallet, because
/// in order to access and unlock all the transactions associated to an [HDWallet]
/// you just need to backup the **Master** [PrivateKey] which is the root [ExtendedPrivateKey].
class ExtendedPrivateKey extends PrivateKey {

  // Master Extended Keys:
  static final Uint8List MASTER_DEPTH = 0x00.to8Bits();
  static final Uint8List MASTER_FINGERPRINT = 0x00000000.to32Bits();
  static final Uint8List CHILD_NUMBER = 0x00000000.to32Bits();

  static final Uint8List BITCOIN_SEED = "Bitcoin seed".toUint8ListFromUtf8;
  static const String PATH_MASTER_PRIVATE = "m";
  static const int PRIVATE_KEY_HARDENED_MIN_INDEX = 2147483648;
  static const int PRIVATE_KEY_HARDENED_MAX_INDEX = 4294967295;

  final ExtendedPrivateKey? parentKey;
  final Uint8List chainCode;
  final String? parentPath;
  final int index;
  late final String path;
  final Network network;

  /// Given a [chainCode] and the Key [value], it creates a valid [ExtendedPrivateKey] which can be used to generate
  /// valid [PublicKey] and derived pairs of [PrivateKey]/[PublicKey].
  ExtendedPrivateKey(this.chainCode, Uint8List value, {this.parentKey, this.parentPath, this.index = 0, EllipticCurve? curve, this.network = Network.mainnet}) : super(value, curve: curve) {
    final indexStr = (index < PRIVATE_KEY_HARDENED_MIN_INDEX) ? index.toString() : (index - PRIVATE_KEY_HARDENED_MIN_INDEX).toString() + "'";
    path = (parentPath == null) ? PATH_MASTER_PRIVATE : parentPath! + "/" + indexStr;
  }


  ///  Given a valid 64 bytes [seed] value, usually obtained from the [Mnemonic] associated
  ///  to an [HDWallet], it creates the **Master** [ExtendedPrivateKey] which can be used
  ///  to generate all the derived [PrivateKey]/[PublicKey] to create and unlock [Transaction]s.
  factory ExtendedPrivateKey.masterKey(Uint8List seed) {
    final longKey = Hash.hmacSHA512(BITCOIN_SEED, seed);
    final masterPrivateKey = longKey.sublist(0, 32);
    final chainCode = longKey.sublist(32, 64);
    return ExtendedPrivateKey(chainCode, masterPrivateKey);
  }

  bool get isMaster => parentPath == null;

  ExtendedPrivateKey deriveKey({bool hardened = true, int? index}) => hardened ? hardenedChild(index ?? PRIVATE_KEY_HARDENED_MIN_INDEX) : normalChild(index ?? 0);

  /// Create a new instance of an [ExtendedPrivateKey] using the current key as a parent.
  ///
  /// Optionally an index can be specified to identify which child branch this key belongs to,
  /// into the hierarchy.
  /// The derived [ExtendedPrivateKey] obtained from this function can be used to create further
  /// derivations.
  ExtendedPrivateKey normalChild([int index = 0]) {
    final data = publicKey.compressed.concat(index.to32Bits(endian: Endian.big));
    final intermediateKey = Hash.hmacSHA512(chainCode, data);
    final left = intermediateKey.sublist(0, 32);
    final newChainCode = intermediateKey.sublist(32, 64);

    final newValue = (left.toBigInt + value.toBigInt) % curve.n;

    return ExtendedPrivateKey(newChainCode, newValue.toUint8List, parentKey: this, parentPath: path, index: index);
  }

  /// Create a new instance of an [ExtendedPrivateKey] using the current key as a parent.
  /// The new instance is an **Hardened Key**, which means cannot be used for [PublicKey] derivations.
  ///
  /// Optionally an index can be specified to determine which child branch this key belongs to,
  /// into the hierarchy.
  /// The derived [ExtendedPrivateKey] obtained from this function can be used to create further
  /// derivations.
  ExtendedPrivateKey hardenedChild(int index) {
    assert(index >= PRIVATE_KEY_HARDENED_MIN_INDEX && index <= PRIVATE_KEY_HARDENED_MAX_INDEX);
    final data = 0.to8Bits().concat(value.concat(index.to32Bits(endian: Endian.big)));
    final intermediateKey = Hash.hmacSHA512(chainCode, data);
    final left = intermediateKey.sublist(0, 32);
    final newChainCode = intermediateKey.sublist(32, 64);

    final newValue = (left.toBigInt + value.toBigInt) % curve.n;

    return ExtendedPrivateKey(newChainCode, newValue.toUint8List, parentKey: this, parentPath: path, index: index);
  }

  @override
  PublicKey get publicKey => (index < PRIVATE_KEY_HARDENED_MIN_INDEX) ? super.publicKey : throw Exception("Operation not supported on an Hardened Private Key");

  /// Create an [ExtendedPublicKey] associated to this [ExtendedPrivateKey].
  ///
  /// [ExtendedPublicKey] can be used to derive new child [PublicKey] associated to the same [ExtendedPrivateKey].
  /// This allows to create new transaction addresses which can be unlocked by the derivation of the [ExtendedPrivateKey].
  ExtendedPublicKey get extendedPublicKey => (index < PRIVATE_KEY_HARDENED_MIN_INDEX) ? ExtendedPublicKey(chainCode, publicKey.point, parentPath: path.replaceFirst(PATH_MASTER_PRIVATE, ExtendedPublicKey.PATH_MASTER_PUBLIC), index: index, curve: curve) : throw Exception("Operation not supported on an Hardened Private Key");

  /// Serialize an [ExtendedPrivateKey].
  /// The [ExtendedPrivateKey] serialization is a string in Base58 containing:
  /// - version: BIP32 network Prefix - 4 Bytes
  /// - depth: hierarchy depth (how many child derivations) - 1 Byte
  /// - fingerPrint: first 4 bytes of the parent public key hash160 - 4 Bytes
  /// - childNumber: child index value - 4 Bytes
  /// - key value: Private Key value prefixed by 0x00 byte - 33 bytes (1 Byte prefix + 32 Bytes [PrivateKey] value)
  String get serialize {
    final version = network.bip32Private.to32Bits(endian: Endian.big);
    final depth = (path.split("/").length - 1).to8Bits();
    final fingerPrint = (parentKey?.publicKey.toPublicKeyHash(compress: true).sublist(0, 4)) ?? MASTER_FINGERPRINT;
    final childNumber = index.to32Bits();
    final prefixedKey = 0x00.to8Bits().concat(value);
    
    final input = version.concat(depth.concat(fingerPrint.concat(childNumber.concat(chainCode.concat(prefixedKey)))));

    final data = input.concat(Hash.checksum(input));

    return data.toBase58;
  }
}