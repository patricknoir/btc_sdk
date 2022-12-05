import 'dart:math';
import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:equatable/equatable.dart';

/// A [SignedHash] contains the hashed and it's signature.
///
/// The [Signature] is an instance of [BigIntPoint] representing a point within the
/// [PrivateKey.curve] derived from the [PrivateKey.value].
///
class SignedHash extends Equatable {
  final Uint8List hash;
  final BigInt r;
  final BigInt s;

  /// Private constructor to instantiate a [SignedHash] with the original message as [hash] and
  /// its signature points [r] and [s].
  const SignedHash._(this.hash, this.r, this.s);

  /// Given the [hash], the [PrivateKey] to use to sign the [hash], it creates an instance of [SignedHash].
  ///
  /// Optionally you can provide the [nonce] random value to be used during the signing, if not provided
  /// a random number of 32 bytes will be generated.
  factory SignedHash.sign(Uint8List hash, PrivateKey prvKey, {BigInt? nonce}) {
    // generate random number if not given
    while(nonce == null) {
      BigInt potentialNonce = _generateNonce();
      if(potentialNonce < prvKey.curve.n) {
        nonce = potentialNonce;
      }
    }

    // r = the x value of a random point on the curve
    final r = prvKey.curve.multiply(nonce).x % prvKey.curve.n;

    // s = nonce⁻¹ * (hash + private_key * r) mod n
    final s = nonce.modInverse(prvKey.curve.n) * (hash.toBigInt + prvKey.value.toBigInt * r) % prvKey.curve.n;

    return SignedHash._(hash, r, s);
  }

  /// Verifies if this [SignedHash] instance was signed using the [PrivateKey] associated to the passed [PublicKey].
  bool verify(PublicKey pubKey) {
    // point1 = multiply(s⁻¹ * hash)
    final point1 = pubKey.curve.multiply(s.modInverse(pubKey.curve.n) * hash.toBigInt);

    // point2 = multiply((s⁻¹ * r), public_key)
    final point2 = pubKey.curve.multiply(s.modInverse(pubKey.curve.n) * r, generator: pubKey.point);

    // add two points together
    final point3 = pubKey.curve.add(point1, point2);

    // check x coordinate of this point matches the x-coordinate of the random point given
    return point3.x == r;
  }

  static BigInt _generateNonce() {
    final random = Random.secure();
    final randomBytesArray = List<int>.generate(32, (i) => random.nextInt(256)).toUint8List;
    return randomBytesArray.toBigInt;
  }

  @override
  List<Object?> get props => [hash, r, s];

}