import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:btc_sdk/src/model/crypto/private_key.dart';
import 'package:btc_sdk/src/model/crypto/hash.dart';
import 'package:test/test.dart';

void main() {
  group('hash tests', () {
    test('sha256', () {
      final hashed = Hash.sha256(Uint(0xF7700088).toUint8List);
      expect(hashed.toHex, '931b9509cc23031f8b433d16768ccf2bbf28542dc8d1aa5d989220f5951e8d65');
    });

    test('checksum', () {
      PrivateKey privateKey = PrivateKey.parseHex('2CF24DBA5FB0A30E26E83B2AC5B9E29E1B161E5C1FA7425E73043362938B9824');
      expect(privateKey.toUint8List.toHex, '2CF24DBA5FB0A30E26E83B2AC5B9E29E1B161E5C1FA7425E73043362938B9824'.toLowerCase());
      Uint8List extended = [0x80].toUint8List.concat(privateKey.toUint8List).concat([0x01].toUint8List);
      final checksum = Hash.checksum(extended);
      expect(checksum.toHex, 'F29E9187'.toLowerCase());
      final wifPK = extended.concat(checksum).toBase58;
      expect(wifPK, 'Kxj5ejwPg2s2ejZHW7N1zAydD4fkmFi9j19QRmgeVK9mXL3wFMmp');
    });

    test('validateWif', () {
      expect(Hash.validateWif('Kxj5ejwPg2s2ejZHW7N1zAydD4fkmFi9j19QRmgeVK9mXL3wFMmp'), true);
      expect(Hash.validateWif('Kxj5ejwPg2s2ejZHW7N1zAydD4fkmFi9j19QRmgeVK9mXL3wXXXX'), false);
    });
  });
}