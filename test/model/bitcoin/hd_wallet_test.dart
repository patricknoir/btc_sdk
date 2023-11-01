import 'package:btc_sdk/btc_sdk.dart';
import 'package:test/test.dart';

void main() {
  group('hd_wallet', () {
    test('seed', () {
      final mnemonic = HDWallet.generateMnemonic();
      expect(mnemonic.split(' ').length, 24);
    });

    test('master private key', () {
      // final seed = '7f2507c3adb7115aa3c5a0f33011d36991e0bd5458b9f3148e27bc9be06c37b0d8389dea5fa306d8a1ccc0e7a2181f7a31fd26b2e860e5263a1cdf6952fb4004'.toUint8ListFromHex!;
      // final wallet = HDWallet(seed);
      //
      // final masterPrivateKey = wallet.masterPrivateKey.sublist(0, 32);
      // final chainCode = wallet.masterPrivateKey.sublist(32, 64);
      //
      // expect(masterPrivateKey.toHex, '962a2004cc3aba45f3c4c03177580d8f59e3a905b6eda9404e90f8d87ec33c97');
      // expect(chainCode.toHex, '2aa06db40f0d7a4dee98dad46de11cc484edb6e3e59c9de99eca2a442ccb7e2a');
      //
      // final xprv = 0xa63383.to32Bits().toUint8List;
      // print(xprv.toHex);
      //
      // print('a63383'.toUint8ListFromHex!.toBase58);

      final seed = '67f93560761e20617de26e0cb84f7234aaf373ed2e66295c3d7397e6d7ebe882ea396d5d293808b0defd7edd2babd4c091ad942e6a9351e6d075a29d4df872af'.toUint8ListFromHex!;
      final wallet = HDWallet.fromSeed(seed);

      // final masterPrivateKey = wallet.masterPrivateKey.sublist(0, 32);
      // final chainCode = wallet.masterPrivateKey.sublist(32, 64);
      //
      // expect(masterPrivateKey.toHex, 'f79bb0d317b310b261a55a8ab393b4c8a1aba6fa4d08aef379caba502d5d67f9');
      // expect(chainCode.toHex, '463223aac10fb13f291a1bc76bc26003d98da661cb76df61e750c139826dea8b');
      //
      // PrivateKey prvk = PrivateKey(masterPrivateKey);
      // expect(prvk.publicKey.compressed.toHex, '0252c616d91a2488c1fd1f0f172e98f7d1f6e51f8f389b2f8d632a8b490d5f6da9');
    });

    // test('master private key address', () {
    //   final seed = 'fffcf9f6f3f0edeae7e4e1dedbd8d5d2cfccc9c6c3c0bdbab7b4b1aeaba8a5a29f9c999693908d8a8784817e7b7875726f6c696663605d5a5754514e4b484542'.toUint8ListFromHex!;
    //   final wallet = HDWallet(seed);
    //   print(wallet.masterPrivateKey.sublist(0, 32).toHex);
    //   print(wallet.masterPrivateKey.sublist(32, 64).toHex);
    //
    //   print((Network.mainnet.bip32Private.toHex + wallet.masterPrivateKey.sublist(0, 32).toHex).toUint8ListFromHex!.toBase58);
    // });
  });
}