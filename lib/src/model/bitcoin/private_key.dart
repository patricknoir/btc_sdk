import 'dart:convert';
import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:btc_sdk/src/model/bitcoin/elliptic.dart';
import 'package:btc_sdk/src/model/bitcoin/network.dart';
import 'package:btc_sdk/src/model/bitcoin/public_key.dart';
import 'package:btc_sdk/src/model/bitcoin/wif_private_key.dart';
import 'package:btc_sdk/src/model/crypto/hash.dart';
import 'package:hex/hex.dart';

/// Contains the value of a valid private key for bitcoin wallets.
class PrivateKey {
  late final EllipticCurve curve;
  final Uint8List value = Uint8List(32);
  /// The publicKey is the [BigIntPoint] in the [EllipticCurve] obtained by multiplying the [PrivateKey.value] by the `curve.G` point of the [EllipticCurve] used.
  late final PublicKey publicKey;

  /// Create an instance of [PrivateKey] from a valid 32 bytes input.
  ///
  /// If the passed value is an array exceeding the 32 bytes, the most significant bytes will be truncated.
  /// The passed [EllipticCurve] will be used to perform the multiplication in order to derive the [PublicKey].
  /// If no curve is specified the [EllipticCurve.secp256k1] will be used.
  PrivateKey(Uint8List value, {EllipticCurve? curve}) {
    if(value.length >= 32) {
      this.value.setRange(0, 32, value.sublist(value.length - 32));
    } else {
      this.value.setRange(32 - value.length, 32, value);
    }
    publicKey = PublicKey(curve ??= EllipticCurve.secp256k1, curve.multiply(BigInt.parse(value.toHex, radix: 16)));
  }

  /// Create an instance of [PrivateKey] from a valid Hex representation of a 32 bytes array.
  ///
  /// If the hex is longer than 32 bytes the most significan bytes will me truncated.
  /// The passed [EllipticCurve] will be used to perform the multiplication in order to derive the [PublicKey].
  /// If no curve is specified the [EllipticCurve.secp256k1] will be used.
  factory PrivateKey.parseHex(String hex, {EllipticCurve? curve}) {
    final decoded = HEX.decode(hex);
    curve ??= EllipticCurve.secp256k1;
    return PrivateKey(decoded.toUint8List, curve: curve);
  }

  /// Create an instance of [PrivateKey] from a Seed string.
  ///
  /// The passed [EllipticCurve] will be used to perform the multiplication in order to derive the [PublicKey].
  /// If no curve is specified the [EllipticCurve.secp256k1] will be used.
  factory PrivateKey.fromSeed(String seed, {EllipticCurve? curve}) => PrivateKey(Hash.sha256(utf8.encode(seed).toUint8List), curve: curve);

  /// Return a [Uint8List] representation for this key
  Uint8List get toUint8List => value;

  WifPrivateKey toWifPrivateKey(Network network, bool isCompressed) => WifPrivateKey(network, this.value, isCompressed);
}