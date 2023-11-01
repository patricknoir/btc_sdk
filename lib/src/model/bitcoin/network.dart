// ignore_for_file: constant_identifier_names

enum Network {

  mainnet(MAINNET_WIF_PRVK_PREFIX, MAINNET_P2PKH_PREFIX, MAINNET_P2SH_PREFIX, MAINNET_BECH32_PREFIX, MAINNET_EXT_PRVK_PREFIX, MAINNET_EXT_PUBK_PREFIX, MAINNET_MAX_nBITS),
  testnet(TESTNET_WIF_PRVK_PREFIX, TESTNET_P2PKH_PREFIX, TESTNET_P2SH_PREFIX, TESTNET_BECH32_PREFIX, TESTNET_EXT_PRVK_PREFIX, TESTNET_EXT_PUBK_PREFIX, TESTNET_MAX_nBITS);

  static const int MAINNET_MAX_nBITS = 0x1d00ffff;
  static const int MAINNET_WIF_PRVK_PREFIX = 0x80;
  static const int MAINNET_P2PKH_PREFIX = 0x00;
  static const int MAINNET_P2SH_PREFIX = 0x05;
  static const String MAINNET_BECH32_PREFIX = "bc";
  static const int MAINNET_EXT_PRVK_PREFIX = 0x0488ADE4; // xprv
  static const int MAINNET_EXT_PUBK_PREFIX = 0x0488B21E; // xpub

  static const int TESTNET_MAX_nBITS = 0x1d00ffff;
  static const int TESTNET_WIF_PRVK_PREFIX = 0xEF;
  static const int TESTNET_P2PKH_PREFIX = 0x6F;
  static const int TESTNET_P2SH_PREFIX = 0xC4;
  static const String TESTNET_BECH32_PREFIX = "tc";
  static const int TESTNET_EXT_PRVK_PREFIX = 0x04358394; // tprv
  static const int TESTNET_EXT_PUBK_PREFIX = 0x043587CF; // tpub

  final int nBits;
  final int wif;
  final int p2pkh;
  final int p2sh;
  final String bech32;
  final int bip32Private;
  final int bip32Public;

  const Network(this.wif, this.p2pkh, this.p2sh, this.bech32, this.bip32Private, this.bip32Public, this.nBits);

  factory Network.fromWif(int prefix) {
    switch(prefix) {
      case MAINNET_WIF_PRVK_PREFIX:
        return Network.mainnet;
      case TESTNET_WIF_PRVK_PREFIX:
        return Network.testnet;
      default:
        throw Exception('Unsupported Prefix');
    }
  }

  factory Network.fromP2PKH(int prefix) {
    switch(prefix) {
      case MAINNET_P2PKH_PREFIX:
        return Network.mainnet;
      case TESTNET_P2PKH_PREFIX:
        return Network.testnet;
      default:
        throw Exception('Unsupported Prefix');
    }
  }
}