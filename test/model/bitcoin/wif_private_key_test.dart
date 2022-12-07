import 'package:btc_sdk/btc_sdk.dart';
import 'package:fast_base58/fast_base58.dart';
import 'package:test/test.dart';

void main() {
  group('wif private key', () {
    test('creation', () {
      final pubKeyHashCompressed = 'KybG9fqdgrTXP8GWk4LZXdkTpKutf8PqMMxQpcBprd93CWecwQph';
      final pubKeyHashUncompressed = '5JMT68toNiZk8jRp4s9WaDrisbeMmSEnPjozWN7XnEAygr14ZuR';
      final wifPrvKeyCompressed = WifPrivateKey(Network.mainnet, '46c2f278fa5f60b68cbbd8840799730160713fc748d613cb7e742e3625d29ce5'.toUint8ListFromHex!, true);
      final wifPrvKeyUncompressed = WifPrivateKey(Network.mainnet, '46c2f278fa5f60b68cbbd8840799730160713fc748d613cb7e742e3625d29ce5'.toUint8ListFromHex!, false);

      expect(wifPrvKeyCompressed.toWif, pubKeyHashCompressed);
      expect(wifPrvKeyUncompressed.toWif, pubKeyHashUncompressed);

      final decodedUncompressedPKH = Base58Decode(pubKeyHashUncompressed).toUint8List;
      expect(decodedUncompressedPKH.sublist(1, decodedUncompressedPKH.length - 4), wifPrvKeyUncompressed.value);

      final decodedCompressedPKH = Base58Decode(pubKeyHashCompressed).toUint8List;
      expect(decodedCompressedPKH.sublist(1, decodedCompressedPKH.length - 5), wifPrvKeyCompressed.value);
    });

    test('from base58check', () {
      final prvKeyHashMainnetCompressed = 'KwoJPMvvjKPcU9p41GcF84Y5tHghrka3Vj8MrMrhhCzSyvTn4S2b';
      final prvKeyHashMainnetUncompressed = '5HwtyGcnFaAewdtSbxCA6E34Nb96BNCZjkyx2DRrYmQSNYktrUH';
      final prvKeyHashTestnetCompressed = 'cNAHrGvnAP5sdbHKPgRNVP39WWz7XCfjZmGpxnKDCKeTEfVy4iHc';
      final prvKeyHashTestnetUncompressed = '91iXZ1SKqoEnuhPjEJ64xpb22FVoLXjm5hqu6qnMtW9V9bHAZra';

      final prvk = '1147a1675e5181e75c8da3ff7e8f2807c51a5201229fc57d434a9565611b5eb0'.toUint8ListFromHex;

      final prvKHMC = WifPrivateKey.parseBase58Check(prvKeyHashMainnetCompressed);
      expect(prvKHMC.network, Network.mainnet);
      expect(prvKHMC.isCompressed, true);
      expect(prvKHMC.value, prvk);

      final prvKHMU = WifPrivateKey.parseBase58Check(prvKeyHashMainnetUncompressed);
      expect(prvKHMU.network, Network.mainnet);
      expect(prvKHMU.isCompressed, false);
      expect(prvKHMU.value, prvk);

      final prvKHTC = WifPrivateKey.parseBase58Check(prvKeyHashTestnetCompressed);
      expect(prvKHTC.network, Network.testnet);
      expect(prvKHTC.isCompressed, true);
      expect(prvKHTC.value, prvk);

      final prvKHTU = WifPrivateKey.parseBase58Check(prvKeyHashTestnetUncompressed);
      expect(prvKHTU.network, Network.testnet);
      expect(prvKHTU.isCompressed, false);
      expect(prvKHTU.value, prvk);
    });
  });
}