import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';

class TransactionOutput {
  // Uint64 (8 Bytes) bitcoin amount in satoshi
  final int nValue;
  final Uint8List scriptPubKey;

  TransactionOutput({required this.nValue, required this.scriptPubKey});

  TransactionOutput copyWith({int? nValue, Uint8List? scriptPubKey}) =>
      TransactionOutput(
        nValue: nValue ??= this.nValue,
        scriptPubKey: scriptPubKey ??= this.scriptPubKey
      );

  Uint8List get toUint8List =>
      nValue.to64Bits(endian: Endian.little)
        .concat(VarInt.fromValue(scriptPubKey.length).toUint8List)
        .concat(scriptPubKey);
}