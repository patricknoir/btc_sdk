import 'dart:typed_data';

import 'package:btc_sdk/btc_sdk.dart';

class Transaction {

  static const int TX_VERSION_1 = 0x01000000;
  static const int TX_VERSION_2 = 0x02000000;

  static const int TX_nLOCK_DEFAULT = 0x00000000;

  final int version; //32 bits (4 Bytes) little endian
  final List<TransactionInput> inputs;
  final List<TransactionOutput> outputs;
  final int nLockTime;

  const Transaction({required this.version, required this.inputs, required this.outputs, this.nLockTime = Transaction.TX_nLOCK_DEFAULT});

  factory Transaction.fromBytes(Uint8List data) => TransactionReader.fromUint8List(data).readTransaction();
}