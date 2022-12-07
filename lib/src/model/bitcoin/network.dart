// ignore_for_file: constant_identifier_names

enum Network {

  mainnet(MAINNET_PREFIX),
  testnet(TESTNET_PREFIX);

  static const int MAINNET_PREFIX = 0x80;
  static const int TESTNET_PREFIX = 0xEF;

  final int prefix;
  const Network(this.prefix);

  factory Network.fromPrefix(int prefix) {
    switch(prefix) {
      case MAINNET_PREFIX:
        return Network.mainnet;
      case TESTNET_PREFIX:
        return Network.testnet;
      default:
        throw Exception('Unsupported Prefix');

    }
  }
}