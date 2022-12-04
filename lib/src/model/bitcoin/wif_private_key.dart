import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:btc_sdk/src/model/bitcoin/network.dart';
import 'package:btc_sdk/src/model/bitcoin/private_key.dart';

import '../crypto/hash.dart';

class WifPrivateKey extends PrivateKey {
  final Network network;
  final bool isCompressed;

  WifPrivateKey(this.network, Uint8List value, this.isCompressed) : super(value);

  /// Return the [PrivateKey] in the WIF Compressed/Uncompressed (Wallet Inport Format) for a specific bitcoin [Network].
  String get toWif {
    Uint8List extended = network.prefix.to8Bits().concat(value);
    if(isCompressed) {
      extended = extended.concat([0x01].toUint8List);
    }
    Uint8List checksum = Hash.checksum(extended);
    return extended.concat(checksum).toBase58;
  }


}