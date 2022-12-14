// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:math';
import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:btc_sdk/src/model/bitcoin/english.dart';
import 'package:pointycastle/export.dart';

enum MnemonicType {
  short12Words(16),
  long24Words(32);

  final int bytes;

  const MnemonicType(this.bytes);
}

class HDWallet {

  static const int _SIZE_BYTE = 255;
  static final  Uint8List BITCOIN_SEED = "Bitcoin seed".toUint8ListFromUtf8;

  /// Generates a random number of either 16 or 32 bytes to be used to create the Mnemonic sentence.
  static Uint8List generateEntropy([MnemonicType mnemonicType = MnemonicType.long24Words]) {
    final rng = Random.secure();
    final bytes = Uint8List(mnemonicType.bytes);
    for (var i = 0; i < mnemonicType.bytes; i++) {
      bytes[i] = rng.nextInt(_SIZE_BYTE);
    }
    return bytes;
  }

  /// Given an entropy random value, this will generate an either 12 or 24 words mnemonic sentence used to
  /// deterministically generate a Seed value, used to create the Master Private Key.
  static String generateMnemonic([Uint8List? entropy, MnemonicType mnemonicType = MnemonicType.long24Words]) {
    entropy ??= generateEntropy(mnemonicType); // either 16 or 32 bytes => 128 bits / 256 bits
    final checksum = Hash.sha256(entropy).toBinaryString.substring(0, entropy.length ~/ 4); //take 1 bit each 32 bits (4 bytes)
    final extended = entropy.toBinaryString + checksum;
    String wordList = "";
    for(int i=0; i<extended.length ~/ 11; i++) {
      final wordIndex = int.parse(extended.substring(i * 11, i * 11 + 11), radix: 2);
      wordList += " " + WORDLIST_ENGLISH[wordIndex];
    }
    return wordList.trim();
  }

  /// Given a mnemonic and an optional passphrase a seed value of 64 bytes will be created in order to generate
  /// deterministically the Private Master Key
  ///
  /// The Seed is a 64 bytes value.
  static Uint8List generateSeedFromMnemonic(String mnemonic, {String passphrase = ""}) => Hash.pbkdf2(mnemonic, passphrase: passphrase);

  final Uint8List seed;
  final Uint8List masterPrivateKey;

  HDWallet(this.seed) : masterPrivateKey = Hash.hmacSHA512(BITCOIN_SEED, seed);

}