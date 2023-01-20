import 'package:btc_sdk/btc_sdk.dart';
import 'package:test/test.dart';

void main() {
  group('public key', () {
    test('creation', () {
      PrivateKey prvKey = PrivateKey.parseHex('ef235aacf90d9f4aadd8c92e4b2562e1d9eb97f0df9ba3b508258739cb013db2');
      PublicKey pubKey = prvKey.publicKey;

      final hexX = 'b4632d08485ff1df2db55b9dafd23347d1c47a457072a1e87be26896549a8737';
      final hexY = '8ec38ff91d43e8c2092ebda601780485263da089465619e0358a5c1be7ac91f4';
      final expectedPoint = BigIntPoint(
        x: hexX.toUint8ListFromHex!.toBigInt,
        y: hexY.toUint8ListFromHex!.toBigInt
      );

      expect(pubKey.point, expectedPoint);
      expect(pubKey.uncompressed.toHex, '04' + hexX + hexY);
      expect(pubKey.compressed.toHex, '02' + hexX);
      expect(pubKey.toPublicKeyHash(compress: true), Hash.hash160(pubKey.compressed));
    });

    test('fromSEC Uncompressed', () {
      PrivateKey prvKey = PrivateKey.parseHex('ef235aacf90d9f4aadd8c92e4b2562e1d9eb97f0df9ba3b508258739cb013db2');
      PublicKey referencePublicKey = prvKey.publicKey;
      final secUncompressed = '04b4632d08485ff1df2db55b9dafd23347d1c47a457072a1e87be26896549a87378ec38ff91d43e8c2092ebda601780485263da089465619e0358a5c1be7ac91f4'.toUint8ListFromHex!;

      final pubKey = PublicKey.fromSEC(EllipticCurve.secp256k1, secUncompressed);
      expect(pubKey.point, referencePublicKey.point);
    });

    test('fromSEC Compressed [EVEN]', () {
      PrivateKey prvKey = PrivateKey.parseHex('ef235aacf90d9f4aadd8c92e4b2562e1d9eb97f0df9ba3b508258739cb013db2');
      PublicKey referencePublicKey = prvKey.publicKey;
      final secCompressed = '02b4632d08485ff1df2db55b9dafd23347d1c47a457072a1e87be26896549a8737'.toUint8ListFromHex!;

      final pubKey = PublicKey.fromSEC(EllipticCurve.secp256k1, secCompressed);
      expect(pubKey.point, referencePublicKey.point);
    });

    test('fromSEC Uncompressed', () {
      PrivateKey prvKey = PrivateKey.parseHex('ef235aacf90d9f4aadd8c92e4b2562e1d9eb97f0df9ba3b508258739cb013db2');
      PublicKey referencePublicKey = prvKey.publicKey;
      final secUncompressed = '04b4632d08485ff1df2db55b9dafd23347d1c47a457072a1e87be26896549a87378ec38ff91d43e8c2092ebda601780485263da089465619e0358a5c1be7ac91f4'.toUint8ListFromHex!;

      final pubKey = PublicKey.fromSEC(EllipticCurve.secp256k1, secUncompressed);
      expect(pubKey.point, referencePublicKey.point);
    });

    test('fromSEC Compressed [ODD]', () {
      PrivateKey prvKey = PrivateKey.parseHex('2CF24DBA5FB0A30E26E83B2AC5B9E29E1B161E5C1FA7425E73043362938B9824');
      PublicKey referencePublicKey = prvKey.publicKey;
      final secCompressed = '0387D82042D93447008DFE2AF762068A1E53FF394A5BF8F68A045FA642B99EA5D1'.toUint8ListFromHex!;

      final pubKey = PublicKey.fromSEC(EllipticCurve.secp256k1, secCompressed);
      expect(pubKey.point, referencePublicKey.point);
    });
  });
}