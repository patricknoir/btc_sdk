import 'dart:convert';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:test/test.dart';

void main() {
  group("signed_hash", () {
    test('creation', () {
      final expectedR = BigInt.parse('108607064596551879580190606910245687803607295064141551927605737287325610911759');
      final expectedS = BigInt.parse('73791001770378044883749956175832052998232581925633570497458784569540878807131');

      final message = 'ECDSA is the most fun I have ever experienced';
      final hash = Hash.sha256(utf8.encode(message).toUint8List);
      final nonce = BigInt.from(12345);
      final prvKey = PrivateKey.parseHex(BigInt.parse('112757557418114203588093402336452206775565751179231977388358956335153294300646').toRadixString(16));
      final signedHash = SignedHash.sign(hash, prvKey, nonce: nonce);
      expect(signedHash.r, expectedR);
      expect(signedHash.s, expectedS);
    });
    
    test('validate signature', () {
      final message = 'ECDSA is the most fun I have ever experienced';
      final hash = Hash.sha256(utf8.encode(message).toUint8List);
      final nonce = BigInt.from(12345);
      final prvKey = PrivateKey.parseHex(BigInt.parse('112757557418114203588093402336452206775565751179231977388358956335153294300646').toRadixString(16));
      final signedHash = SignedHash.sign(hash, prvKey, nonce: nonce);
      
      expect(signedHash.verify(prvKey.publicKey), true);
      expect(signedHash.verify(PrivateKey.fromSeed("invalid key").publicKey), false);
    });
  });
}