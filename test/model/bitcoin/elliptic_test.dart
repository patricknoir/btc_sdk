import 'package:btc_sdk/src/model/bitcoin/elliptic.dart';
import 'package:test/test.dart';

void main() {
  group("elliptic maths", () {
    test("inverse", () {
      expect(Modulus.inverse(BigInt.from(13), p: BigInt.from(47)), BigInt.from(29));
    });

    test("multiply", () {
      BigInt prvKey = BigInt.parse("112757557418114203588093402336452206775565751179231977388358956335153294300646");
      BigIntPoint pubKey = EllipticCurve.secp256k1.multiply(prvKey);
      expect(pubKey.x, BigInt.parse("33886286099813419182054595252042348742146950914608322024530631065951421850289"));
      expect(pubKey.y, BigInt.parse("9529752953487881233694078263953407116222499632359298014255097182349749987176"));
    });
  });
}