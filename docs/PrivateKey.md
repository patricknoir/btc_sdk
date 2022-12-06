# Private Key

A private key is a random number. It is a 256 bits (32 Bytes = Uint32) number.

It is used as the source of a public key.

> **A private key can be almost any 256-bit number.**
>
> When you create a public key, your private key is put through a special mathematical function, and this function can only handle numbers up to just below 256 bits. The maximum value is:
>
> ```bash
> max = 115792089237316195423570985008687907852837564279074904382605163141518161494336
> ```
>
> This number is n-1, where n is the number of points on the elliptic curve used in Bitcoin. So when you generate a 256 bit number, you will want to check that it’s not above this maximum value.

## Formats

A hexadecimal private key is 32 bytes (64 characters):

```bash
ef235aacf90d9f4aadd8c92e4b2562e1d9eb97f0df9ba3b508258739cb013db2
```
However, you can convert your private key to a **WIF Private Key**, which basically makes it easier to copy and import in to wallets.

## WIF Private Key

A private key can be converted in to a “Wallet Import Format”, which basically makes it easier to copy and move around (because it’s shorter and contains a checksum for detecting errors).

A WIF private key is a standard private key, but with a few added extras:

1. Version Byte prefix - Indicates which network the private key is to be used on.
    - 0x80 = Mainnet
    - 0xEF = Testnet
2. Compression Byte suffix (optional) - Indicates if the private key is used to create a compressed public key.
    - 0x01
3. [Checksum](Checksum.md) - Useful for detecting errors/typos when you type out your private key.

This is all then converted to Base58, which shortens the entire thing and makes it easier to transcribe…

## Generating the PublicKey

When you multiply the `PrivateKey.value` by the generator `BigIntPoint` `curve.G` of the `EllipticCurve` instance used,
you obtain a new `BigIntPoint` in the curve: this point is your `PublicKey`.

i.e.:
```dart
PrivateKey prvKey = PrivateKey.fromSeed('hello');
PublicKey pubKey = EllipticCurve.secp256k1.G * prvKey;

expect(prvKey.toUint8List.toHex, '2CF24DBA5FB0A30E26E83B2AC5B9E29E1B161E5C1FA7425E73043362938B9824'.toLowerCase());

```

Fore more details check the [Public Key](PublicKey.md) documentation.