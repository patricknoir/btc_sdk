import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:btc_sdk/src/model/bitcoin/network.dart';
import 'package:btc_sdk/src/model/bitcoin/wif_private_key.dart';
import 'package:btc_sdk/src/model/crypto/hash.dart';
import 'package:elliptic/elliptic.dart' as elliptic;
import 'package:hex/hex.dart';

/// Contains the value of a valid private key for bitcoin wallets.
class PrivateKey {
  final Uint8List value = Uint8List(32);

  /// Create an instance of [PrivateKey] from a valid 32 bytes input.
  ///
  /// If the passed value is an array exceeding the 32 bytes, the most significant bytes will be truncated.
  PrivateKey(Uint8List value) {
    if(value.length >= 32) {
      this.value.setRange(0, 32, value.sublist(value.length - 32));
    } else {
      this.value.setRange(32 - value.length, 32, value);
    }
  }

  /// Create an instance of [PrivateKey] from a valid Hex representation of a 32 bytes array.
  ///
  /// If the hex is longer than 32 bytes the most significan bytes will me truncated.
  factory PrivateKey.parseHex(String hex) {
    final decoded = HEX.decode(hex);
    return PrivateKey(decoded.toUint8List);
  }

  /// Return a [Uint8List] representation for this key
  Uint8List get toUint8List => value;

  WifPrivateKey toWifPrivateKey(Network network, bool isCompressed) => WifPrivateKey(network, this.value, isCompressed);

  Uint8List getPublicKey() {
    final curve = elliptic.getSecp256k1();
    elliptic.PrivateKey epk = elliptic.PrivateKey.fromHex(curve, value.toUint8List.toHex);
    return epk.publicKey.toCompressedHex().fromHex!;
  }
}