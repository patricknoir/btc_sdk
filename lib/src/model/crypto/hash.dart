import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:btc_sdk/btc_sdk.dart';
import 'package:pointycastle/digests/ripemd160.dart';

class Hash {
  static Uint8List sha256(Uint8List input) => crypto.sha256.convert(input).bytes.toUint8List;
  static Uint8List checksum(Uint8List input) => sha256(sha256(input)).sublist(0, 4);
  static bool validateWif(String wif) {
    final input = wif.fromBase58;
    if(input != null) {
      final cs = input.sublist(input.length - 4, input.length);
      final extended = input.sublist(0, input.length - 4);
      return cs.toHex == checksum(extended).toHex;
    } else {
      return false;
    }
  }
  static Uint8List ripe160(Uint8List input) => RIPEMD160Digest().process(sha256(input));
}