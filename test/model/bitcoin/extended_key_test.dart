import 'package:btc_sdk/btc_sdk.dart';
import 'package:btc_sdk/src/model/bitcoin/extended_private_key.dart';
import 'package:test/test.dart';

void main() {
  group('extended private key', () {
    test('creation', () {
      final seed = '67f93560761e20617de26e0cb84f7234aaf373ed2e66295c3d7397e6d7ebe882ea396d5d293808b0defd7edd2babd4c091ad942e6a9351e6d075a29d4df872af'.toUint8ListFromHex!;
      final extendedPrivateKey = ExtendedPrivateKey.masterKey(seed);

      expect(extendedPrivateKey.parentPath, null);
      expect(extendedPrivateKey.path, ExtendedPrivateKey.PATH_MASTER_PRIVATE);
      expect(extendedPrivateKey.index, 0);
      expect(extendedPrivateKey.chainCode.toHex, '463223aac10fb13f291a1bc76bc26003d98da661cb76df61e750c139826dea8b');
      expect(extendedPrivateKey.value.toHex, 'f79bb0d317b310b261a55a8ab393b4c8a1aba6fa4d08aef379caba502d5d67f9');
      expect(extendedPrivateKey.publicKey.compressed.toHex, '0252c616d91a2488c1fd1f0f172e98f7d1f6e51f8f389b2f8d632a8b490d5f6da9');
    });

    test('derive normal child', () {
      final parentPrivateKey = ExtendedPrivateKey(
          '463223aac10fb13f291a1bc76bc26003d98da661cb76df61e750c139826dea8b'.toUint8ListFromHex!,
          'f79bb0d317b310b261a55a8ab393b4c8a1aba6fa4d08aef379caba502d5d67f9'.toUint8ListFromHex!);

      final childPrivateKey = parentPrivateKey.normalChild();

      expect(childPrivateKey.parentPath, ExtendedPrivateKey.PATH_MASTER_PRIVATE);
      expect(childPrivateKey.path, ExtendedPrivateKey.PATH_MASTER_PRIVATE + "/0");
      expect(childPrivateKey.index, 0);
      expect(childPrivateKey.chainCode.toHex, '05aae71d7c080474efaab01fa79e96f4c6cfe243237780b0df4bc36106228e31');
      expect(childPrivateKey.value.toHex, '39f329fedba2a68e2a804fcd9aeea4104ace9080212a52ce8b52c1fb89850c72');
      expect(childPrivateKey.publicKey.compressed.toHex, '030204d3503024160e8303c0042930ea92a9d671de9aa139c1867353f6b6664e59');
    });

    test('derive hardened child', () {
      final parentPrivateKey = ExtendedPrivateKey(
          '463223aac10fb13f291a1bc76bc26003d98da661cb76df61e750c139826dea8b'.toUint8ListFromHex!,
          'f79bb0d317b310b261a55a8ab393b4c8a1aba6fa4d08aef379caba502d5d67f9'.toUint8ListFromHex!);

      final childPrivateKey = parentPrivateKey.deriveKey(index: 2147483648);

      expect(childPrivateKey.parentPath, ExtendedPrivateKey.PATH_MASTER_PRIVATE);
      expect(childPrivateKey.path, ExtendedPrivateKey.PATH_MASTER_PRIVATE + "/2147483648");
      expect(childPrivateKey.index, 2147483648);
      expect(childPrivateKey.chainCode.toHex, 'cb3c17166cc30eb7fdd11993fb7307531372e565cd7c7136cbfa4655622bc2be');
      expect(childPrivateKey.value.toHex, '7272904512add56fef94c7b4cfc62bedd0632afbad680f2eb404e95f2d84cbfa');
      expect(() => childPrivateKey.publicKey, throwsException); // cannot generate a public key from and hardened private key!
      // expect(childPrivateKey.publicKey.compressed.toHex, '0355cff4a963ce259b08be9a864564caca210eb4eb35fcb75712e4bba7550efd95');
    });
  });
}