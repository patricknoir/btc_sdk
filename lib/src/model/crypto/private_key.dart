import 'dart:convert';
import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:hex/hex.dart';

/// Contains the value of a valid private key for bitcoin wallets.
/// A Private Key for bitcoin, is a 32 bytes random number sitting which exists in the [EllipticCurve] associated.
class PrivateKey {
  late final EllipticCurve curve;
  /// Private Key secret number
  final Uint8List value = Uint8List(32);
  /// The publicKey is the [BigIntPoint] in the [EllipticCurve] obtained by multiplying the [PrivateKey.value] by `curve.G` point (Generator Point) of the [EllipticCurve] used.
  PublicKey get publicKey => PublicKey(curve, curve.multiply(value.toBigInt));

  /// Create an instance of [PrivateKey] from a valid 32 bytes input.
  ///
  /// If the passed value is an array exceeding the 32 bytes, the most significant bytes will be truncated.
  /// The passed [EllipticCurve] will be used to perform the multiplication in order to derive the [PublicKey].
  /// If no curve is specified the [EllipticCurve.secp256k1] will be used.
  PrivateKey(Uint8List value, {EllipticCurve? curve}) {
    this.curve = (curve ??= EllipticCurve.secp256k1);
    if(value.length >= 32) {
      this.value.setRange(0, 32, value.sublist(value.length - 32));
    } else {
      this.value.setRange(32 - value.length, 32, value);
    }
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
  /// The Seed [String] is converted to UTF8 and then converted to a 32 bytes hash representation using the standard function [Hash.sha256].
  ///
  /// The passed [EllipticCurve] will be used to perform the multiplication in order to derive the [PublicKey].
  /// If no curve is specified the [EllipticCurve.secp256k1] will be used.
  factory PrivateKey.fromSeed(String seed, {EllipticCurve? curve}) => PrivateKey(Hash.sha256(utf8.encode(seed).toUint8List), curve: curve);

  /// Return a [Uint8List] representation for this key
  Uint8List get toUint8List => value;

  WifPrivateKey toWifPrivateKey(Network network, bool isCompressed) => WifPrivateKey(network, value, isCompressed);
}