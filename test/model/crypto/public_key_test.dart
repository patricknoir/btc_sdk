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
  });
}