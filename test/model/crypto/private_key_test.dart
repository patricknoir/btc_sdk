import 'package:btc_sdk/btc_sdk.dart';
import 'package:test/test.dart';

void main() {
  group('PrivateKey', () {
    test('creation from Uint8List', () {
      PrivateKey pk1 = PrivateKey([1].toUint8List);
      expect(pk1.toUint8List.length, 32);
      expect(pk1.toUint8List, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]);

      // The input Uint8List of 64 bytes should be truncated to the lower 32 bits, the outcome of using data64 to generate pk2 should be the same as pk1.
      final data64 = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1].toUint8List;
      PrivateKey pk2 = PrivateKey(data64);
      expect(pk2.toUint8List.length, 32);
      expect(pk2.toUint8List, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]);
    });

    test('creation from Hex', () {
      PrivateKey pk1 = PrivateKey.parseHex('1');
      expect(pk1.toUint8List.length, 32);
      expect(pk1.toUint8List, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]);

      // As the HEX representation is bigger than 32 bytes, the hex number will be truncated containing the lowest 32 bytes, as an outcome pk2 will be equivalent to pk1
      PrivateKey pk2 = PrivateKey.parseHex('ffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000001');
      expect(pk2.toUint8List.length, 32);
      expect(pk2.toUint8List, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]);
    });

    test('creation from seed', () {
      PrivateKey prvKey = PrivateKey.fromSeed('hello');
      expect(prvKey.toUint8List.toHex, '2CF24DBA5FB0A30E26E83B2AC5B9E29E1B161E5C1FA7425E73043362938B9824'.toLowerCase());
    });

    test('export to wif compressed for mainnet', () {
      PrivateKey pk = PrivateKey.parseHex('2CF24DBA5FB0A30E26E83B2AC5B9E29E1B161E5C1FA7425E73043362938B9824');
      expect(pk.toWifPrivateKey(Network.mainnet, true).toWif, 'Kxj5ejwPg2s2ejZHW7N1zAydD4fkmFi9j19QRmgeVK9mXL3wFMmp');
    });

    test('generate public key', () {
      final expectedX = '87D82042D93447008DFE2AF762068A1E53FF394A5BF8F68A045FA642B99EA5D1'.toLowerCase();
      final expectedY = '53F577DD2DBA6C7AE4CFD7B6622409D7EDD2D76DD13A8092CD3AF97B77BD2C77'.toLowerCase();
      PrivateKey prvKey = PrivateKey.fromSeed('hello');
      expect(prvKey.toUint8List.toHex, '2CF24DBA5FB0A30E26E83B2AC5B9E29E1B161E5C1FA7425E73043362938B9824'.toLowerCase());

      PublicKey pubKey = prvKey.publicKey;
      expect(pubKey.point.x.toRadixString(16), expectedX);
      expect(pubKey.point.y.toRadixString(16), expectedY);

      expect(pubKey.uncompressed.toHex, "04" + expectedX + expectedY);
      expect(pubKey.compressed.toHex, "03" + expectedX);
    });

    test('generate p2pkh address for mainnet from the private key', () {
      PrivateKey pk = PrivateKey.parseHex('2CF24DBA5FB0A30E26E83B2AC5B9E29E1B161E5C1FA7425E73043362938B9824');
      expect(pk.toWifPrivateKey(Network.mainnet, true).toWif, 'Kxj5ejwPg2s2ejZHW7N1zAydD4fkmFi9j19QRmgeVK9mXL3wFMmp');

      expect(pk.publicKey.compressed.toHex, '0387D82042D93447008DFE2AF762068A1E53FF394A5BF8F68A045FA642B99EA5D1'.toLowerCase());
      final extPubKey = Hash.hash160(pk.publicKey.compressed);
      expect(extPubKey.toHex, 'E3DD7E774A1272AEDDB18EFDC4BAF6E14990EDAA'.toLowerCase());
      final p2pkhPrefix = [0x00].toUint8List;
      final pubk = p2pkhPrefix.concat(extPubKey).concat(Hash.checksum(p2pkhPrefix.concat(extPubKey)));
      expect(pubk.toHex, '00E3DD7E774A1272AEDDB18EFDC4BAF6E14990EDAA79BC2527'.toLowerCase());
      expect(pubk.toBase58, '1MmqjDhakEfJd9r5BoDhPApCpA75Em17GA');
    });
  });
}