import 'dart:math';
import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:btc_sdk/src/model/bitcoin/private_key.dart';
import 'package:equatable/equatable.dart';

class SignedHash extends Equatable {
  final Uint8List hash;
  final BigInt r;
  final BigInt s;

  const SignedHash(this.hash, this.r, this.s);

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
    final s = nonce.modInverse(prvKey.curve.n) * (BigInt.parse(hash.toHex, radix:16) + BigInt.parse(prvKey.value.toHex, radix: 16) * r) % prvKey.curve.n;

    return SignedHash(hash, r, s);
  }

  bool verify(PublicKey pubKey) {
    // point1 = multiply(s⁻¹ * hash)
    final point1 = pubKey.curve.multiply(s.modInverse(pubKey.curve.n) * BigInt.parse(hash.toHex, radix: 16));

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
    return BigInt.parse(randomBytesArray.toHex, radix: 16);
  }

  @override
  List<Object?> get props => [hash, r, s];

}