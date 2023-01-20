import 'dart:convert';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:test/test.dart';

void main() {
  group("signed_hash", ()
  {
    test('creation', () {
      final expectedR = BigInt.parse(
          '108607064596551879580190606910245687803607295064141551927605737287325610911759');
      final expectedS = BigInt.parse(
          '73791001770378044883749956175832052998232581925633570497458784569540878807131');

      final message = 'ECDSA is the most fun I have ever experienced';
      final hash = Hash.sha256(utf8
          .encode(message)
          .toUint8List);
      final nonce = BigInt.from(12345);
      final prvKey = PrivateKey.parseHex(BigInt.parse(
          '112757557418114203588093402336452206775565751179231977388358956335153294300646')
          .toRadixString(16));
      final signedHash = SignedHash.sign(hash, prvKey, nonce: nonce);
      expect(signedHash.r, expectedR);
      expect(signedHash.s, expectedS);
    });

    test('validate signature', () {
      final message = 'ECDSA is the most fun I have ever experienced';
      final hash = Hash.sha256(utf8
          .encode(message)
          .toUint8List);
      final nonce = BigInt.from(12345);
      final prvKey = PrivateKey.parseHex(BigInt.parse(
          '112757557418114203588093402336452206775565751179231977388358956335153294300646')
          .toRadixString(16));
      final signedHash = SignedHash.sign(hash, prvKey, nonce: nonce);

      expect(signedHash.verify(prvKey.publicKey), true);
      expect(signedHash.verify(PrivateKey
          .fromSeed("invalid key")
          .publicKey), false);
    });

    test('to DER', () {
      final derSig = '3046022100acd484e2f0c7f65309ad178a9f559abde09796974c57e714c35f110dfc27ccbe022100e6ee8efc7599012f5ac0933ab2686fbace9e4ee44c0ca49368249a3e663d5108'
          .toUint8ListFromHex!;
      final prvKey = PrivateKey.parseHex(
          'eec8fb5d3091e9fc2bf7c287f2f97cbf1100eeeb27fc8aaa650b314b71c7252');
      final pubKey = prvKey.publicKey;
      final message = utf8
          .encode('hello')
          .toUint8List;

      final sigHash = SignedHash.sign(message, prvKey, nonce: BigInt.from(9));

      expect(sigHash.toDER(), derSig);
      expect(sigHash.r.toRadixString(10), '78173298682877769088723994436027545680738210601369041078747105985693655485630');
      expect(sigHash.s.toRadixString(10), '104453451629840809757050217047625721329522324522833116900506572186093828788488');
    });

    test('from DER', () {
      final derSig = '3046022100acd484e2f0c7f65309ad178a9f559abde09796974c57e714c35f110dfc27ccbe022100e6ee8efc7599012f5ac0933ab2686fbace9e4ee44c0ca49368249a3e663d5108'
          .toUint8ListFromHex!;
      final prvKey = PrivateKey.parseHex(
          'eec8fb5d3091e9fc2bf7c287f2f97cbf1100eeeb27fc8aaa650b314b71c7252');
      final pubKey = prvKey.publicKey;
      final message = utf8
          .encode('hello')
          .toUint8List;

      final sigHash = SignedHash.fromDER(message, derSig);

      expect(sigHash.verify(pubKey), true);
      expect(sigHash.r.toRadixString(10), '78173298682877769088723994436027545680738210601369041078747105985693655485630');
      expect(sigHash.s.toRadixString(10), '104453451629840809757050217047625721329522324522833116900506572186093828788488');
    });

    test('OP_CHECKSIG', () {
      final trxHash = 'a6b4103f527dfe43dfbadf530c247bac8a98b7463c7c6ad38eed97021d18ffcb'.toUint8ListFromHex!;
      final sigScript = '3044022008f4f37e2d8f74e18c1b8fde2374d5f28402fb8ab7fd1cc5b786aa40851a70cb02201f40afd1627798ee8529095ca4b205498032315240ac322c9d8ff0f205a93a5801'.toUint8ListFromHex!;
      final publicKey = PublicKey.fromSEC(EllipticCurve.secp256k1, '024aeaf55040fa16de37303d13ca1dde85f4ca9baa36e2963a27a1c0c1165fe2b1'.toUint8ListFromHex!);

      final sigDer = sigScript.sublist(0, sigScript.length - 1);
      final signedHash = SignedHash.fromDER(trxHash, sigDer);

      expect(signedHash.verify(publicKey), true);
    });

  });
}