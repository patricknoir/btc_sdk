import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';

/// Wallet Import Format PrivateKey
///
/// WIF PrivateKey are used to be exported/imported from/to non custodial wallets.
/// They are specific for a bitcoin [Network] and they can be used to generate compressed/uncompressed public keys
class WifPrivateKey extends PrivateKey {
  // ignore: constant_identifier_names
  static const int COMPRESSION_BYTE = 0x01;

  final Network network;
  final bool isCompressed;

  WifPrivateKey(this.network, Uint8List value, this.isCompressed) : super(value);

  /// Return the [PrivateKey] in the WIF Compressed/Uncompressed (Wallet Inport Format) for a specific bitcoin [Network].
  String get toWif {
    Uint8List extended = network.prefix.to8Bits().concat(value);
    if(isCompressed) {
      extended = extended.concat([COMPRESSION_BYTE].toUint8List);
    }
    Uint8List checksum = Hash.checksum(extended);
    return extended.concat(checksum).toBase58;
  }


}