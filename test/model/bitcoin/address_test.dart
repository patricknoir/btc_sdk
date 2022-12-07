import 'package:btc_sdk/btc_sdk.dart';
import 'package:test/test.dart';

void main() {
  group('address', () {
    test('create valid P2PKH and P2SH addresses', () {
      final pubKeyHash = '20b0d7a1b34295039a6eec64b3a407412461ca6f'.toUint8ListFromHex!;

      final mainnetAddr = Address(Network.mainnet, pubKeyHash);
      final testnetAddr = Address(Network.testnet, pubKeyHash);

      final expectedMainnetP2PKHAddr = '13yrUMkVtgnn2hsWrqaWfgeuKXcAbra1m9';
      final expectedMainnetP2SHAddr = '34fsPuEwSb7A7sZwywF76K1qU3ttDHsmb3';

      final expectedTestnetP2PKHAddr = 'miVomQqUhiE2opM8aQYtVbsEBXCscwVh69';
      final expectedTestnetP2SHAddr = '2MvE5TeAy43cWKfCVf4ryiG16gQ73waxzDL';

      expect(mainnetAddr.p2pkhBase58, expectedMainnetP2PKHAddr);
      expect(mainnetAddr.p2shBase58, expectedMainnetP2SHAddr);

      expect(testnetAddr.p2pkhBase58, expectedTestnetP2PKHAddr);
      expect(testnetAddr.p2shBase58, expectedTestnetP2SHAddr);
    });

    test('create from valid P2PKH address', () {
      final pubKH = 'f8714579f7b9256eef4ea4a930396444f7799e22'.toUint8ListFromHex!;
      final mainnetP2PKHAddr = '1PeeGosykSYHbREbVScnAw5WZkpnhcDsg3';
      final mainnetAddress = Address.fromString(mainnetP2PKHAddr);

      expect(mainnetAddress.network, Network.mainnet);
      expect(mainnetAddress.hash, pubKH);

      final testnetP2PKHAddr = 'n4AbZrxxZTyYNXiDD1b9zrHqRkRVaQAX19';
      final testnetAddress = Address.fromString(testnetP2PKHAddr);

      expect(testnetAddress.network, Network.testnet);
      expect(testnetAddress.hash, pubKH);
    });

    test('create from valid P2SH address', () {
      final hash = 'f8714579f7b9256eef4ea4a930396444f7799e22'.toUint8ListFromHex!;
      final mainnetP2SHAddr = '3QLfCMNRJLrfgaw2cYHNbZSSiH7WFTwooQ';
      final mainnetAddress = Address.fromString(mainnetP2SHAddr);

      expect(mainnetAddress.network, Network.mainnet);
      expect(mainnetAddress.hash, hash);

      final testnetP2SHAddr = '2NFtsG6JSuoN1tNZaHfuFDWRhvdKg1aHmrQ';
      final testnetAddress = Address.fromString(testnetP2SHAddr);

      expect(testnetAddress.network, Network.testnet);
      expect(testnetAddress.hash, hash);
    });
  });
}