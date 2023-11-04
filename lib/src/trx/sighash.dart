import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';

class SigHash {
  static const int SIGHASH_FORKID = 0x40;// 0100 0000
  static const int SIGHASH_ALL = 0x41;   // 0100 0001
  static const int SIGHASH_NONE = 0x42;  // 0100 0010
  static const int SIGHASH_SINGLE = 0x43;// 0100 0011

  static const int ANYONECANPAY = 0x80; // 1000 0000


  static Uint8List sigHashAll(int inputIndex, Uint8List prevScriptPubKey, Transaction trx) {
    final sigHashFlag = 1;
    var signingTrx = trx.copyWithEmptyInputScripts().copyWithSigScriptAt(data: {inputIndex:prevScriptPubKey});
    return Hash.sha256(Hash.sha256(signingTrx.toUint8List.concat(sigHashFlag.to32Bits(endian: Endian.little))));
  }
}