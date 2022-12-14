import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:btc_sdk/btc_sdk.dart';
import 'package:pointycastle/export.dart';

class Hash {
  static Uint8List sha256(Uint8List input) => crypto.sha256.convert(input).bytes.toUint8List;
  static Uint8List checksum(Uint8List input) => sha256(sha256(input)).sublist(0, 4);
  static bool validateWif(String wif) {
    final input = wif.toUint8ListFromBase58;
    if(input != null) {
      final cs = input.sublist(input.length - 4, input.length);
      final extended = input.sublist(0, input.length - 4);
      return cs.toHex == checksum(extended).toHex;
    } else {
      return false;
    }
  }
  static Uint8List hash160(Uint8List input) => RIPEMD160Digest().process(sha256(input));

  static final _pbkdf2 = PBKDF2();

  static Uint8List pbkdf2(String mnemonic, {String passphrase = ""}) => _pbkdf2.process(mnemonic, passphrase: passphrase);

  static Uint8List hmacSHA512(Uint8List key,Uint8List data) {
    final _tmp = HMac(SHA512Digest(), 128)..init(KeyParameter(key));
    return _tmp.process(data);
  }
}

class PBKDF2 {
  final int blockLength;
  final int iterationCount;
  final int desiredKeyLength;
  final String saltPrefix = "mnemonic";

  final PBKDF2KeyDerivator _derivator;

  PBKDF2({
    this.blockLength = 128,
    this.iterationCount = 2048,
    this.desiredKeyLength = 64,
  }) : _derivator = PBKDF2KeyDerivator(HMac(SHA512Digest(), blockLength));

  Uint8List process(String mnemonic, {String passphrase = ""}) {
    final salt = Uint8List.fromList(utf8.encode(saltPrefix + passphrase));
    _derivator.reset();
    _derivator
        .init(Pbkdf2Parameters(salt, iterationCount, desiredKeyLength));
    return _derivator.process(Uint8List.fromList(mnemonic.codeUnits));
  }
}