import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:equatable/equatable.dart';

/// Represents an [Address] defined for a specific network in order to create lock [UTXO] on bitcoin transactions.
class Address extends Equatable {
  final Network network;
  final Uint8List hash;

  /// Create an instance of [Address] defined on a specific bitcoin [Network] and providing the [hash] for this key.
  const Address(this.network, this.hash);

  /// Create an instance of [Address] defined on a specific bitcoin [Netowrk] by providing a [PublicKey].
  ///
  /// This factory is mainly used for the creation of P2PKH Addresses.
  /// Optionally you can force the address to be generated from a compressed/uncompressed Publick Key Hash.
  factory Address.fromPublicKey(Network network, PublicKey publicKey, {bool compress = false}) {
    final pubKH = publicKey.toPublicKeyHash(compress: compress);
    return Address(network, pubKH);
  }

  /// Given a bitcoin string address, creates an instance of [Address].
  factory Address.fromString(String address) {
    final decoded = address.toUint8ListFromBase58!;
    final networkPrefix = decoded[0];
    final pubKH = decoded.sublist(1, decoded.length - 4).toUint8List;
    final checksum = decoded.sublist(decoded.length - 4).toUint8List;

    assert(Hash.checksum(networkPrefix.to8Bits().concat(pubKH)).compare(checksum));

    if(networkPrefix == Network.mainnet.p2pkh || networkPrefix == Network.mainnet.p2sh) {
      return Address(Network.mainnet, pubKH);
    } else if(networkPrefix == Network.testnet.p2pkh || networkPrefix == Network.testnet.p2sh) {
      return Address(Network.testnet, pubKH);
    } else {
      throw Exception('Invalid address network prefix');
    }
  }

  Uint8List get p2pkhUint8List {
    final extended = network.p2pkh.to8Bits().concat(hash);
    return extended.concat(Hash.checksum(extended));
  }

  String get p2pkhBase58 => p2pkhUint8List.toBase58;

  Uint8List get p2shUint8List {
    final extended = network.p2sh.to8Bits().concat(hash);
    return extended.concat(Hash.checksum(extended));
  }

  String get p2shBase58 => p2shUint8List.toBase58;

  @override
  List<Object?> get props => [network, hash.toHex];
}