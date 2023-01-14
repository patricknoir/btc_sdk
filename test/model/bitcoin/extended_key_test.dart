import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';
import 'package:btc_sdk/src/model/bitcoin/extended_private_key.dart';
import 'package:btc_sdk/src/model/bitcoin/extended_public_key.dart';
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

      // print(extendedPrivateKey.serialize);
    });

    test('derive normal child', () {
      final parentPrivateKey = ExtendedPrivateKey(
          '463223aac10fb13f291a1bc76bc26003d98da661cb76df61e750c139826dea8b'.toUint8ListFromHex!,
          'f79bb0d317b310b261a55a8ab393b4c8a1aba6fa4d08aef379caba502d5d67f9'.toUint8ListFromHex!);

      expect(parentPrivateKey.publicKey.compressed.toHex, '0252c616d91a2488c1fd1f0f172e98f7d1f6e51f8f389b2f8d632a8b490d5f6da9');

      final childPrivateKey = parentPrivateKey.normalChild();

      expect(childPrivateKey.parentPath, ExtendedPrivateKey.PATH_MASTER_PRIVATE);
      expect(childPrivateKey.path, ExtendedPrivateKey.PATH_MASTER_PRIVATE + "/0");
      expect(childPrivateKey.index, 0);
      expect(childPrivateKey.chainCode.toHex, '05aae71d7c080474efaab01fa79e96f4c6cfe243237780b0df4bc36106228e31');
      expect(childPrivateKey.value.toHex, '39f329fedba2a68e2a804fcd9aeea4104ace9080212a52ce8b52c1fb89850c72');
      expect(childPrivateKey.publicKey.compressed.toHex, '030204d3503024160e8303c0042930ea92a9d671de9aa139c1867353f6b6664e59');

      expect(childPrivateKey.serialize, 'xprv9tuogRdb5YTgcL3P8Waj7REqDuQx4sXcodQaWTtEVFEp6yRKh1CjrWfXChnhgHeLDuXxo2auDZegMiVMGGxwxcrb2PmiGyCngLxvLeGsZRq');
    });

    test('derive hardened child', () {
      final parentPrivateKey = ExtendedPrivateKey(
          '463223aac10fb13f291a1bc76bc26003d98da661cb76df61e750c139826dea8b'.toUint8ListFromHex!,
          'f79bb0d317b310b261a55a8ab393b4c8a1aba6fa4d08aef379caba502d5d67f9'.toUint8ListFromHex!);

      final childPrivateKey = parentPrivateKey.deriveKey(hardened: true);

      expect(childPrivateKey.parentPath, ExtendedPrivateKey.PATH_MASTER_PRIVATE);
      expect(childPrivateKey.path, ExtendedPrivateKey.PATH_MASTER_PRIVATE + "/0'");
      expect(childPrivateKey.index, 2147483648);
      expect(childPrivateKey.chainCode.toHex, 'cb3c17166cc30eb7fdd11993fb7307531372e565cd7c7136cbfa4655622bc2be');
      expect(childPrivateKey.value.toHex, '7272904512add56fef94c7b4cfc62bedd0632afbad680f2eb404e95f2d84cbfa');
      // expect(() => childPrivateKey.publicKey, throwsException); // cannot generate a public key from and hardened private key!
      expect(childPrivateKey.publicKey.compressed.toHex, '0355cff4a963ce259b08be9a864564caca210eb4eb35fcb75712e4bba7550efd95');
    });

    test('testing private key hardened derivation', () {
      final masterPrivKey = ExtendedPrivateKey.masterKey("b1680c7a6ea6ed5ac9bf3bc3b43869a4c77098e60195bae51a94159333820e125c3409b8c8d74b4489f28ce71b06799b1126c1d9620767c2dadf642cf787cf36".toUint8ListFromHex!);

      expect(masterPrivKey.toUint8List.toHex, "081549973bafbba825b31bcc402a3c4ed8e3185c2f3a31c75e55f423e9629aa3");
      expect(masterPrivKey.chainCode.toHex, "1d7d2a4c940be028b945302ad79dd2ce2afe5ed55e1a2937a5af57f8401e73dd");

      final child0 = masterPrivKey.hardenedChild(ExtendedPrivateKey.PRIVATE_KEY_HARDENED_MIN_INDEX);
      expect(child0.toUint8List.toHex, "0397654f8c58215da8575e495345912bd0d23545cf0017505ab6b6ae1a97eedb");
      expect(child0.publicKey.compressed.toHex, "021fa96c781e4ba8a11eb6fb8a7bd3f996ad0d6461fb403b0f389605c6f35c2620");
      expect(child0.path, "m/0'");

      final child1 = masterPrivKey.hardenedChild(ExtendedPrivateKey.PRIVATE_KEY_HARDENED_MIN_INDEX + 1);
      expect(child1.toUint8List.toHex, "38512d738064f282d7620205815fa1208258bf031dbf5b6e5887cc3dacf7ae1d");
      expect(child1.publicKey.compressed.toHex, "03073e48507140bb0e57dd4008db386f554d13a8641f7e55426419af4ba71fa3eb");
      expect(child1.path, "m/1'");

      final child2 = masterPrivKey.hardenedChild(ExtendedPrivateKey.PRIVATE_KEY_HARDENED_MIN_INDEX + 2);
      expect(child2.toUint8List.toHex, "590bfef4b951854f60e90eb24e7c690ac70165eb959b3296c3f51cb5a8a6401f");
      expect(child2.publicKey.compressed.toHex, "021b323b81b998340368d8fe11496922295cbae6fcd4b8d495f2c4755cd2279d1d");
      expect(child2.path, "m/2'");
    });

    test('testing HD derivation constraints', () {
      final masterPrivKey = ExtendedPrivateKey.masterKey("b1680c7a6ea6ed5ac9bf3bc3b43869a4c77098e60195bae51a94159333820e125c3409b8c8d74b4489f28ce71b06799b1126c1d9620767c2dadf642cf787cf36".toUint8ListFromHex!);
      final privKeyChild0 = masterPrivKey.normalChild();
      final masterPubKey = masterPrivKey.extendedPublicKey;
      final pubKeyChild0 = masterPubKey.deriveKey();
      expect(masterPrivKey.toUint8List.toHex, "081549973bafbba825b31bcc402a3c4ed8e3185c2f3a31c75e55f423e9629aa3");
      expect(masterPrivKey.chainCode.toHex, "1d7d2a4c940be028b945302ad79dd2ce2afe5ed55e1a2937a5af57f8401e73dd");
      // print(privKeyChild0.extendedPublicKey.path);
      // print(privKeyChild0.extendedPublicKey.compressed.toHex);
      // print(pubKeyChild0.path);
      // print(pubKeyChild0.compressed.toHex);

    });

    test('test keys extension', () {
      final masterPrvKey = ExtendedPrivateKey.masterKey("000102030405060708090a0b0c0d0e0f".toUint8ListFromHex!);
      expect(masterPrvKey.serialize, "xprv9s21ZrQH143K3QTDL4LXw2F7HEK3wJUD2nW2nRk4stbPy6cq3jPPqjiChkVvvNKmPGJxWUtg6LnF5kejMRNNU3TGtRBeJgk33yuGBxrMPHi");
      expect(masterPrvKey.path, "m");
      final masterPubKey = masterPrvKey.extendedPublicKey;
      expect(masterPubKey.serialize, "xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8");
      expect(masterPubKey.path, "mp");
      final prvChild0 = masterPrvKey.deriveKey(hardened: false, index: 0);
      final pubChild0 = masterPubKey.deriveKey(0);
      expect(prvChild0.extendedPublicKey.serialize, pubChild0.serialize);
      // expect(prvChild0H.serialize, "xprv9uHRZZhk6KAJC1avXpDAp4MDc3sQKNxDiPvvkX8Br5ngLNv1TxvUxt4cV1rGL5hj6KCesnDYUhd7oWgT11eZG7XnxHrnYeSvkzY7d2bhkJ7");
      // expect(prvChild0H.path, "m/0'");
      // expect(prvChild0H.extendedPublicKey.serialize, "xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw");
      // final pubChild0H = masterPubKey.deriveKey(ExtendedPrivateKey.PRIVATE_KEY_HARDENED_MIN_INDEX);
      // print(prvChild0H.publicKey.point);
      // print(pubChild0H.point);
    });

  });

  // group('extended public key', () {
  //   test('create', () {
  //     final parentChainCode = "463223aac10fb13f291a1bc76bc26003d98da661cb76df61e750c139826dea8b".toUint8ListFromHex!;
  //     final parentPublicKey = "0252c616d91a2488c1fd1f0f172e98f7d1f6e51f8f389b2f8d632a8b490d5f6da9".toUint8ListFromHex!;
  //     final int i = 0;
  //
  //     ExtendedPublicKey extendedPublicKey = ExtendedPublicKey.fromCompressedParentPublicKey(parentChainCode, parentPublicKey);
  //
  //     ExtendedPublicKey derivedKey = extendedPublicKey.deriveKey();
  //     expect(derivedKey.parentPath, ExtendedPublicKey.PATH_MASTER_PUBLIC);
  //     expect(derivedKey.path, ExtendedPublicKey.PATH_MASTER_PUBLIC + "/0");
  //
  //     expect(derivedKey.chainCode.toHex, 'c84e43b17651cc65f42f1374f527ad9f9fb5cc48c6224bff68883fc6a2a91df3');
  //     expect(derivedKey.compressed.toHex, '03c1995d371665e35093a234a6529bfcfd81a04a143c8a130223b1567e2e0b2e4d');
  //   });
  // });
}