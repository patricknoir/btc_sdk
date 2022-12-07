// ignore_for_file: constant_identifier_names

import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:fast_base58/fast_base58.dart';

/// Wallet Import Format PrivateKey
///
/// WIF PrivateKey are used to be exported/imported from/to non custodial wallets.
/// They are specific for a bitcoin [Network] and they can be used to generate compressed/uncompressed public keys
class WifPrivateKey extends PrivateKey {
  static const int COMPRESSION_BYTE = 0x01;

  static const int WIF_UNCOMPRESSED_PRIVATE_KEY_LENGTH = 1 + 32 + 4;// 1 Byte Network Flag + 32 Bytes Private Key Value + 4 Bytes CHECKSUM
  static const int WIF_COMPRESSED_PRIVATE_KEY_LENGTH = WIF_UNCOMPRESSED_PRIVATE_KEY_LENGTH + 1; // PLUS 1 Byte COMPRESSED FLAG

  final Network network;
  final bool isCompressed;

  WifPrivateKey(this.network, Uint8List value, this.isCompressed, {EllipticCurve? curve}) : super(value, curve: curve);

  factory WifPrivateKey.parseBase58Check(String wifPVKH, {EllipticCurve? curve}) {
    final decoded = wifPVKH.toUint8ListFromBase58!;
    final network = Network.fromPrefix(decoded[0]);
    final isCompressed = (decoded.length == WIF_COMPRESSED_PRIVATE_KEY_LENGTH);
    final value = decoded.sublist(1, decoded.length - 4 - (isCompressed ? 1 : 0));

    final checksum = decoded.sublist(decoded.length - 4, decoded.length).toUint8List;
    assert(checksum.compare(Hash.checksum(decoded.sublist(0, decoded.length - 4).toUint8List)));

    return WifPrivateKey(network, value, isCompressed, curve: curve);
  }

  /// Return the [PrivateKey] in the WIF Compressed/Uncompressed (Wallet Import Format) for a specific bitcoin [Network].
  String get toWif {
    Uint8List extended = network.prefix.to8Bits().concat(value);
    if(isCompressed) {
      extended = extended.concat([COMPRESSION_BYTE].toUint8List);
    }
    Uint8List checksum = Hash.checksum(extended);
    return extended.concat(checksum).toBase58;
  }

  @override
  List<Object?> get props => [network, value, curve, isCompressed];
}