# Public Key

A public key is a point in the elliptic curve obtained by the multiplication of the private key value
with the generator point of the curve adopted.

In cryptography the most used curve is the secp256k1 as discussed in the [EllipticCurves](base/EllipticCurves.md) page.

```dart
final curve = EllipticCurve.secp256k1;
final prvk = BigInt.parse('....');
BigIntPoint pubk = curve.multiply(prvk);
```

The public key is then defined by: 
- the BigIntPoint which represents the x and y coordinate in the elliptic curve.
- the EllipticCurve instance on which the public key is defined.

```dart
class PublicKey extends Equatable {
  final EllipticCurve curve;
  final BigIntPoint point;
  
  const PublicKey(this.curve, this.point);
  ...
}
```

## Public Key Representation

As discussed the public key is essentially a point `BigIntPoint` defined on a `EllipticCurve`.

However, a public key can have different representations:
- Uncompressed
- Compressed
- Hash

### Uncompressed

The uncompressed representation of a public key is defined by an array of bytes [Uint8List] with the following structure:
- 1 Byte flag: 0x04 to specify that the following bytes are the uncompressed encoding of the key.
- 32 Bytes containing the `point.x` coordinate of the public key
- 32 Bytes containing the `point.y` coordinate of the public key

```dart
class PublicKey extends Equatable {
  
  static const int UNCOMPRESSED_PREFIX = 0x04;

  final EllipticCurve curve;
  final BigIntPoint point;
  
  Uint8List get uncompressed => [UNCOMPRESSED_PREFIX].toUint8List.concat(point.x.toRadixString(16).toUint8ListFromHex!).concat(point.y.toRadixString(16).toUint8ListFromHex!);
  
}
```
This will make the public key long 65 bytes, to reduce its size the public key can be represented in a compressed format as described in the next section.

### Compressed

To reduce the size of a public key, a compressed representation has been introduced.
A characteristic of the elliptic curve is to be symmetric, for each value of `x` we have
2 possible `y` values, this is the reason that force us to serialize also the `y` coordinate of the public key.
However, there is an interesting property, for each `x` valid value, the associated `y1` and `y2` possible values
have a nice property:

> if `y1` is even then `y2` will be odd and viceversa.

Exploiting this property we can just serialize the `point.x` of the public key prefixed by a flag which has 2 possible values:
- `0x02`: this prefix will be used if the `point.y` of the public key is even
- `0x03`: this prefix will be used if the `point.y` of the public key is odd

Based on the above here it is the implementation of the compressed PublicKey serialization:

```dart
class PublicKey extends Equatable {

  static const int UNCOMPRESSED_PREFIX = 0x04;
  static const int COMPRESSED_EVEN_PREFIX = 0x02;
  static const int COMPRESSED_ODD_PREFIX = 0x03;

  final EllipticCurve curve;
  final BigIntPoint point;

  /// Return the [Hash.hash160] of the [PublicKey.compressed] representation. This is convenient because is smaller than the original [PublicKey].
  Uint8List get compressed =>
      ((point.y.isEven) ? 
      [COMPRESSED_EVEN_PREFIX] : [ COMPRESSED_ODD_PREFIX]).toUint8List.concat(point.x
          .toRadixString(16)
          .toUint8ListFromHex!);
}
```

This will make the total size of the uncompressed public key of 33 bytes:
- 1 byte for the odd/even flag
- 32 bytes for the `point.x` coordinate.

This can be further improved by hashing the compressed public key representation.

### Hash

Simply by hashing using `hash160` defined as: `RIPEMD160(SHA256(PublicKey.compressed))` we obtain a new bytes array of size 20 bytes.
This goes under the name of `Public Key Hash (PKH)` and is largely used to create wallet addresses in bitcoin's networks.

There are many derivation of the `PKH` which are at the base of the most common bitcoin wallet addresses, which will be covered under the [Bitcoin Address]() page.

```dart
/// Represent an instance of a [PublicKey] derived from the [SecretKey] by using the
/// [EllipticCurve] instance associated.
///
/// `PublicKey = curve.G * SecretKey`
///
class PublicKey extends Equatable {

  static const int UNCOMPRESSED_PREFIX = 0x04;
  static const int COMPRESSED_EVEN_PREFIX = 0x02;
  static const int COMPRESSED_ODD_PREFIX = 0x03;

  final EllipticCurve curve;
  final BigIntPoint point;

  /// Create a [PublicKey] instance from a [BigPoint] and an [EllipticCurve] instance.
  const PublicKey(this.curve, this.point);

  factory PublicKey.from(EllipticCurve curve, BigInt x, BigInt y) => PublicKey(curve, BigIntPoint(x: x, y: y));

  /// Serialize the `point.x` and `point.y` of the [PublicKey] prefixed by the [PublicKey.UNCOMPRESSED_PREFIX].
  Uint8List get uncompressed => [UNCOMPRESSED_PREFIX].toUint8List.concat(point.x.toRadixString(16).toUint8ListFromHex!).concat(point.y.toRadixString(16).toUint8ListFromHex!);
  /// The compressed [PublicKey] takes only the coordinate `point.x` of the [PublicKey] prefixed by [PublicKey.COMPRESSED_EVEN_PREFIX] if the
  /// coordinate `point.y` of the [PublicKey] is even, otherwise it uses the [PublicKey.COMPRESSED_ODD_PREFIX].
  Uint8List get compressed => ((point.y.isEven) ? [COMPRESSED_EVEN_PREFIX] : [ COMPRESSED_ODD_PREFIX]).toUint8List.concat(point.x.toRadixString(16).toUint8ListFromHex!);

  /// Return the [Hash.hash160] of the [PublicKey.compressed] representation. This is convenient because is smaller than the original [PublicKey].
  Uint8List get toPublicKeyHash => Hash.hash160(compressed);

  @override
  List<Object?> get props => [curve, point];
}
```
