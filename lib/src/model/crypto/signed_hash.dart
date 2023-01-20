// ignore_for_file: constant_identifier_names

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
  const SignedHash(this.hash, this.r, this.s);

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

    return SignedHash(hash, r, s);
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

  static const int DER_MARKER = 0x30;
  static const int DER_R_MARKER = 0x02;
  static const int DER_S_MARKER = 0x02;

  /// <DER_MARKER><Length><DER_R_MARKER><R.Length>[[<0x00>]]<R_VALUE><DER_S_MARKER><S.Length>[[<0x00>]]<S_VALUE>
  Uint8List toDER() {
    var encodedR = r.toUint8List;
    if(encodedR.first >= 0x80) {
      encodedR = [0x00].toUint8List.concat(encodedR);
    }

    final segmentR = [DER_R_MARKER].toUint8List.concat(encodedR.length.to8Bits().concat(encodedR));

    var encodedS = s.toUint8List;
    if(encodedS.first >= 0x80) {
      encodedS = [0x00].toUint8List.concat(encodedS);
    }

    final segmentS = [DER_S_MARKER].toUint8List.concat(encodedS.length.to8Bits().concat(encodedS));

    Uint8List segment = segmentR.concat(segmentS);
    segment = segment.length.to8Bits().concat(segment);

    return [DER_MARKER].toUint8List.concat(segment);
  }

  factory SignedHash.fromDER(Uint8List hash, Uint8List signature) {
    // <DER_MARKER><Length><DER_R_MARKER><R.Length>[[<0x00>]]<R_VALUE><DER_S_MARKER><S.Length>[[<0x00>]]<S_VALUE>
    assert(signature.elementAt(0) == DER_MARKER);
    assert(signature.elementAt(1) == signature.sublist(2).length);
    assert(signature.elementAt(2) == DER_R_MARKER);

    var segmentR = signature.sublist(4, 4 + signature.elementAt(3));
    assert(segmentR.first == 0x00 ? segmentR.elementAt(1) >= 0x80 : segmentR.elementAt(0) < 0x80);
    segmentR = (segmentR.elementAt(0) == 0x00) ? segmentR.sublist(1) : segmentR;
    final r = segmentR.toBigInt;

    final endSegment = signature.sublist(4 + signature.elementAt(3));
    assert(endSegment.first == DER_S_MARKER);
    var segmentS = endSegment.sublist(2);
    assert(endSegment.elementAt(1) == segmentS.length);
    assert(segmentS.first == 0x00 ? segmentS.elementAt(1) >= 0x80 : segmentS.elementAt(0) < 0x80);
    segmentS = (segmentS.elementAt(0) == 0x00) ? segmentS.sublist(1) : segmentS;
    final s = segmentS.toBigInt;

    return SignedHash(hash, r, s);
  }
}