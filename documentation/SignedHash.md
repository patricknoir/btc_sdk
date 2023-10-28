# Hash Signing

Signing a message, guarantees to the receiver that the content of the message has not been tempered and has been created by the owner of the `PrivateKey` associated to the `PublicKey` used to verify the signature.

## Signing

To sign a message you need three things:

- Random Number `k` — This introduces an element of randomness in to our signatures, which is important for security. It means that every signature we generate will be different, even if we sign the same message twice.
- Message Hash `z` — This is the hash of the message we want to sign. Hashing the message gives us a small and unique fingerprint for it, and it’s more efficient to sign this fingerprint than it is to sign a large blob of data. You have a choice of which hash algorithm to use, but the one most commonly used with `secp256k1` is `SHA-256`.
- Private Key `d` — The source of a public key (that we’ve made publicly available).

An actual signature is then made of two parts:

- `r` — A random point on the curve. We take the random number `k` and `multiply` it by the `generator` point to get a random point `R`. We only actually use the `x-coordinate` of this point, and we call this lowercase `r`.
- `s` — A number to accompany the random point. This is a unique number created from a combination of the message hash `z` and private key `d`, which is also bound to the random point using `r`.

```bash
z = hash(message)
R = k * G
r = R.x mod n 
s = k⁻¹ * (z + d * r) mod n
```

> The ⁻¹ notation indicates the modular inverse of that number. Here the modular multipicative inverse is found mod n (the number of points on the curve).

```dart
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
    while (nonce == null) {
      BigInt potentialNonce = _generateNonce();
      if (potentialNonce < prvKey.curve.n) {
        nonce = potentialNonce;
      }
    }

    // r = the x value of a random point on the curve
    final r = prvKey.curve
        .multiply(nonce)
        .x % prvKey.curve.n;

    // s = nonce⁻¹ * (hash + private_key * r) mod n
    final s = nonce.modInverse(prvKey.curve.n) * (hash.toBigInt + prvKey.value.toBigInt * r) % prvKey.curve.n;

    return SignedHash._(hash, r, s);
  }

  ...
}
```

## Verifying

Verify
You can verify a message and its signature with three things:

- Public Key `Q` — This is the public key for the person claiming to have created the signature.
- Message — The data that was signed. We can hash it ourselves to get the message hash `z`.
- Signature `[r, s]` — This is the signature created for the above message, allegedly created by the person who has the private key for the public key.

We then use these three pieces of data to calculate two points on the curve:

- **Point 1.** Start with the generator point `G`, and `multiply` it by `inverse(s) * z`.
- **Point 2.** Start with the public key point `Q`, and `multiply` it by `inverse(s) * r`.

We can now add these points together to give us Point 3:

`(s⁻¹ * z) * G + (s⁻¹ * r) * Q = R`

> **If this third point matches up with the random point given, the signature is valid.**

```dart
...
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
...
```