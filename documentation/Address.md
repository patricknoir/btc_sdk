# Address

An address is what you give to people so that they can “send” you bitcoins.

When someone receives it, they can create a specific **locking script** based on the type of address you have given them.

In general, an address contains:

Some specific data that you would like included in the lock. For example, your public key hash.
- A prefix to indicate what kind of lock to create.
- And a checksum to help with catching any typos.

Finally, all of that gets converted to Base58, which makes it a little more user-friendly.

There are different kind of addresses used for different purposes, in the following section we will be
analizing the 2 most commonly used:

- Pay To PubKey Hash (P2PKH)
- P2SH

```dart 
class Address extends Equatable {
  final Network network;
  final Uint8List hash;

  const Address(this.network, this.hash);

  factory Address.fromPublicKey(Network network, PublicKey publicKey, {bool compress = false}) {
    final pubKH = publicKey.toPublicKeyHash(compress: compress);
    return Address(network, pubKH);
  }
  
  ...
  
}
```

## Pay To PubKey Hash (P2PKH)

This is a typical address that locks bitcoins to a public key (or to be more precise: the public key hash).

As mentioned, we prepend a prefix depending on the network and append a checksum to our hashed public key, then encode it all in base58.

```
<P2PKH Address> = <P2PKH Network Prefix> <Public Key Hash> <Checksum>
```

- P2PKH for Mainnet Netowrk: `0x00`
- P2PKH for Testnet Netowrk: `0x6F`

```dart
class Address extends Equatable {
  final Network network;
  final Uint8List hash;
  ...

  Uint8List get p2pkhUint8List {
  final extended = network.p2pkh.to8Bits().concat(hash);
  return extended.concat(Hash.checksum(extended));
  }

  String get p2pkhBase58 => p2pkhUint8List.toBase58;

  ...
}
```

## Pay To Script Hash (P2SH)

This lock includes the hash of a script. We provide the actual locking script later on (when we come to unlock it), which allows us to construct complex locking scripts without others having to worry about the details of it.

Same as before, except this time we’re including the hash of a script, and using the prefix 05 to indicate a P2SH.

```
<P2SH Address> = <P2SH Network Prefix> <Script Hash> <Checksum>
```

- P2SH for Mainnet Netowrk: `0x05`
- P2SH for Testnet Netowrk: `0xC4`

```dart
class Address extends Equatable {
  final Network network;
  final Uint8List hash;
  ...

  Uint8List get p2shUint8List {
    final extended = network.p2sh.to8Bits().concat(hash);
    return extended.concat(Hash.checksum(extended));
  }

  String get p2shBase58 => p2shUint8List.toBase58;

  ...
}
```