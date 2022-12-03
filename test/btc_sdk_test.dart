import 'dart:typed_data';

import 'package:bip32/bip32.dart';
import 'package:btc_sdk/btc_sdk.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:btc_sdk/src/model/uint.dart';
import 'package:fast_base58/fast_base58.dart';
import 'package:hex/hex.dart';
import 'package:test/test.dart';
import 'package:btc_sdk/btc_sdk.dart';

void main() {
  group('A group of tests', () {
    final awesome = Awesome();

    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      expect(awesome.isAwesome, isTrue);
    });
  });

  group('btc_sdk tests', ()
  {

    final String myMnemonic = 'card file race stamp craft behave pulp achieve security grace leopard recall';

    setUp(() {
      // Additional setup goes here.
    });

    test('Uint8List data types', () {
      final Uint8List data = Uint8List.fromList([124, 8, 234, 156]);
      final int first = data[0];
      expect(first, 0x7C, reason: 'First byte is 0x7C = 124');
      int value4Bytes = data.buffer.asByteData().getInt32(0); // read the full Uint8List of length 4 as a Uint32 (4 bytes int value)
      expect(value4Bytes, 2080959132, reason: 'Read the full Uint8List of length 4 as an int32 value: 2080959132');
      expect(2080959132, 0x7C08EA9C, reason: "2080959132 can be represented as the concat of the [124 = 7C, 8 = 08, 234 = EA, 156 = 9C] in HEX 7C08EA9C");

      final String hexData = data.toHex;
      expect(hexData, '7C08EA9C'.toLowerCase());
      expect('7C08EA9C'.fromHex, [124, 8, 234, 156]);

      expect(hexData.fromHex, data);
      expect('hello'.fromHex, null, reason: 'An invalid HEX string should generate a null Uint8List');

      expect(data.toBase58, '4AtTej');
      expect('3yQ'.fromBase58?.buffer.asByteData().getInt16(0), 9999);

      final l1 = [128].toUint8List;
      final l2 = [64].toUint8List;
      final l3 = l1.concat(l2);
      expect(l3, [128, 64]);

      final l4 = l3.appendInt(33);
      expect(l4, [128, 64, 33]);

      final l0 = Uint8List(0);
      final l16 = l0?.appendInt(Uint.minUint16Value);
      expect(l16, [1, 0]);
      expect(l16?.toHex, '0100');
      final l32 = l0?.appendInt(Uint.minUint32Value);
      expect(l32, [0, 1, 0, 0]);
      expect(l32?.toHex, '00010000');
      final l64 = l0?.appendInt(Uint.minUint64Value);
      expect(l64, [0, 0, 0, 1, 0, 0, 0, 0]);
      expect(l64?.toHex, '0000000100000000');
    });

    test('base58 test', () {
      final Uint8List data = [124, 8, 234, 156].toUint8List;
      final base58Data = Base58Encode(data.toList(growable: false));
      expect(Base58Encode([0]), '1', reason: 'In Base58 the digit 0 is suppressed not to be confused with the capital O. Hence the value 0 is represented by the digit 1.');
      expect(Base58Encode([57]), 'z');
      expect(Base58Decode('3yQ').toUint8List.buffer.asByteData().getUint16(0), 9999);
    });


    test('bip39.generateMnemonic', () {
      final mnemonic = bip39.generateMnemonic();
      expect(mnemonic
          .split(' ').length,
          12,
          reason: mnemonic);
    });

    test('bip39 get the seed from a mnemonic', () {
      final Uint8List seed = bip39.mnemonicToSeed(myMnemonic);
      expect(seed.length, 64, reason: 'Seed length should be 64 byes');
      expect(seed.toHex, '0124541c3a08aab8dd25821fcead035a29ce61ec86378015603cebe36d9fb451fefdcf3f9db61472312f38fad8f430263db180023acc42218657caeb42dfe07b');
      expect(seed.toHex.length, seed.length * 2, reason: 'each Uint8 = 2 HEX Digits hence hex(seed).length = 2 * seed.length');
    });

    test('bip32', () {
      final BIP32 hd = BIP32.fromSeed(bip39.mnemonicToSeed(myMnemonic));
    });

  });

}
