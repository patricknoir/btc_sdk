import 'package:btc_sdk/btc_sdk.dart';
import 'package:btc_sdk/src/model/bitcoin/network.dart';
import 'package:btc_sdk/src/model/bitcoin/private_key.dart';
import 'package:btc_sdk/src/model/crypto/hash.dart';
import 'package:test/test.dart';

void main() {
  group('PrivateKey', () {
    test('creation from Uint8List', () {
      PrivateKey pk1 = PrivateKey([1].toUint8List);
      expect(pk1.toUint8List.length, 32);
      expect(pk1.toUint8List, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]);

      final data64 = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1].toUint8List;
      PrivateKey pk2 = PrivateKey(data64);
      expect(pk2.toUint8List.length, 32);
      expect(pk2.toUint8List, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]);
    });

    test('creation from Hex', () {
      PrivateKey pk1 = PrivateKey.parseHex('1');
      expect(pk1.toUint8List.length, 32);
      expect(pk1.toUint8List, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]);

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
      PrivateKey prvk = PrivateKey.parseHex('ef235aacf90d9f4aadd8c92e4b2562e1d9eb97f0df9ba3b508258739cb013db2');
      expect(prvk.publicKey.compressed.toHex, '02b4632d08485ff1df2db55b9dafd23347d1c47a457072a1e87be26896549a8737');
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